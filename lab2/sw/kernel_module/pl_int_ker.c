/*
 * EE382N.4 Lab2
 * Kernel module for processing interrupt
 *     Bonding income int and set a SIGIO based on that
 *     which will be catchted by a user program for measuring latency
 * Wenqi Yin
 */
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/proc_fs.h>
#include <linux/version.h>
#include <linux/errno.h>
#include <linux/fs.h>
#include <linux/mm.h>
#include <linux/interrupt.h>
#include <linux/sched.h>
#include <asm/uaccess.h>
#include <asm/io.h>
#include <linux/vmalloc.h>
#include <linux/mman.h>
#include <linux/slab.h>
#include <linux/ioport.h>

#include <linux/types.h>
#include <linux/kdev_t.h>
#include <asm/uaccess.h>
#include <linux/platform_device.h>
#include <linux/device.h>
#include <linux/cdev.h>

#define MODULE_VER "1.0"
#define INTERRUPT 164
#define FPGA_INT_PA_BASE 0x43C10000
#define MAP_SIZE 4096UL
#define MODULE_NM "fpga_intr"
#define CLASS_NM "fpga_peri"
#define DEVICE_NM "fpga_intr"

static struct proc_dir_entry *proc_file;
static struct fasync_struct *fasync_queue ;
static struct device *dev_dev;  /* Global variable for the character device structure */
static struct class *dev_class;  /* Global variable for the device class */
static int major_num;
static void __iomem * fpga_int_va_base;
static int fpga_int_va_offset;
static int errno;

irqreturn_t interrupt_handler(int irq, void *dev_id)
{  
  printk(KERN_INFO "[KM %s] Interrupt detected in kernel \n", MODULE_NM);
  kill_fasync(&fasync_queue, SIGIO, POLL_IN);
  return 0;
}


static int fpga_int_open (struct inode *inode, struct file *file) {
  printk(KERN_INFO "[KM %s] Inside %s_open \n", MODULE_NM, MODULE_NM);
  fpga_int_va_offset = 0;
  return 0;
}


static int fpga_int_release (struct inode *inode, struct file *file) {
  printk(KERN_INFO "[KM %s] Inside %s_release \n", MODULE_NM, MODULE_NM);
  return 0;
}


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * function: fpga_fasync
 *
 * This is invoked by the kernel when the user program opens this
 * input device and issues fcntl(F_SETFL) on the associated file
 * descriptor. fasync_helper() ensures that if the driver issues a
 * kill_fasync(), a SIGIO is dispatched to the owning application.
 * Actually i am not clear how this helper function ensures that
 */
static int fpga_int_fasync (int fd, struct file *filp, int on)
{
  printk(KERN_INFO "[KM %s] Inside %s_fasync \n", MODULE_NM, MODULE_NM);
  return fasync_helper(fd, filp, on, &fasync_queue);
} 


ssize_t fpga_int_read(
        struct file *fd,
        char *buf,
        size_t len,
        loff_t *offset)
{
    int errno = 0;
    errno = copy_to_user(buf, fpga_int_va_base, len);
    if(errno != 0){
      printk(KERN_ALERT "ERROR when read from kernel\n");
      return -EFAULT;
    }
  return 0;
}


ssize_t fpga_int_write(struct file* fd, const char* buf, size_t len, loff_t *offset)
{
    return 0;
}


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*
*  Define which file operations are supported
*
*/
struct file_operations fpga_int_fops = {
  .owner = THIS_MODULE,
  .llseek = NULL,
  .read = fpga_int_read,
  .write = fpga_int_write,
  .poll = NULL,
  .unlocked_ioctl = NULL,
  .mmap = NULL,
  .open = fpga_int_open,
  .flush = NULL,
  .release = fpga_int_release,
  .fsync = NULL,
  .fasync = fpga_int_fasync,
  .lock = NULL,
};

static const struct file_operations proc_fops = {
  .owner = THIS_MODULE,
  .open = NULL,
  .read = NULL,
};
     

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * function: init_fpga_int
 *
 * This function creates the /proc directory entry interrupt_arm. It
 * also configures the parallel port then requests interrupt 240 from Linux.
 */
 
static int __init init_fpga_int(void)
{
  printk("[KM %s] Start initializing \n", MODULE_NM);

  //create /proc entry
  proc_file = proc_create("fpga_int", 0444, NULL, &proc_fops );
  if(NULL == proc_file) {
      printk(KERN_ALERT "[KM %s] create /proc entry returned NULL. ABORTING! \n", MODULE_NM);
      return -ENOMEM;
  }
  printk(KERN_INFO "[KM %s] create /proc entry successful\n", MODULE_NM);

  //create /dev entry
  major_num = register_chrdev(0, MODULE_NM, &fpga_int_fops);
  if(0 > major_num){
      printk(KERN_ALERT "Fail to register %s under /dev", MODULE_NM);
      remove_proc_entry("fpga_intr", NULL);
      return -EBUSY;
  }
  printk(KERN_INFO "[KM %s] Successfully register with major number %d\n",MODULE_NM, major_num);

  dev_class = class_create(THIS_MODULE, CLASS_NM);
  if(IS_ERR(dev_class)){
      unregister_chrdev(major_num, MODULE_NM);
      remove_proc_entry("fpga_intr", NULL);
      printk(KERN_ALERT "Fail to create device class\n");
      return -EBUSY;
  }
  
  dev_dev = device_create(dev_class, NULL, MKDEV(major_num, 0), NULL, DEVICE_NM);
  if(IS_ERR(dev_dev)){
      class_destroy(dev_class);
      unregister_chrdev(major_num, MODULE_NM);
      remove_proc_entry("fpga_intr", NULL);
      printk(KERN_ALERT "Fail to create device\n");
      return -EBUSY;
  }

  //bond interrupt
  errno = request_irq(INTERRUPT, interrupt_handler, IRQF_TRIGGER_RISING,
                   "fpga_intr", NULL);
  if(errno){
    printk(KERN_ALERT "[KM %s] Can't get interrupt %d \n", MODULE_NM, INTERRUPT);
    device_destroy(dev_class, MKDEV(major_num, 0));
    class_destroy(dev_class);
    unregister_chrdev(major_num, MODULE_NM);
    remove_proc_entry("fpag_intr", NULL);
    return -ENOMEM;
  }

 
  //maping register to addressspace
  fpga_int_va_base = ioremap((resource_size_t)FPGA_INT_PA_BASE, MAP_SIZE);
  printk(KERN_INFO "[KM %s] mapped to virtual address %p \n", MODULE_NM, fpga_int_va_base);
  printk(KERN_INFO "[KM %s] %s Initialization done\n ",MODULE_NM, MODULE_VER);
  return 0;
}


static void __exit cleanup_fpga_int(void)
{
  iounmap(fpga_int_va_base);
  free_irq(INTERRUPT,NULL);
  device_destroy(dev_class, MKDEV(major_num, 0));
  class_destroy(dev_class);
  unregister_chrdev(major_num, MODULE_NM);
  remove_proc_entry("fpga_intr", NULL);
}


module_init(init_fpga_int);
module_exit(cleanup_fpga_int);

MODULE_AUTHOR("Wenqi Yin");
MODULE_DESCRIPTION("pl_interrupt handler module");
MODULE_LICENSE("GPL");
