assume cs: code, ds: data

data segment
dummy db 0Ah, '$'
string1 db 100, 99 dup ('$')
string2 db 100, 99 dup ('$')
res db 100, 99 dup ('$')
base db 10
len1 db ? 
len2 db ?
c db ?
count db 0
carry db 0
errstr db "error$"
data ends

code segment

strinput proc
	mov ah, 0Ah
	int 21h
	
	mov dx, offset dummy
	mov ah, 09h
	int 21h
	ret
strinput endp

big_sub proc
	push bp
	mov bp, sp
	
	str2 equ [bp+4]
    str1 equ [bp+6]
	xor dx, dx
    
    mov si, offset str1
    ;mov len1, [si]
	mov cl, [si]
	mov len1, cl
	inc si

	
	l1: 
		xor ax, ax
		mov al, [si]
		cmp al, 30h
		jl erro
		cmp al, 39h
		jg erro
		sub  al, 30h
		mov [si], al
		inc si
	loop l1

    mov di, offset str2
	mov cl, [di]
	mov len2, cl
	inc di

	l2:
		xor ax, ax
		mov al, [di]
		cmp al, 30h
		jl erro
		cmp al, 39h
		jg erro
		sub  al, 30h
		mov [di], al
		inc di
	loop l2
	
	jmp minus
	
	erro:
		xor ax, ax
		mov si, offset errstr
		jmp oout

	minus:
	dec si
	dec di
	mov al, len1
	mov bl, len2
	cmp al, bl
	jl erro
		;len1>=len2
	mov cl, bl
	xor ax, ax
	xor bx, bx

	l31:
		inc dx
		mov al, [si]
		mov bl, [di]
		cmp al, bl
		jge ok
		repet:
		dec si
		mov al, [si]
		cmp al,0
		jne borrow
		inc count
		mov al, 9
		mov [si], al
		jmp repet
		borrow:
		dec al
		mov [si], al
		mov carry, cl
		mov cl, count
		loo:
		inc si
		loop loo
		mov cl, carry
		inc si
		mov al, [si]
		add al, base
		ok:
		sub al, bl
		;div base
		;mov bl, ah
		;mov ah, 0
		push ax
		dec si
		dec di
	loop l31

	xor bx, bx
	mov bl, len1
	sub bl, len2
	mov cl, bl
	cmp cl, 0
	je ennd

	
	rest1:
		mov al, [si]
		cmp al, 0
		jne notnul
		cmp cl, 1
		je ennd
		notnul:
		push ax
		inc dx
		dec si
	loop rest1


	ennd:
		mov cx, dx
		mov si, offset res
		l5:
			pop ax
			add al, 30h
			mov [si], al
			inc si
		loop l5

		mov si, offset res

	
	oout:
		pop bp
		pop bx
		push si
		push bx
		ret
big_sub endp


start:	mov ax, data
		mov ds, ax
		mov es, ax

        mov dx, offset string1
		call strinput
		
		mov dx, offset string1
		inc dx
		push dx
		
		mov dx, offset string2
		call strinput
		
		mov dx, offset string2
		inc dx
		push dx

		call big_sub
		pop dx

		mov ah, 09h
		int 21h

		mov ah, 4ch
		int 21h
		code ends
		end start