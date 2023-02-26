assume cs: code, ds: data

data segment
string1 db 0Ah, '$'
string2 db 100, 99 dup (0)
string3 db 100, 99 dup (0)
data ends

code segment
strcpy proc
	push bp
	mov bp, sp
	
	str1 equ [bp+4]
    str2 equ [bp+6]
    
    mov si, offset str1
    mov cl, [si]
	inc si

    mov di, offset str2
    copy:
        
		movsb
    loop copy
    mov dx, str2
    mov ah, 09h
	int 21h
	
	mov ax, offset str2
	pop bp
	pop bx
	push ax
	push bx
	ret
strcpy endp


start:	mov ax, data
		mov ds, ax
		mov es, ax

        
        mov dx, offset string3
        push dx

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
		call strcpy
		
		pop dx
		mov ah, 09h
		int 21h

		mov ah, 4ch
		int 21h
		code ends
		end start