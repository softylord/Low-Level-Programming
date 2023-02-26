assume cs: code, ds: data

data segment
dummy db 0Ah, '$'
string1 db 100, 99 dup ('$')
string2 db 100, 99 dup ('$')
res db 100, 99 dup ('$')
dop db 100, 99 dup (0)
base db 10
len1 db ? 
len2 db ?
count1 db ?
count2 db ?
shift db 0
dii dw 0
ost db 0
flag db 1
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

big_mul proc
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
	inc flag
	inc si
	dec len1
	uns:
	mov cl, [di]
	mov len2, cl
	inc di
	mov al, [di]
	cmp al, '-'
	jne uns1
	dec flag
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
	
	jmp mull
	
	erro:
		xor ax, ax
		mov si, offset errstr
		jmp oout

	mull:
	dec si
	dec di
	mov dii, di
	mov al, len1
	mov bl, len2
	mov count2, bl
	;cmp al, bl
	;jl less
		;len1>=len2
	mov cl, len1
	xor ax, ax
	xor bx, bx
	;mov dop[1], 1
	inc dx

	l3:
		mov count1, cl
		mov cl, count2
		mov bl, len2
		mov di, dii
		l4:
		
			mov bl, len1
			sub bl, count1
			add bl, len2
			sub bl, cl
			mov shift, bl
			mov bl, dl
			mov bh, shift
			cmp bh, bl
			jl notinc
			inc dx
			notinc:
			xor ax, ax
			xor bx, bx
			mov al, [si]
			mov bl, [di]
			mul bl
			add al, ost
			div base
			mov bl, shift
			inc bl
			add dop[bx], ah
			mov ost, al
			xor ax, ax
			mov al, dop[bx]
			div base
			mov dop[bx], ah
			inc bx
			cmp al, 0
			je loo1
			dec bx
			mov dop[bx], ah
			inc bx
			cmp bl, dl
			jle notinc2
			inc dx
			notinc2:
			;mov bl, dl
			add dop[bx], al
			loo1:
			dec di
		loop l4
		mov cl, count1
		mov al, ost
		mov ost, 0	
		cmp al, 0
		je loo
		;inc bx
		cmp bl, dl
		jle notinc3
		inc dx
		notinc3:
		;mov bx, dx
		add dop[bx], al
		xor ax, ax
		loo:
		dec si 	
	dec cx
	cmp cl, 0
	je next 
	jmp l3
	
	next:
	cmp al, 0
	je ennd
	inc dx
	mov bx, dx
	;dec bx
	;add bl, 2
	mov dop[bx], al
	;mov dop[1], dl

	ennd:
		mov cx, dx
		mov si, offset res
		mov bx, dx
        mov al, flag
        cmp al, 1
        je l5
        mov al, '-'
        mov [si], al
        inc si
		
		l5:
			mov al, dop[bx]
			add al, 30h
			mov [si], al
			inc si
			dec bx
		loop l5

		mov si, offset res

	
	oout:
		pop bp
		pop bx
		push si
		push bx
		ret
big_mul endp


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

		call big_mul
		pop dx

		mov ah, 09h
		int 21h

		mov ah, 4ch
		int 21h
		code ends
		end start