SECTIONS {
    . = 0x7C00;

    .stage1 : { stage1.o(.text) }
    .stage2 : { stage2.o(.text) }
    . = ALIGN(512);

    .text   : { *(.text*) }
    .rodata : { *(.rodata*) }
    .data   : { *(.data*) }
    .bss    : { *(.bss*) }
}
