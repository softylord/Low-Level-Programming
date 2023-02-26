assume cs: code, ds: data

data segment
string1 db 0Ah, '$'
string2 db 100, 99 dup (0)
string3 db 100, 99 dup (0)
data ends

code segment
strcmp proc
	push bp
	mov bp, sp
	
	str1 equ [bp+6]
    str2 equ [bp+4]
    
    mov si, offset str1
    mov cl, [si]
	inc si

    mov di, offset str2
    inc di
    xor ax, ax
    copy:
        cmpsb
        jl lower
        jg bigger
		
    loop copy
    mov ax, 8
    jmp res
    lower:
        mov ax, 5
        jmp res
    bigger:
        mov ax, 1
        jmp res
    res:
    mov dx, ax
	pop bp
	pop bx
	push dx
	push bx
	ret
strcmp endp


start:	mov ax, data
		mov ds, ax
		mov es, ax

		mov dx, offset string2
		mov ax, 0
		mov ah, 0Ah
		int 21h
		
		mov dx, offset string1
		mov ah, 09h
		int 21h
		
		mov dx, offset string2
		add dx, 1
		
		push dx

        mov dx, offset string3
		mov ax, 0
		mov ah, 0Ah
		int 21h
		
		mov dx, offset string1
		mov ah, 09h
		int 21h
		
		mov dx, offset string3
		add dx, 1
		
		push dx
		call strcmp
        xor dx, dx
		
		pop dx
        add dx, 30h
		mov ah, 09h
		int 21h

		mov ah, 4ch
		int 21h
		code ends
		end start