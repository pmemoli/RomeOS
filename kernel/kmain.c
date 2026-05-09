#include <stdint.h>

// Mode 13h: 320×200 pixels, 1 byte each, 256 colors
#define VGA_BUFFER ((volatile uint8_t *)0xA0000)

int kmain(void) {
    for (int x = 0; x < 320; x++) {
        for (int y = 0; y < 200; y++) {
            VGA_BUFFER[x + 320 * y] = 30;
        }
    }

    while (1)
        ;

    return 0;
}
