; 512 bytes exactly
stage_1_start:
    %include "kernel/bootloader/stage1.asm"
stage_1_end:

; Some 512 bytes multiple
stage_2_start:
    %include "kernel/bootloader/stage2.asm"
    align 512, db 0
stage_2_end:
