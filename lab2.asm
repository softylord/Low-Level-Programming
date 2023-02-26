assume CS:code,DS:data

data segment
x dw 3
res dw 0
arr dw 1,9,2,1
n db ($-arr)/2
s db ?, '$'
data ends

code segment
start:
mov AX, data
mov DS, AX
mov AH, 0

mov di, offset s

mov cx, n
;mov bx,x
mov bx, 0



counter: 
mov ax, arr[si]
cmp ax, x 
jg local_1
dec bx

local_1:
inc bx
;inc si
add si, 2
xor ax, ax
loop counter

mov res, bx
mov ax, res
add ax, 30h
mov [di], al

mov dx, offset s
mov ah, 09h
int 21h

mov AX,4C00h
int 21h
code ends
end start

