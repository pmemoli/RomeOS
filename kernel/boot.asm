; print hello world
mov ah, 0x0e ; teletype output
mov al, 'x'
int 0x10 ; BIOS video interrupt

mov ah, 0x0e ; teletype output
mov al, 'd'
int 0x10 ; BIOS video interrupt

jmp $ 

; Complete the MBR with 0s and the boot signature
times 510-($-$$) db 0
db 0x55, 0xAA
