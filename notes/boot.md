# Boot

We assume a BIOS-based system with an MBR partition scheme for the bootable disk for an x86-64 architecture with VGA compatibility for display (display is mapped at 0xA0000-0xBFFFF).

The MBR is 512 bytes and is structured like:

- 440 bytes: Bootloader code (446 bytes)
- 4 bytes: Disk signature
- 2 bytes: Unused
- 64 bytes: Partition table (4 entries of 16 bytes each)
- 2 bytes: Boot signature (0x55AA)

Each partition entry is 16 bytes and contains:

- 1 byte: Drive attributes (bit 7 set = active or bootable)
- 3 bytes: CHS address of partition start (legacy, assumes cylinders, heads, sectors)
- 1 byte: Partition type (fat, ntfs, etc.)
- 3 bytes: CHS address of last partition sector (legacy, assumes cylinders, heads, sectors)
- 4 bytes: LBA of partition start (logical block addressing, each block is 512 bytes)
- 4 bytes: Number of sectors in partition

Info from: 

- https://wiki.osdev.org/MBR_(x86)
- https://learning.lpi.org/en/learning-materials/101-500/101/101.2/101.2_01/

## What do IA32 processors do on startup?

Processor fetches and runs the first instruction from address 0xFFFFFFF0H, which is physically wired to the EPROM (ROM which contains the BIOS firmware). Then it begins running the BIOS firmware.

## BIOS

The BIOS is firmware that initializes the hardware and provides basic input/output services. It does the following:

1. The POST (power-on self-test) to check that the hardware works.
2. Initializes basic hardware components (like the keyboard, display, etc.). 
3. Sets up real mode IDT on physical address for bios functions, which uses BDA and EBDA for data storage.
3. Loads the MBR (master boot record) from the first sector of the bootable disk into memory at address 0x7C00, and jumps to it.

The BIOS finds and loads the MBR at address 0x7C00 for the first disk with 0x55AA at the end of MBR, then jumps to it.

The physical address space (<1MB) of the processor after the BIOS gives control to the MBR looks like (wtf there are 0 sources in the wiki):

https://wiki.osdev.org/Memory_Map_(x86)

The only really important things to note from systems programming are:

1. Moves and cedes control to the MBR at 0x7C00, where 440 bytes contain the bootloader code and the rest partition table info.
2. Provides BIOS interrupts for basic input/output services through the IVT at address 0x00000000 that can be run with simple INT instructions.

## Our bootloader

We'll use a *double stage bootloader* where the first stage fits within the first 440 bytes of the MBR, and the other loads the kernel. Actual systems will use GRUB (gnu project bootloader) for their specific boot firmware and architecture, and probably use UEFI.
