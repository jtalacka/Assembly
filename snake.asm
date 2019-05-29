.MODEL medium
.STACK 200H
.DATA
x dw 500 dup(0)
y dw 500 dup(0)
ilgis dw 5
z db 00100b
rx dw 0
ry dw 0
count db 0
erase db 00000b
direction db 1
du db 2
back dw 0
time dw 0
ballx dw 160
bally dw 120
ballx1 dw 160
bally1 dw 121
ballx2 dw 161
bally2 dw 120
ballx3 dw 161
bally3 dw 121
ballc db 01010b

.CODE
START:
mov ax,@data
mov ds,ax

mov bx,0
mov ax, 0013h
int 10h
mov bl,0
mov si,0
mov x[1],160
mov y[1],100
mov x[0],160
mov y[0],100


mov ah,0ch
mov bx,110
mov si,0

ring:
mov ah, 0ch

mov al, 00001b
mov cx, bx
mov dx, 50
int 10h ;set pixel.
mov dx, 150
int 10h ;set pixel.
inc bx
inc si
cmp si,100
jne ring

mov bx,50
mov si,0
ringy:
mov ah, 0ch

mov al, 00001b
mov cx, 110
mov dx, bx
int 10h ;set pixel.
mov cx, 210
int 10h ;set pixel.
inc bx
inc si
cmp si,100
jne ringy


jump:


mov ah,1h
int 16h
jnz key
cmp direction,0
mov si,0
mov di,0
jne cha
jmp jump

key:
mov ah,0h
int 16h
cmp al,77h ;up
je up
cmp al,73h ;down
je down
cmp al,61h ;left
je left
cmp al,64h ;right
je right
cmp al,20h ;stop
je space
cmp al,0Dh
je ent
jmp jump

up:
cmp direction,2
je jump
mov direction,1
jmp jump
down:
cmp direction,1
je jump
mov direction,2
jmp jump
left:
cmp direction,4
je jump
mov direction,3
jmp jump
right:
cmp direction,3
je jump
mov direction,4
jmp jump



space:
mov ax, 4c00h
int 21h

ent:
inc z
inc ilgis
jmp jump
temp:
 jmp jump


cha:

mov dx,ilgis
add dx,ilgis
sub dx,2
mov back,dx
mov bx,offset x
add bx,back
mov cx,[bx]
mov rx,cx

mov bx,offset y
add bx,back
mov cx,[bx]
mov ry,cx

mov cx,ilgis
mov si,back



change:
mov bx,offset x
sub si,2
mov dx,[bx+si]
add si,2
mov [bx+si],dx

mov bx,offset y
sub si,2
mov dx,[bx+si]
add si,2
mov [bx+si],dx

cmp cx,1
dec cx
dec si
dec si
jne change


mov si,0
mov di,0

cmp direction,1
je diru
cmp direction,2
je dird
cmp direction,3
je dirl
cmp direction,4
je dirr
jmp temp
diru:
dec y[0]
jmp check
dird:
inc y[0]
jmp check
dirl:
dec x[0]
jmp check
dirr:
inc x[0]
jmp check
check:

mov ax,x[0]
cmp ax,209
ja xnul
mov ax,x[0]
cmp ax,111
jb xmax
mov ax,y[0]
cmp ax,149
ja ynul
mov ax,y[0]
cmp ax,51
jb ymax

jmp draw
xnul:
mov x[0],111;209
jmp draw
xmax:
mov x[0],209;111
jmp draw
ynul:
mov y[0],51;149
jmp draw
ymax:
mov y[0],149;51
jmp draw




draw:



mov ah, 0ch
mov al, erase
mov cx, rx
mov dx, ry
int 10h ;set pixel.

mov al, ballc
mov cx, ballx
mov dx, bally
int 10h ;set pixel.


mov ah, 0ch
mov al, z
mov bx,offset x
mov cx, [bx+si]
mov bx,offset y
mov dx, [bx+si]
int 10h ;set pixel.
inc si
inc si
inc di
cmp di,ilgis
jne draw

mov DI,1
mov ah,0
int 1ah
mov bx,dx
Delay:
mov ah,0
int 1ah
sub dx,bx
cmp di,dx
ja delay

mov dx,x[0]
cmp dx,ballx
je ball
;cmp dx,ballx1
;je ball
;cmp dx,ballx2
;je ball
;cmp dx,ballx3
;je ball
jmp temp
ball:
mov dx,y[0]
cmp dx,bally
je ball1
;cmp dx,bally1
;je ball1
;cmp dx,bally2
;je ball1
;cmp dx,bally3
;je ball1

jmp temp
ball1:

inc ilgis
mov ax,2c00h
int 21h
mov dh,00
add dx,110
cmp dx,209
ja retreatx
backx:
mov ballx,dx
;mov ballx1,dx
;inc dx
;mov ballx2,dx
;mov ballx3,dx
sub dx,110
add dx,52
cmp dx,149
ja retreaty
backy:
mov bally,dx
;mov bally2,dx
;inc dx
;mov bally1,dx
;mov bally3,dx
jmp temp
retreatx:
sub dx,10
jmp backx
retreaty:
sub dx,10
jmp backy

mov ax, 4c00h
int 21h

END START
 
