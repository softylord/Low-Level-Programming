assume cs: code, ds: data

data segment
dummy db 0Ah, '$'
string1 db 100, 99 dup ('$')
string2 db 100, 99 dup ('$')
res db 100, 99 dup ('$')
base db 10
len1 db ? 
len2 db ?
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

big_add proc
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
	;mov len2, [di]
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
	
	jmp plus
	
	erro:
		xor ax, ax
		mov si, offset errstr
		jmp oout

	plus:
	dec si
	dec di
	mov al, len1
	mov bl, len2
	cmp al, bl
	jl less
		;len1>=len2
	mov cl, bl
	xor ax, ax
	xor bx, bx

	l3:
		add al, [si]
		add al, [di]
		inc dx
		div base
		mov bl, ah
		mov ah, 0
		push bx
		dec si
		dec di
	loop l3

	xor bx, bx
	mov bl, len1
	sub bl, len2
	mov cl, bl
	cmp cl, 0
	je h1
	
	rest1:
		add al, [si]
		div base
		mov bl, ah
		mov ah, 0
		push bx
		inc dx
		dec si
	loop rest1

	h1:
	cmp al, 0
	je ennd
	push 1
	inc dx
	jmp ennd

	less:
		;len1<len2
		mov cl, len1
		xor ax, ax
		xor bx, bx
		l4:
			add al, [di]
			add al, [si]
			inc dx
			div base
			mov bl, ah
			mov ah, 0
			push bx
			dec si
			dec di
		loop l4
		xor bx, bx
		mov bl, len2
		sub bl, len1
		mov cl, bl
		cmp cl, 0
		je h2
		
		rest2:
			add al, [di]
			div base
			mov bl, ah
			mov ah, 0
			push bx
			inc dx
			dec di
		loop rest2
		
		h2:
		cmp al, 0
		je ennd
		push 1
		inc dx
		jmp ennd


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
big_add endp


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

		call big_add
		pop dx

		mov ah, 09h
		int 21h

		mov ah, 4ch
		int 21h
		code ends
		end start