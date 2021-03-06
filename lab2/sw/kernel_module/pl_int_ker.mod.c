#include <linux/module.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

MODULE_INFO(vermagic, VERMAGIC_STRING);

__visible struct module __this_module
__attribute__((section(".gnu.linkonce.this_module"))) = {
	.name = KBUILD_MODNAME,
	.init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
	.exit = cleanup_module,
#endif
	.arch = MODULE_ARCH_INIT,
};

static const struct modversion_info ____versions[]
__used
__attribute__((section("__versions"))) = {
	{ 0x6c9dadc8, __VMLINUX_SYMBOL_STR(module_layout) },
	{ 0xbf9d756, __VMLINUX_SYMBOL_STR(cdev_del) },
	{ 0xb7754f2a, __VMLINUX_SYMBOL_STR(device_destroy) },
	{ 0xf20dabd8, __VMLINUX_SYMBOL_STR(free_irq) },
	{ 0xedc03953, __VMLINUX_SYMBOL_STR(iounmap) },
	{ 0x84e06acf, __VMLINUX_SYMBOL_STR(remove_proc_entry) },
	{ 0x7485e15e, __VMLINUX_SYMBOL_STR(unregister_chrdev_region) },
	{ 0x375cdb51, __VMLINUX_SYMBOL_STR(class_destroy) },
	{ 0x79c5a9f0, __VMLINUX_SYMBOL_STR(ioremap) },
	{ 0xd6b8e852, __VMLINUX_SYMBOL_STR(request_threaded_irq) },
	{ 0x5d534a5b, __VMLINUX_SYMBOL_STR(cdev_add) },
	{ 0x220c9794, __VMLINUX_SYMBOL_STR(cdev_init) },
	{ 0x8bc4f6e5, __VMLINUX_SYMBOL_STR(device_create) },
	{ 0xb74f0973, __VMLINUX_SYMBOL_STR(__class_create) },
	{ 0x29537c9e, __VMLINUX_SYMBOL_STR(alloc_chrdev_region) },
	{ 0x27e1a049, __VMLINUX_SYMBOL_STR(printk) },
	{ 0x1091b658, __VMLINUX_SYMBOL_STR(proc_create_data) },
	{ 0x1cb71b95, __VMLINUX_SYMBOL_STR(fasync_helper) },
	{ 0x639f3e13, __VMLINUX_SYMBOL_STR(kill_fasync) },
	{ 0x28118cb6, __VMLINUX_SYMBOL_STR(__get_user_1) },
	{ 0xbb72d4fe, __VMLINUX_SYMBOL_STR(__put_user_1) },
	{ 0xefd6cf06, __VMLINUX_SYMBOL_STR(__aeabi_unwind_cpp_pr0) },
};

static const char __module_depends[]
__used
__attribute__((section(".modinfo"))) =
"depends=";

