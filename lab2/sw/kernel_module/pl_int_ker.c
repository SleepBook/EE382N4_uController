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
#define MODULE_NM "fpga_int"

#undef DEBUG
//#define DEBUG

static struct proc_dir_entry *proc_file;
static struct fasync_struct *fasync_queue ;
static struct cdev chr_dev;  /* Global variable for the character device structure */
static struct class *p_devclass;  /* Global variable for the device class */
static int errno;
static dev_t dev_num;  /* Global variable for the first device number */

static int fid;  /* opened file id */
static char * fpga_int_va_base;


/*
 * This function is called when the associated interrupt raises
 */
irqreturn_t interrupt_handler(int irq, void *dev_id)
{  
#ifdef DEBUG
  printk(KERN_INFO "[KM %s] Interrupt detected in kernel \n", MODULE_NM);
#endif
  
/* 
 * Signal the user application that an interupt occured
 * NOTICE the name kill in Linux usually is assocaited with 
 * sending signals
 */
  kill_fasync(&fasync_queue, SIGIO, POLL_IN);
  return 0;
}


/*
 * This function is called when the fpga_int device is opened
 */
static int fpga_int_open (struct inode *inode, struct file *file) {
#ifdef DEBUG
  printk(KERN_INFO "[KM %s] Inside %s_open \n", MODULE_NM, MODULE_NM);
#endif

  fid = open("/dev/mem", O_RDWR|O_SYNC);
  if(0 > fid)
  {
      printk(KERN_ALERT "[KM %s] Open /dev/mem error: %d \n", MODULE_NM, fid);
      return -1;
  }
  else  /* now /dev/mem is opened, do memory map */
  {
      fpga_int_va_base = (char *)mmap(
              NULL,  /* let kernel to choose the virtual address */
              4096UL,  /* always map one page */
              PROT_READ|PROT_WRITE,  /* permissions protection */
              MAP_SHARED,  /* share the mapping? */
              fid,  /* target device node to map */
              FPGA_INT_PA_BASE
              );
  }

  return 0;
}


/*
 * This function is called when the fpga_int device is released
 */
static int fpga_int_release (struct inode *inode, struct file *file) {
#ifdef DEBUG
  printk(KERN_INFO "[KM %s] Inside %s_release \n", MODULE_NM, MODULE_NM);
#endif
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
#ifdef DEBUG
  printk(KERN_INFO "[KM %s] Inside %s_fasync \n", MODULE_NM, MODULE_NM);
#endif
  return fasync_helper(fd, filp, on, &fasync_queue);
} 

/*
 * This function is to map the read operation on the device node to device
 */
