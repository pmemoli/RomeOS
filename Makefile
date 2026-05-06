os.bin:
	nasm -f bin ./kernel/os.asm -o os.bin

run: os.bin
	qemu-system-x86_64 -drive format=raw,file=os.bin
	rm -f os.bin

clean:
	rm *.bin

.PHONY: run clean
