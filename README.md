An x86-64 xv6-like OS for the default qemu configuration.

Final goal is a simple window system for shells, and running doom as a user space program.

TODO:

- Set the cool 0x13 VGA mode in stage 2 before far jump
- Load an actual C kernel in real mode before the far jump in the bootloader.

Sources:

- OSDEV: https://wiki.osdev.org/Main_Page
- Intel systems programming manual: https://pdos.csail.mit.edu/6.828/2008/readings/ia32/IA32-3A.pdf

