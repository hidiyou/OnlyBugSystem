ALL: OS.bin

OS.bin: mbr.o run.o
	cat mbr.o>OS.bin
	cat run.o>>OS.bin
	make clean
mbr.o: mbr.asm
	nasm -o mbr.o mbr.asm
run.o: run.asm
	nasm -o run.o run.asm
clean:
	rm *.o