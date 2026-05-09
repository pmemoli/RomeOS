# RomeOS

An x86-64 xv6-like OS for the default qemu configuration.

Final goal is a simple window system for shells, and running doom as a user space program.

Done:
- Bootloader that sets up long mode and jumps to a C kernel entry point.

TODO:
- Kernel setting up the remainder x86 data structures.

## Bootloader

We use a *double stage bootloader* where the first stage fits within the first 440 bytes of the MBR, and the other loads the kernel. Actual systems will use GRUB (gnu project bootloader) for their specific boot firmware and architecture, and probably use UEFI.

The kernel and bootloaders just lives in the ~481 kbytes of physical memory between 0x7C00 and 0x7FFFF. First 2 mb of physical memory are mapped at virtual address 0xFFFFFFFF80000000. 

Found this really cool source for this:

https://alamot.github.io/os_stage1/
https://alamot.github.io/os_stage2/

We generate object files for stage 1, stage 2 and the c kernel, which are linked using ld according to kernel/linker.ld. Then we just prune the elf headers with objcopy -O binary. 

## Sources:

- OSDEV: https://wiki.osdev.org/Main_Page
- Intel systems programming manual: https://pdos.csail.mit.edu/6.828/2008/readings/ia32/IA32-3A.pdf

