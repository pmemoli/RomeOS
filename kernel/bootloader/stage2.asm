; This stage is responsible for setting up 

stage_2_entrypoint:
    mov ah, 0x0E    
    mov al, 'S' ; S for SUCCESS!     
    int 0x10

    ; Disable interrupts
    cli 

    ; Enables A20 line to not truncate physical addresses above 1 MiB
    mov ax, 0x2401
    int 0x15

    ; Sets up paging (gdt and paging structures)
    lgdt [gdt_descriptor]

    ; Enables long mode

    ; Jumps to long mode entry point (resets code segment)
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
