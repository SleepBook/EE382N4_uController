#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>

//module_param(name, charp, S_IRUGO);
//MODULE_PARM_DESC(name, "The name to display somewhere");

static int __init hello_init(void)
{
    printk(KERN_INFO "HELLO FROM MY MODULE\n", name);
    //printk(KERN_INFO "HELLO FROM MY MODULE\n", name);
    return 0;
}

static void __exit hello_exit(void)
{
    printk(KERN_INFO "Good BYE\n", name);
    //printk(KERN_INFO "Good BYE\n", name);
}

module_init(hello_init);
module_exit(hello_exit);
