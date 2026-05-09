; This stage is responsible for setting up long mode.
BITS 16

extern kmain ; defined in kmain.c
global stage_2_entrypoint

stage_2_entrypoint:
    ; Disable interrupts
    cli 

    ; Enables A20 line to not truncate physical addresses above 1 MiB
    mov ax, 0x2401
    int 0x15

    ; VGA 0x13 mode
    mov ax, 0x0013
    int 0x10

    ; Segment structures (flat model)
    lgdt [gdt_descriptor] 

    ; Paging structures (identity mapping of first 2 MiB)
    mov edi, PML4 ; destination
    mov ecx, 3*0x1000/4 ; repetitions
    xor eax, eax ; value to write
    rep stosd ; sets PML4, PDPT, PD to 0

    mov eax, PDPT
    or eax, PAGE_WRITE | PAGE_PRESENT
    mov [PML4], eax

    mov eax, PD
    or eax, PAGE_WRITE | PAGE_PRESENT
    mov [PDPT], eax

    mov eax, 0
    or eax, PAGE_WRITE | PAGE_PRESENT | PAGE_LARGE_SIZE
    mov [PD], eax

    ; Set cr4 to set the ia-32e 4 table paging mode
    mov eax, 10100000b ; PAE = 1, LA57 = 0, PGE=1 (extended paging with global pages)
    mov cr4, eax

    mov ecx, 0xC0000080 ; EFER MSR address  
    rdmsr ; read current EFER into EDX:EAX               
    or eax, LME ; set LME bit (bit 8)      
    wrmsr ; Write it back

    ; Set cr3 to point to the PML
    mov eax, PML4
    mov cr3, eax

    ; Enable paging and protection at the same time
    mov eax, cr0
    or eax, CR0_PE | CR0_PG
    mov cr0, eax

    ; Far jumps to long mode entry point (sets code segment)
    jmp CODE64_SEL:long_mode_entrypoint

BITS 64
long_mode_entrypoint:
    ; Set data segment register, and the rest to whatever
    mov ax, DATA64_SEL
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    jmp kmain

align 8
gdt_start:
    ; null segment (8 null bytes)
    dq 0 

    ; code segment base=0, limit=0, type=exec/read, L=1, DB=0, G=1
    dw 0x0000 ; limit 15:0 (ignored in ia-32e)
    dw 0x0000 ; base 15:0 (ignored in ia-32e)
    db 0x00 ; base 23:16 (ignored in ia-32e)
    db 0b10011010 ; P=1 (1 bit), DPL=00 (2 bits), S=1 (1 bit), type=exec/read (4 bits)
    db 0b10100000 ; G=1 (1 bit, ignored), D=0 (1 bit), L=1 (1 bit), AVL=0 (1 bit), limit 19:16=0 (4 bits, ignored)
    db 0x00 ; base 31:24 (ignored in ia-32e)

    ; data segment base=0, limit=0, type=read/write, L=0, DB=1, G=1
    dw 0x0000 ; limit 15:0 (ignored in ia-32e)
    dw 0x0000 ; base 15:0 (ignored in ia-32e)
    db 0x00 ; base 23:16 (ignored in ia-32e)
    db 0b10010010 ; P=1 (1 bit), DPL=00 (2 bits), S=1 (1 bit), type=read/write (4 bits)
    db 0b00000000 ; G=0 (1 bit, ignored), D=0 (1 bit, ignored), L=0 (1 bit), AVL=0 (1 bit), limit 19:16=0 (4 bits, ignored)
    db 0x00 ; base 31:24 (ignored in ia-32e)
gdt_end:

gdt_descriptor: ; [address | limit]
    dw gdt_end - gdt_start - 1 ; size of the GDT
    dq gdt_start ; address of the GDT

CODE64_SEL equ 0x08
DATA64_SEL equ 0x10

; Paging control bits
PAGE_PRESENT equ (1 << 0)
PAGE_WRITE equ (1 << 1)
PAGE_LARGE_SIZE equ (1 << 7) ; defines if page directories map 2mb pages instead of page tables

LME equ (1 << 8)

CR0_PE equ (1 << 0)
CR0_PG equ (1 << 31)

; Page table addresses
PML4 equ 0x1000
PDPT equ 0x2000
PD equ 0x3000
