assume CS:code,DS:data

data segment
a db 3
b db 2
c db 7
d db 24
res db ?
s db ?, ?, ?,  ?, '$'
data ends
;a*b*c+d/8-3
;теперь результат 42

code segment
start:
mov AX, data
mov DS, AX
mov AH, 0

mov al, a
mul b
mul c
mov res, al
mov al, d
mov bl, 8
div bl
mov ah, 0
add al, res
sub al, 3
;mov bl, res
;чтобы добыть символ цифры, надо к ней прибавить 30h

mov res, al
;mov al, res
mov bl, 10
div bl
mov al, ah
mov ah, 0
push ax
mov al, res
div bl
mov ah, 0
push ax

pop ax
add ax, 30h
mov di, offset s
mov [di], al
add di, 1
;mov ax, 0
pop ax
add ax, 30h
; mov di, offset s
mov [di], al

mov AX,4C00h
int 21h
code ends
end start