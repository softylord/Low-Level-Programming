inputStr macro strr
	lea dx, strr
	mov ah, 0Ah
	int 21h
	mov dx, offset dummy
	mov ah, 09h
	int 21h
endm

printStr macro st
	lea dx, st+2
	mov ah, 09h
	int 21h
endm

;вариант 11:
;Задана строка слов. Слово – последовательность знаков без пробелов.
;Заменить в строке слова, начинающиеся с заданного символа, другим
;заданным символом.
wordChange macro str
	lea si, str1+2
	lea di, str2+2
	mov bl, [symb1+2]
	mov dl, [symb2+2]
	firstsymb:
		mov al, [si]
		cmp al, bl
		jne noteq
		mov flag, 1
		jmp noteq
	somesymb:
		cmp flag, 0
		jne nex
		mov [di], al
		inc di
	nex:
		mov al, [si]
	noteq:
		inc si
		cmp al, 0Dh
		je endd
		cmp al, 32
		jne somesymb
		cmp flag, 1
		jne justword
		mov [di], dl
		mov flag, 0
		inc di
	justword:
		mov [di], al
		inc di
		jmp firstsymb
	endd:
		cmp flag,1 
		jne eend
		mov [di], dl
		mov flag, 0
	eend:
endm

exit macro
	mov ax, 4C00h
	int 21h
endm