ALL:OS.bin : mbr.o run.o
    cat mbr.o>OS.bin
    cat run.o>>OS.bin
mbr.o : mbr.asm
    nasm -o mbr.o mbr.asm
run.o : run.asm
    nasm -o run.o run.asm
    