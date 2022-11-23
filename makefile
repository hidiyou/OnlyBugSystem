#目录配置
OUTPUT = output
#防无用报错导致编译中断
RM = -rm -f
RMDIR = -rmdir
MKDIR = -mkdir

ALL: OS.bin
OS.bin: asm-mbr.o asm-run.o
	$(MKDIR) $(OUTPUT)
	cat asm-mbr.o>$(OUTPUT)/OS.bin
	cat asm-run.o>>$(OUTPUT)/OS.bin
asm-mbr.o: mbr.asm
	nasm -o asm-mbr.o mbr.asm
asm-run.o: run.asm
	nasm -o asm-run.o run.asm
cleanALL: clean cleanOutPut
clean:
	$(RM) ./*.o
cleanOutPut:
	$(RM) $(OUTPUT)/*
	$(RMDIR) $(OUTPUT)