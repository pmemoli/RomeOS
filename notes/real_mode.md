# Real mode

When processor boots up, it is set on real mode which duplicates the execution environment of the 8086 processors. It is a 16 bit machine with no protection, and can address 1 mb of memory.

The BIOS tests and initializes the hardware, sets up the IVT (along with a bunch of other stuff probably), then loads up the MBR from the first bootable disk into memory at physical address 0x7C00, and then starts running the code in the MBR. The MBR is 512 bytes, with the first 440 bytes containing the bootloader code, and the rest containing partition table info. 

According to OSDEV (i imagine modern hardware still follows this, not sure) after bios cedes control, memory is laid out like: 

https://wiki.osdev.org/Memory_Map_(x86)

## Memory & Registers

Real mode supports up to 1mb (2^20 bytes) of physical memory, which is divided into segments of up to 2^16 (64 K) bytes.

It provides 16 bit general purpose registers, 4 segment registers, the IP mapped to the lower 16 bits of EIP and a control flags register.

It uses the SS register to point to the stack segment, with SP and BP as the stack pointer and base pointer respectively, which is used for function calls (mostly for interrupts).

### Addresses

Instructions use logical addresses through offsets (16 bytes), which are translated through physical addresses by: 

offset + selector * 2^4 (4 bits left shift), enabling 1mb of memory being accessed. 

The selector is chosen implicitly depending on the instruction.

With A20 disabled, it emulates the 8086 behavior where addresses wrap around at 1mb, so the address space is effectively 20 bits. With A20 enabled, it allows access to the full 1mb of memory without wrapping around (necessary for passing to protected mode).

## Procedures

On "far call" instructions:

1. Pushes the current CS and IP to the stack
2. Loads the new CS and IP from the instruction

On a "far return" instruction:

1. Pops the new IP and CS from the stack

## IVT (interrupt vector table)

The IVT is a table of 4 byte long entries located at address 0x0000 and UP TO 0x3FFH set by the BIOS. Each entry contains a pointer by a segment (2 bytes) and offset (2 bytes) for the interrupt handler. The interrupts just act like procedures but with extra flag steps:

1. PUSH CS and EIP to the stack
2. Pushes low 16 bits of EFLAGS to the stack
3. Clears IF flag to setup interrupts and other flags.
4. Transfers control to the handler by loading CS and EIP from the IVT entry.

## Protected mode 

## Sources

- https://wiki.osdev.org/Real_Mode
- https://wiki.osdev.org/Memory_Map_(x86)
- CHAPTER 15: 8086 emulation from https://pdos.csail.mit.edu/6.828/2008/readings/ia32/IA32-3A.pdf (surprisingly short) 
