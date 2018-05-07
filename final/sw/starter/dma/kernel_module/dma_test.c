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
#define MAP_SIZE 4096UL
#define MODULE_NM "dma_test"

#define DMA_RES_ADDR 0x001fff00
#define DMA_RES_ADDR2 0x001fffa0
#define RES_SIZE 16

#undef DEBUG

/*
 * This function is called when the fpga_int device is opened
 */
static int fpga_int_open (struct inode *inode, struct file *file) {
#ifdef DEBUG
  printk(KERN_INFO "[KM %s] Inside %s_open \n", MODULE_NM, MODULE_NM);
#endif
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

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*
*  Define which file operations are supported
*
*/
struct file_operations fpga_int_fops = {
  .owner = THIS_MODULE,
  .llseek = NULL,
  .read = NULL,
  .write = NULL,
  .poll = NULL,
  .unlocked_ioctl = NULL,
  .mmap = NULL,
  .open = fpga_int_open,
  .flush = NULL,
  .release = fpga_int_release,
  .fsync = NULL,
  .fasync = NULL,
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
  /* temporility use this kernal module for dma test */
  if(request_mem_region(DMA_RES_ADDR, RES_SIZE, MODULE_NM)== NULL){
      printk(KERN_ALERT "Reserving PHY Addr space failed");
      return -EBUSY;
  }

  if(request_mem_region(DMA_RES_ADDR2, RES_SIZE, MODULE_NM)== NULL){
      printk(KERN_ALERT "Reserving PHY Addr2 space failed");
      return -EBUSY;
  }

  /* everything initialized */
#ifdef DEBUG
  printk(KERN_INFO "[KM %s] %s Initialized\n ",MODULE_NM, MODULE_VER);
#endif
  return 0;
}


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * function: cleanup_fpga_int
 *
 * This function frees interrupt 164 then removes the /proc directory entry 
 * interrupt_arm. 
 */
 
static void __exit cleanup_fpga_int(void)
{
   /* releasing the address reservation */
  release_mem_region(DMA_RES_ADDR, RES_SIZE);
  release_mem_region(DMA_RES_ADDR2, RES_SIZE);
}

module_init(init_fpga_int);
module_exit(cleanup_fpga_int);

MODULE_AUTHOR("Wenqi Yin");
MODULE_DESCRIPTION("dma_learn module");
MODULE_LICENSE("GPL");
