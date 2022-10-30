;mbr.asm
mbrSeg equ 0x7c0
_Seg equ 0x800
num_sector equ 4
num_header equ 0
num_cylind equ 0
jmp start
error db "System load error with code 0x0000",0

sector db 2
header db 0
cylind db 0
start:
    mov ax,mbrSeg
    mov ds,ax
    mov ax,_Seg
    mov es,ax
    call read_init
    call read
    jmp _Seg:0
print:
    mov al,[si]
    cmp al,0
    je over
    mov ah,0eh
    int 10h
    inc si
    jmp print
over:
    ret
read_init:
    mov ah,0
    mov dl,0
    int 13h
    ret
read:
    mov di,0
    call read1
    mov ax,es
    add ax,20h
    mov es,ax
    inc byte [sector]
    cmp byte [sector],num_sector+1
    jne read
    mov byte [sector],1
    inc byte [header]
    cmp byte [header],num_header+1
    jne read
    mov byte [header],0
    inc byte [cylind]
    cmp byte [cylind],num_cylind+1
    jne read
    ret
read1:
    mov ah,2
    mov al,1
    mov bx,0
    mov ch,[cylind]
    mov dh,[header]
    mov cl,[sector]
    mov dl,0
    int 13h
    jnc readOk
        inc di
        call read_init 
        cmp di,5
        jne read1
            mov si,error
            call print
            jmp $
readOk:
    ret

times 510-($-$$) db 0
db 0x55,0xaa