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


#define MODULE_VER "1.0"
#define INTERRUPT 164	// 
#define PL_PERI_MAJOR 245
#define MODULE_NM "fpga_interrupt_peripheral"

#undef DEBUG
#define DEBUG

static struct proc_dir_entry *interrupt_arm_file;
static struct fasync_struct *fasync_fpga_queue ;

void interrupt_handler(int irq, void *dev_id, struct pt_regs *regs)
{  
#ifdef DEBUG
    printk(KERN_INFO "fpga_int_peripheral: Interrupt detected in kernel \n");
#endif
  
/* Signal the user application that an interupt occured */  
  kill_fasync(&fasync_fpga_queue, SIGIO, POLL_IN);
}


/*
 * This function is called when the fpga_int device is opened
 */
 
static int fpga_open (struct inode *inode, struct file *file) {
#ifdef DEBUG
    	printk(KERN_INFO "fpga_int_peripheral: Inside fpga_open \n");
#endif
	return 0;
}


/*
 * This function is called when the fpga_int device is released
 */
static int fpga_release (struct inode *inode, struct file *file) {

#ifdef DEBUG
    	printk(KERN_INFO "\nfpga_int: Inside fpga_release \n");  // DEBUG
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
 */
static int fpga_fasync (int fd, struct file *filp, int on)
{
#ifdef DEBUG
    	printk(KERN_INFO "\nfpga_int: Inside fpga_fasync \n");  // DEBUG
#endif
	return fasync_helper(fd, filp, on, &fasync_fpga_queue);
} 



/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*
*  Define which file operations are supported
*
*/

struct file_operations fpga_fops = {
	.owner	=	THIS_MODULE,
	.llseek	=	NULL,
	.read	=	NULL,
	.write	=	NULL,
	.poll	=	NULL,
	.unlocked_ioctl	=	NULL,
	.mmap	=	NULL,
	.open	=	fpga_open,
	.flush	=	NULL,
	.release=	fpga_release,
	.fsync	=	NULL,
	.fasync	=	fpga_fasync,
	.lock	=	NULL,
	.read	=	NULL,
	.write	=	NULL,
};

static const struct file_operations proc_fops = {
    .owner  = THIS_MODULE,
    .open   = NULL,
    .read   = NULL,
};
     

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * function: init_interrupt_arm
 *
 * This function creates the /proc directory entry interrupt_arm. It
 * also configures the parallel port then requests interrupt 240 from Linux.
 */
 
static int __init init_interrupt_arm(void)
{

 int rv = 0;
 
  printk("FPGA Interrupt Module\n");
  printk("FPGA Driver Loading.\n");
  printk("Using Major Number %d on %s\n", PL_PERI_MAJOR, MODULE_NM); 
	
  if (register_chrdev(PL_PERI_MAJOR, MODULE_NM, &fpga_fops)) {
	printk("fpga_int: unable to get major %d. ABORTING!\n", PL_PERI_MAJOR);
	return -EBUSY;
	}


  interrupt_arm_file = proc_create("interrupt_arm", 0444, NULL, &proc_fops );
  
  if(interrupt_arm_file == NULL) {
  	printk("fpga_int: create /proc entry returned NULL. ABORTING!\n");
    return -ENOMEM;
  }

 // request interrupt from linux
 
  rv = request_irq(INTERRUPT, interrupt_handler, IRQF_TRIGGER_RISING,
                   "interrupt_arm", NULL);
  
  if ( rv ) {
    printk("Can't get interrupt %d\n", INTERRUPT);
    goto no_interrupt_arm;
  }


/* everything initialized */
  printk(KERN_INFO "%s %s Initialized\n",MODULE_NM, MODULE_VER);
  return 0;

/* remove the proc entry on error */
  no_interrupt_arm:
  remove_proc_entry("interrupt_arm", NULL);
  return -EBUSY;
}


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * function: cleanup_interrupt_arm
 *
 * This function frees interrupt 164 then removes the /proc directory entry 
 * interrupt_arm. 
 */
 
static void __exit cleanup_interrupt_arm(void)
{

/* free the interrupt */
  free_irq(INTERRUPT,NULL);
  
  unregister_chrdev(PL_PERI_MAJOR, MODULE_NM);

  remove_proc_entry("interrupt_arm", NULL);
  printk(KERN_INFO "%s %s removed\n", MODULE_NM, MODULE_VER);
}

module_init(init_interrupt_arm);
module_exit(cleanup_interrupt_arm);

MODULE_AUTHOR("Wenqi Yin");
MODULE_DESCRIPTION("pl_interrupt handler module");
MODULE_LICENSE("GPL");
