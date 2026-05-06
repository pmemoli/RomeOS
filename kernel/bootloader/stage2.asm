; This stage is responsible for setting up long mode. Its tiny so it could fit into stage 1.

stage_2_entrypoint:
    mov ah, 0x0E    
    mov al, 'S' ; S for SUCCESS!     
    int 0x10

    ; Disable interrupts
    cli 

    ; Enables A20 line to not truncate physical addresses above 1 MiB
    mov ax, 0x2401
    int 0x15

    ; Sets up minimal kernel memory access structures

    ; segment structures (flat model)
    lgdt [gdt_descriptor] 

    ; paging structures

    ; Enables long mode bits and stuff

    ; Far jumps to long mode entry point (sets code segment)
    jmp CODE64_SEL:long_mode_start

BITS 64
long_mode:
    ; Set data segment register, and the rest to whatever
    mov ax, DATA64_SEL
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Here it should jump to kernel entry point
    jmp $

; GDT
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
    db 0b10010010 ; P=1 (1 bit), DPL=00 (2 bits), S=1 (1 bit), type=exec/read (4 bits)
    db 0b00000000 ; G=0 (1 bit, ignored), D=0 (1 bit, ignored), L=0 (1 bit), AVL=0 (1 bit), limit 19:16=0 (4 bits, ignored)
    db 0x00 ; base 31:24 (ignored in ia-32e)
gdt_end:

gdt_descriptor: ; [address | limit]
    dw gdt_end - gdt_start - 1 ; size of the GDT
    dq gdt_start ; address of the GDT

CODE64_SEL equ 0x08
DATA64_SEL equ 0x10
