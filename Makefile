# Generates an elf64 relocatable object file for the stage 1 of the bootloader 
stage1.o:
	nasm -f elf64 ./kernel/stage1.s -o stage1.o

# Generates an elf64 relocatable object file for the stage 2 of the bootloader 
stage2.o:
	nasm -f elf64 ./kernel/stage2.s -o stage2.o

# Generates an elf64 relocatable object file for the kernel
kmain.o:
	gcc -ffreestanding -nostdlib -fno-pie -mno-red-zone -c kernel/kmain.c -o kmain.o
	# -ffreestanding: no hosted libc
	# -nostdlib: don't link stdlibs
	# -mno-red-zone: required for kernel code; the SysV red zone breaks interrupt handlers.
	# -mcmodel=kernel: code/data live in the upper canonical half (>0xFFFFFFFF80000000).
	# -fno-pie: emit absolute addresses

# Links stage1 + stage2 + kernel via linker.ld, strips ELF headers
os.bin: stage1.o stage2.o kmain.o
	ld -T ./kernel/linker.ld -nostdlib -o kernel.elf stage1.o stage2.o kmain.o
	objcopy -O binary kernel.elf kernel.bin

# Runs the kernel.bin in qemu, and then cleans up the generated files
run: os.bin
	qemu-system-x86_64 -drive format=raw,file=kernel.bin
	$(MAKE) clean

clean:
	rm -f *.bin
	rm -f *.o
	rm -f *.elf

.PHONY: run clean
