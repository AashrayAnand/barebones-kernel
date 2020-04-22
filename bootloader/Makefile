# create virtual floppy disk configured using
# FAT12 FS and place boot loader and second stage on it
FATFloppy: Boot1.bin Boot2.bin
	dd if=/dev/zero of=Floppy.flp bs=512 count=2879; \
	mkfs.fat ./Floppy.flp -f 2 -h 0 -i 0xa0a1a2a3 -I -n "AASHRAY OS" -r 224 -R 1 -S 512; \
	sudo mount -o loop ./Floppy.flp /media/floppy1/; \
	sudo cp Boot2.bin /media/floppy1/; \
	sudo umount /media/floppy1; \
	dd if=Boot1.bin of=Floppy.flp conv=notrunc status=noxfer;

Floppy: Boot1.bin Boot2.bin
	dd if=/dev/zero of=Floppy.flp bs=512 count=2879; \
	dd if=Boot1.bin of=Floppy.flp conv=notrunc status=noxfer; \
	dd if=Boot2.bin of=Floppy.flp conv=notrunc status=noxfer seek=1;

# create second stage bootloader binary from assembly
Boot2.bin:
	nasm -f bin Boot2.asm -o Boot2.bin
	
# create bootloader binary from assembly
Boot1.bin: Boot1.asm
	nasm -f bin Boot1.asm -o Boot1.bin

# delete virtual floppy disk and bootloader binary
Clean:
	rm *.bin *.flp
