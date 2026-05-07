; 512 bytes exactly
stage_1_start:
    %include "kernel/bootloader/stage1.asm"
stage_1_end:

; Some 512 bytes multiple, stage 2 can be ~480 kB before it starts eating EBDA
stage_2_start:
    %include "kernel/bootloader/stage2.asm"
    align 512, db 0
stage_2_end:
