# Booting

We assume a BIOS-based system with an MBR partition scheme for the bootable disk for an x86-64 architecture. The MBR is 512 bytes and is structured like:

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

The BIOS finds and loads the MBR at address 0x7C00 for the first disk with 0x55AA at the end of MBR, then jumps to it.

We use a *double stage bootloader* where the first stage fits within the first 440 bytes of the MBR, and the other loads the kernel. Actual systems will use GRUB (gnu project bootloader) for their specific boot firmware and architecture.
