;run.asm
jmp start

out_seg equ 0x800
dpt_seg equ 0x7e0
gdt_descriptior dw 32-1     ;GDT 表的大小 ;（总字节数减一）
                dd 0x00007e00 ;GDT的物理地址

start:
    mov ax,out_seg
    mov ds,ax
    mov ax,dpt_seg
    mov es,ax
    ;创建gdt
    ;空描述符，这是处理器神奇（SB）的要求 gdt_null
    mov dword [es:0x00],0x00
    mov dword [es:0x04],0x00
    ;代码段描述符 gdt_code
    mov dword [es:0x08],0x8000ffff
    mov dword [es:0x0c],0x00409800
    ;数据段描述符 gdt_data
    mov dword [es:0x10],0x0000ffff  ;（把DS的基地址定义为0）
    mov dword [es:0x14],0x00c09200  ; (标志位G=1,表示以4KB为单位)
    ;堆栈段描述符 gdt_stack
    mov dword [es:0x18],0x00007a00
    mov dword [es:0x1c],0x00409600
    ;将gdt位置、大小写入gdtr生效
    lgdt [gdt_descriptior]
    ;关闭中断
    cli
    ;打开A20
    in al,0x92
    or al,0000_0010b
    out 0x92,al
    ;保护模式开关
    mov eax,cr0
    or eax,1
    mov cr0,eax
    ;保护模式跳转
    jmp dword 08h:PM
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
[bits 32]
PM:
    ;在屏幕上显示"Protect mode",验证保护模式下的数据段设置正确
    mov ax,00000000000_10_000B ;加载数据段选择子(0x10)
    mov ds,ax

    mov byte [0xb8000+20*160+0x00],'P'  ;屏幕第20行开始显示
    mov byte [0xb8000+20*160+0x01],0x0c
    mov byte [0xb8000+20*160+0x02],'R'
    mov byte [0xb8000+20*160+0x03],0x0c
    mov byte [0xb8000+20*160+0x04],'O'
    mov byte [0xb8000+20*160+0x05],0x0c
    mov byte [0xb8000+20*160+0x06],'T'
    mov byte [0xb8000+20*160+0x07],0x0c
    mov byte [0xb8000+20*160+0x08],'E'
    mov byte [0xb8000+20*160+0x09],0x0c
    mov byte [0xb8000+20*160+0x0a],'C'
    mov byte [0xb8000+20*160+0x0b],0x0c
    mov byte [0xb8000+20*160+0x0c],'T'
    mov byte [0xb8000+20*160+0x0d],0x0c
    mov byte [0xb8000+20*160+0x0e],'-'
    mov byte [0xb8000+20*160+0x0f],0x0c
    mov byte [0xb8000+20*160+0x10],'M'
    mov byte [0xb8000+20*160+0x11],0x0c
    mov byte [0xb8000+20*160+0x12],'O'
    mov byte [0xb8000+20*160+0x13],0x0c
    mov byte [0xb8000+20*160+0x14],'D'
    mov byte [0xb8000+20*160+0x15],0x0c
    mov byte [0xb8000+20*160+0x16],'E'
    mov byte [0xb8000+20*160+0x17],0x0c
    mov byte [0xb8000+20*160+0x18],' '
    mov byte [0xb8000+20*160+0x19],0x0c
    mov byte [0xb8000+20*160+0x1a],'!'
    mov byte [0xb8000+20*160+0x1b],0x0c
    mov byte [0xb8000+20*160+0x1c],'!'
    mov byte [0xb8000+20*160+0x1d],0x0c
    mov byte [0xb8000+20*160+0x1e],'!'
    mov byte [0xb8000+20*160+0x1f],0x0c

    ;通过堆栈操作,验证保护模式下的堆栈段设置正确
    mov ax,00000000000_11_000B ;加载堆栈段选择子
    mov ss,ax                  ;7a00-7c00为此次设计的堆栈区
    mov esp,0x7c00             ;7c00固定地址为栈底，
                               ;7a00为栈顶的最低地址（通过载堆栈段选择子的段界限值设置）
    mov  ebp,esp ;保存堆栈指针
    push byte '#' ;压入立即数#（字节）后，执行push指令，esp会自动减4

    sub ebp,4

    cmp ebp,esp ;判断ESP是否减4
    jnz Pover    ;如果堆栈工作正常则打印出pop出来的值和其它字符

    pop eax

    mov byte [0xb8000+22*160+0x00],'S'
    mov byte [0xb8000+22*160+0x01],0x0c
    mov byte [0xb8000+22*160+0x02],'t'
    mov byte [0xb8000+22*160+0x03],0x0c
    mov byte [0xb8000+22*160+0x04],'a'
    mov byte [0xb8000+22*160+0x05],0x0c
    mov byte [0xb8000+22*160+0x06],'c'
    mov byte [0xb8000+22*160+0x07],0x0c
    mov byte [0xb8000+22*160+0x08],'k'
    mov byte [0xb8000+22*160+0x09],0x0c
    mov byte [0xb8000+22*160+0x0a],':'
    mov byte [0xb8000+22*160+0x0b],0x0c
    mov byte [0xb8000+22*160+0x0c],al     ;打印出pop出来的值
    mov byte [0xb8000+22*160+0x0d],0x0c
    mov byte [0xb8000+22*160+0x0e],','
    mov byte [0xb8000+22*160+0x0f],0x0c
    mov byte [0xb8000+22*160+0x10],'O'
    mov byte [0xb8000+22*160+0x11],0x0c
    mov byte [0xb8000+22*160+0x12],'K'
    mov byte [0xb8000+22*160+0x13],0x0c
    mov byte [0xb8000+22*160+0x14],'!'
    mov byte [0xb8000+22*160+0x15],0x0c

Pover :
    jmp $