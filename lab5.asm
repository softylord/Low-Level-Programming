assume cs: code, ds: data

data segment
	dummy db 0Dh, 0Ah, '$'
	str1 db 100, 99 dup ('$')
	str2 db 100, 99 dup ('$')
    symb1 db 4, 3 dup ('$')
    symb2 db 4, 3 dup ('$')
    temp db ?
    flag db 0
data ends

;вариант 11:
;Задана строка слов. Слово – последовательность знаков без пробелов.
;Заменить в строке слова, начинающиеся с заданного символа, другим
;заданным символом.

code segment
include llp\macro.asm ;у меня все файлы asm лежат в папке llp
start:
	mov ax, data
	mov ds, ax
	mov ax, 0
	
	inputStr str1
    inputStr symb1
    inputStr symb2
	wordChange str1	
	printStr str2
	exit				
	
code ends
end start