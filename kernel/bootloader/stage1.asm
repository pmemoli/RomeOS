; Basically just loads stage 2 to bypass the 512 byte limit of the MBR

BITS 16 ; Tells nasm to generate 16-bit code
ORG 0x7C00 ; Code is loaded at this address

stage_1_entrypoint:
    ; sets all segment registers to 0 (except for cs which is forbidden)
    xor ax, ax
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; sets up the stack
    mov sp, 0x7C00 ; stack grows down from the start of this 

    ; loads stage 2 from disk (using LBA)
    mov [disk], dl ; store the boot drive number in case int clobbers it
    mov si, disk_address_packet ; recieves input from the dap pointer
    mov ah, 0x42
    int 0x13

    jmp stage_2_entrypoint ; Jump to stage 2 (now on memory)

disk_error:
    ; prints 'E' to indicate a disk error and halts the system 
    mov ah, 0x0E    
    mov al, 'E'     
    int 0x10
    jmp $

; Disk Address Packet for the LBA read
disk_address_packet:
    db 0x10 ; size of packet
    db 0 ; reserved
    dw (stage_2_end - stage_2_start) / 512 ; sector count
    dw stage_2_start ; destination offset
    dw 0 ; destination segment
    dq 1 ; starting LBA (sector 1)

disk: db 0 ; storage for the boot drive number

; Padding
times 510-($-$$) db 0 
db 0x55, 0xAA