ssize_t fpga_int_read (
        struct file * pf,  /* point to file struct */
        char * usr_buf,  /* the buffer to fill with data */
        size_t len,  /* the length of buffer */
        loff_t * offset  /* offset in the file, need explicitly point
                            out if it is not recorded in pf struct */
        ) {
#ifdef DEBUG
  printk(KERN_INFO "[KM %s] Inside %s_read, fill %d char to %x \n",
          MODULE_NM, MODULE_NM, len, usr_buf);
#endif
  int bytes_read = 0;
  char * p_reg = *offset;

  while(len)
  {
      put_user(*(p_reg++), usr_buf++);
      len--;
      bytes_read++;
      *offset++;
  }

  return bytes_read;
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
  .write = NULL,
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

#ifdef DEBUG
  printk("[KM %s] Start initializing \n", MODULE_NM);
#endif
	
  /* Step 0: create proc entry */
  proc_file = proc_create("fpga_int", 0444, NULL, &proc_fops );
  
  if(NULL == proc_file) {
    printk(KERN_ALERT "[KM %s] create /proc entry returned NULL. ABORTING! \n", MODULE_NM);
    goto proc_create_failed;
  }

  /* Step 1: allocate character device region */
  errno = alloc_chrdev_region( &dev_num, 0, 1, MODULE_NM);

  if(0 > errno)
  {
    printk(KERN_ALERT "[KM %s] Device Registration error: %d \n", MODULE_NM, errno);
    return -EBUSY;
  }
#ifdef DEBUG
  else
    printk(KERN_ALERT "[KM %s] Major Number is %d \n", MODULE_NM, dev_num >> 20);
#endif

  /* Step 2: create character device class */
  p_devclass = class_create(THIS_MODULE, "chardev");
  if(NULL == p_devclass)
  {
    printk(KERN_ALERT "[KM %s] Class creation failed \n", MODULE_NM);
    goto devclass_create_failed;
  }

  /* Step 3: create character device */
  if(NULL == device_create(p_devclass, NULL, dev_num, NULL, MODULE_NM))
  {
    printk(KERN_ALERT "[KM %s] Device creation failed \n", MODULE_NM);
    goto dev_create_failed;
  }

  /* Step 4: initialize character device and add it to device class */
  cdev_init(&chr_dev, &fpga_int_fops);

  if(-1 == cdev_add(&chr_dev, dev_num, 1))
  {
    printk(KERN_ALERT "[KM %s] Device addition failed \n", MODULE_NM);
    goto dev_add_failed;
  }

 /* Step 5: bind interrupt from linux */
 
  errno = request_irq(INTERRUPT, interrupt_handler, IRQF_TRIGGER_RISING,
                   "fpga_int", NULL);
  
  if(errno)
  {
    printk(KERN_ALERT "[KM %s] Can't get interrupt %d \n", MODULE_NM, INTERRUPT);
    goto irq_request_failed;
  }

/* everything initialized */
#ifdef DEBUG
  printk(KERN_INFO "[KM %s] %s Initialized\n ",MODULE_NM, MODULE_VER);
#endif
  return 0;

irq_request_failed:
dev_add_failed:
dev_create_failed:
  class_destroy(p_devclass);
devclass_create_failed:
  unregister_chrdev_region(dev_num, 1);
/* remove the proc entry on error */
  remove_proc_entry("fpga_int", NULL);
  return -EBUSY;

proc_create_failed:
  return -ENOMEM;

}


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * function: cleanup_fpga_int
 *
 * This function frees interrupt 164 then removes the /proc directory entry 
 * interrupt_arm. 
 */
 
static void __exit cleanup_fpga_int(void)
{
  /* Step -5: free the interrupt */
  free_irq(INTERRUPT,NULL);
#ifdef DEBUG
  printk(KERN_INFO "[KM %s] interrupt %d released \n", MODULE_NM, INTERRUPT);
#endif

  /* Step -4: remove device from class */
  device_destroy(p_devclass, dev_num);
#ifdef DEBUG
  printk(KERN_INFO "[KM %s] device removed \n", MODULE_NM);
#endif

  /* Step -3: device delete */
  cdev_del(&chr_dev);
#ifdef DEBUG
  printk(KERN_INFO "[KM %s] device deleted \n", MODULE_NM);
#endif

  /* Step -2: destroy device class */
  class_destroy(p_devclass);
#ifdef DEBUG
  printk(KERN_INFO "[KM %s] device class destroied \n", MODULE_NM);
#endif

  /* Step -1: unregister character device region */
  unregister_chrdev_region(dev_num, 1);
#ifdef DEBUG
  printk(KERN_INFO "[KM %s] device region unregisted \n", MODULE_NM);
#endif

  /* Step -0: remove proc entry */
  remove_proc_entry("fpga_int", NULL);
#ifdef DEBUG
  printk(KERN_INFO "[KM %s] /dev/fpga_int removed \n", MODULE_NM);
#endif
}

module_init(init_fpga_int);
module_exit(cleanup_fpga_int);

MODULE_AUTHOR("Wenqi Yin");
MODULE_DESCRIPTION("pl_interrupt handler module");
MODULE_LICENSE("GPL");
