# IA-32e

## Registers

## Memory access

Physical memory accesses pass through two units, segmentation and paging in that order. In practice, segmentation is often disabled by setting up the GDT with flat segments, so paging is the only mechanism for memory access control. Programs use logical addresses, which are translated to linear addresses through segmentation, and then to physical addresses through paging. 

The flow to translate an logical address to a physical address is as follows:

1. Find the index field in the segment selector (upper 13 bits), and use it to index into the GDT to get the segment descriptor.
2. Add the offset to the base address in the segment descriptor to get the linear address.
3. Use the linear address to index into the page structures and page table to get the physical address.

### Segment selector

The segment selector is a 16 bit value within a segment register that points to a segment descriptor in the GDT.

There are 6 relevant segment registers: CS, DS, ES, FS, GS, and SS. The most important ones are CS (code segment), SS (stack segment), and DS (data segment). 

### GDT (global descriptor table)

The GDT is a table that contains segment descriptors. Each descriptor contains the base address, limit, and access rights for a segment. All memory accesses go through the gdt to obtain the corresponding linear address. The GDT is loaded into the GDTR register, which contains the base address and limit of the GDT.

Each entry is 8 bytes long.

#### Format of the GDTR

| Bits  | Description                          |
| 79:16 | Base address of the GDT              |
| 15:0  | Limit of the GDT (size in bytes - 1) |

#### Format of the GDT entry (segment descriptor)

Can be properly found in the intel manual volume 3a, section 3.4.5. Point is that on CS/DS/ES/SS, in IA-32e when L = 1, the base is 0 and the limit is essentially ignored. What matters are access writes and segment type bits.

#### Paging

## Interrupts

## Tasks
