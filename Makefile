boot.bin:
	nasm -f bin ./kernel/boot.asm -o boot.bin

run: boot.bin
	qemu-system-x86_64 -drive format=raw,file=boot.bin
	rm -f boot.bin

clean:
	rm -f boot.bin

.PHONY: run clean
