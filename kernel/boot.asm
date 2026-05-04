; Basically follows chapter 12.9 on the Intel manual (IDT and TSS set up by the kernel)

BITS 16 ; Tells nasm to generate 16-bit code
ORG 0x7c00 ; Code is loaded at this address

start:
    ; disables interrupts
    cli 

    ; sets all segment registers to 0 (except for cs which is forbidden)
    xor ax, ax
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; loads gdt
    lgdt [gdt_descriptor]

    ; set up paging (identity mapping first 4 MiB)

    ; sets up cr4.pae 
    mov eax, cr4
    or  eax, 1 << 5
    mov cr4, eax

    ; loads cr3
    mov eax, 0x1000
    
    ; Sets up cr0.pe and cr0.pg (protected mode and paging control bits)
    mov eax, cr0
    or  eax, (1 << 0) | (1 << 31)
    mov cr0, eax

    ; enters protected IA-32e mode
    jmp CODE64_SEL:long_mode_start

BITS 64
long_mode:
    ; resets segment registers for 64-bit mode
    mov ax, DATA64_SEL
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Here it should jump to kernel entry point, but for now we just loop infinitely
    jmp $

; GDT
align 8
gdt_start:
    ; null segment
    dq 0 

    ; code segment base=0, limit=0, type=exec/read, L=1, DB=0, G=1
    dq 0x00AF9A000000FFFF

    ; data segment base=0, limit=0, type=read/write, L=0, DB=1, G=1
    dq 0x00AF92000000FFFF 

gdt_end:

gdt_descriptor: ; [address | limit]
    dw gdt_end - gdt_start - 1 ; size of the GDT
    dq gdt_start ; address of the GDT

CODE64_SEL equ 0x08
DATA64_SEL equ 0x10

; Complete the MBR with 0s and the boot signature
times 510-($-$$) db 0
db 0x55, 0xAA

