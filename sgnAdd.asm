assume cs: code, ds: data

data segment
dummy db 0Ah, '$'
string1 db 100, 99 dup ('$')
string2 db 100, 99 dup ('$')
res db 100, 99 dup ('$')
base db 10
len1 db ? 
len2 db ?
a db 1
b db 0
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

big_add proc
	push bp
	mov bp, sp
	
	str2 equ [bp+4]
    str1 equ [bp+6]
	xor dx, dx
	xor ax, ax
    
    mov si, offset str1
	mov di, offset str2
	mov cl, [si]
	mov len1, cl
	inc si
	mov al, [si]
	cmp al, '-'
	jne uns
	inc a
	inc si
	dec len1
	uns:
	mov cl, [di]
	mov len2, cl
	inc di
	mov al, [di]
	cmp al, '-'
	jne uns1
	dec a
	inc di
	dec len2
	uns1:
    ;mov len1, [si]
	
	mov cl, len1

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

	;mov len2, [di]
	mov cl, len2

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

	dec si
	dec di
	
	mov al, len1
	mov bl, len2

	
	cmp a, 1
	je plus
	jmp minus
	
	erro:
		xor ax, ax
		mov si, offset errstr
		jmp oout

	plus:
	xor dx, dx
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
	je skip1
	push 1
	inc dx
	skip1:
	mov bl, [si]
	cmp bl, 2dh
	jne notmin
	push bx
	inc dx
	notmin:
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
		je skip2
		push 1
		inc dx
		skip2:
		mov bl, [di]
		cmp bl, 2dh
		jne notmin2
		push bx
		inc dx
		notmin2:
		jmp ennd

	minus:
		cmp ax, bx
		je equal
		jl lo
		jg gr
		equal:
		dec ax
		dec bx
		sub si, ax
		sub di, bx
		mov cl, len1
		comp:
			xor ax, ax
			xor bx, bx
			inc dx
			mov al, [si]
			mov bl, [di]
			inc si
			inc di
			cmp al, bl
			jl lo
			jg gr
		loop comp
		jmp next

		lo:
		mov b, 2
		cmp dx, 0
		je next
		mov al, len1
		sub ax, dx
		xor dx, dx
		dec ax
		add si, ax
		add di, ax
		jmp next

		gr:
		mov b, 1
		cmp dx, 0
		je next
		mov al, len1
		sub ax, dx
		xor dx, dx
		dec ax
		add si, ax
		add di, ax

		next:
		cmp a, 1
		jg minus1
		jmp minus2

	minus1:
		cmp b, 1
		jne notBIG1
		mov cl, len2
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
		je add_min

		rest3:
			mov al, [si]
			cmp al, 0
			jne notnul
			cmp cl, 1
			je add_min
			notnul:
			push ax
			inc dx
			dec si
		loop rest3
		
		add_min:
			inc dx
			mov ax, '-'
			push ax
		jmp ennd

		notBIG1:
			mov cl, len1
			xor ax, ax
			xor bx, bx

			l32:
				inc dx
				mov al, [di]
				mov bl, [si]
				cmp al, bl
				jge ok2
				repet2:
				dec di
				mov al, [di]
				cmp al,0
				jne borrow2
				inc count
				mov al, 9
				mov [di], al
				jmp repet2
				borrow2:
				dec al
				mov [di], al
				mov carry, cl
				mov cl, count
				loo2:
				inc di
				loop loo2
				mov cl, carry
				inc di
				mov al, [di]
				add al, base
				ok2:
				sub al, bl
				push ax
				dec si
				dec di
			loop l32

			xor bx, bx
			mov bl, len2
			sub bl, len1
			mov cl, bl
			cmp cl, 0
			je add_min2

			
			rest4:
				mov al, [di]
				cmp al, 0
				jne notnul2
				cmp cl, 1
				je add_min2
				notnul2:
				push ax
				inc dx
				dec di
			loop rest4
			add_min2:
			jmp ennd

	minus2:
		cmp b, 2
		jne notBIG2
		mov cl, len1
		xor ax, ax
		xor bx, bx

		l41:
			inc dx
			mov al, [di]
			mov bl, [si]
			cmp al, bl
			jge ok3
			repet3:
			dec di
			mov al, [di]
			cmp al,0
			jne borrow3
			inc count
			mov al, 9
			mov [di], al
			jmp repet3
			borrow3:
			dec al
			mov [di], al
			mov carry, cl
			mov cl, count
			loo3:
			inc di
			loop loo3
			mov cl, carry
			inc di
			mov al, [di]
			add al, base
			ok3:
			sub al, bl
			;div base
			;mov bl, ah
			;mov ah, 0
			push ax
			dec si
			dec di
		loop l41

		xor bx, bx
		mov bl, len2
		sub bl, len1
		mov cl, bl
		cmp cl, 0
		je add_min3
			
		rest5:
			mov al, [di]
			cmp al, 0
			jne notnul3
			cmp cl, 1
			je add_min3
			notnul3:
			push ax
			inc dx
			dec di
		loop rest5
		add_min3:
			inc dx
			mov ax, '-'
			push ax
		jmp ennd

		notBIG2:
			mov cl, len2
			xor ax, ax
			xor bx, bx

			l42:
				inc dx
				mov al, [si]
				mov bl, [di]
				cmp al, bl
				jge ok4
				repet4:
				dec si
				mov al, [si]
				cmp al,0
				jne borrow4
				inc count
				mov al, 9
				mov [si], al
				jmp repet4
				borrow4:
				dec al
				mov [si], al
				mov carry, cl
				mov cl, count
				loo4:
				inc si
				loop loo4
				mov cl, carry
				inc si
				mov al, [si]
				add al, base
				ok4:
				sub al, bl
				;div base
				;mov bl, ah
				;mov ah, 0
				push ax
				dec si
				dec di
			loop l42

			xor bx, bx
			mov bl, len1
			sub bl, len2
			mov cl, bl
			cmp cl, 0
			je add_min4

			
			rest6:
				mov al, [si]
				cmp al, 0
				jne notnul4
				cmp cl, 1
				je add_min4
				notnul4:
				push ax
				inc dx
				dec si
			loop rest6
			add_min4:
			jmp ennd


	ennd:
		mov cx, dx
		mov si, offset res
		l5:
			pop ax
			cmp al, 2dh
			je nonum
			add al, 30h
			nonum:
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