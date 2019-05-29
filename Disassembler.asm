.MODEL medium
.STACK 100H
.DATA
input db 15 dup(?)
inputhandle dw  0
output db 15 dup(?)
outputhandle dw 0
readbytes db 2 dup(?)
bytetobinary db 0
pagalbospran db 'Julius Talacka 1 kursas, trecia grupe',13,10,'dissassembler. Vercia masinini koda atgal i assembli kalba ','$'
d db 0
w db 0
@mod db 0
reg db 0
xy db,0
rm db 0
overall db 0
b db 0
atmintis db 0
newline db 13,10
place dw 0
segfunk db 0
pdydis db 0


ttbyte db 0,0
position dw 100h
poss db '0000   '

p0 db 'BX+SI+.'
p1 db 'BX+DI+.'
p2 db 'BP+SI+.'
p3 db 'BP+DI+.'
p4 db 'SI+.'
p5 db 'DI+.'
p6 db 'BP+.'
p7 db 'BX+.'
neatpazinta db 'Neatpazinta',10,13


s db 0
cmdplace dw 0
spacing db '            '
operandasdydis db 0

poslinkisdydis db 0


bytesread db 12 dup(?)
bytesreadnr dw 0
register db 4 dup(?)
command db 20 dup(?)
cmdcount dw 0
poslinkis db 10 dup(?)
operandas db 8 dup(?)

segreg dw 'se','sc','SS','sd',''
segr dw 0
byteregister dw 'LA','LC','LD','LB','HA','HC','HD','HB'
wordregister dw 'XA','XC','XD','XB', "PS" ,"PB","IS","ID"
wordcommand db 'mov add push pop inc sub dec or adc sbb and sub xor cmp int loop test '
wordcommand2 db 'inc dec mul div push pop call ret jmp ret iret retf jo jno jb jae je jne jbe ja js jns jp jnp jl jge jle jg loop call jcxz '
;inc 0|dec 4|mul 8|div 12|push 16|pop 21|call 25|ret 29|jmp 33|ret 37|iret 41|retf 46
;jo 51| jno 54| jb 58| jae 61| je 65| jne 68| jbe 72| ja 76|js 79| jns 82| jp 86| jnp 89| jl 93| jge 96| jle 100| jg 104|loop 107|
;mov 0|add 4|push 8|pop 13|inc 17|sub 21|dec 25| or 29|adc 32|sbb 36|and 40|sub 44|xor|48|cmp 52| 56 int|loop 60|test 65

.CODE
start:
mov ax,@data

mov ds,ax

;/////////////////////////


    mov ch,0
    mov dl,0
	MOV	cl, es:[0080h]	
    cmp cl,0
    jne par
	jmp pagalba
	par:
    mov bx,0081h
    lea si,input

	inc bx
file1:    
    mov al,es:[bx]
    mov [si],al
	
	cmp es:[bx],'?/'
	je pagalba
	
    inc si
    inc bx
    inc pdydis	
	cmp pdydis,cl
        je pagalba
		mov al,es:[bx]
    cmp al,20h
        jne file1
		inc bx         
		inc pdydis
		mov byte ptr [si],0
		
    
    lea si,output
	
file2:
	mov al,es:[bx]
    mov [si],al
	
		cmp es:[bx],'?/'
	je pagalba
	
    inc si
    inc bx
    inc pdydis	
	cmp pdydis,cl
        je pagalba
		mov al,es:[bx]
    cmp al,0dh
        jne file2
	mov byte ptr [si],0
    inc pdydis
	cmp pdydis,cl
		jb pagalba
		
			jmp sk
	pagalba:
mov ax,0900h
lea dx,pagalbospran
int 21h
mov ax,4c00h
int 21h 

sk:
;/////////////////////////
add place,100h

mov ah,3dh
mov al,0h
lea dx,input
int 21h
jnc inskip1
jmp pagalba
inskip1:
;jc error
mov inputhandle,ax

mov ah,3ch
mov cx,00
lea dx,output
int 21h
jnc inskip
jmp pagalba
inskip:
mov outputhandle,ax



call read

en:
xor ax,ax
mov ah,3eh
mov bx,inputhandle
int 21h

xor ax,ax
mov ah,3eh
mov bx,outputhandle
int 21h

mov ax,4c00h
int 21h
;-------------------------------------------------------
readfile:
add position,1
xor ax,ax
mov ah,3fh
xor cx,cx
mov cx,1
xor bx,bx
mov bx,inputhandle
lea dx,readbytes
int 21h

call tohex
mov si,bytesreadnr
mov [bytesread+si],bh
inc si
mov [bytesread+si],bl
add bytesreadnr,2
cmp ax,0
jne skipax
jmp en
skipax:
ret

;------------------------------------------------------- ||||CONVERT
tohex:
mov di,ax
xor cx,cx
xor ax,ax
mov al,[readbytes]
mov cl,10h
div cl
mov bh,al
mov bl,ah

cmp bl,9h
jna tohex1
add bl,37h
jmp skiptohex1
tohex1:
add bl,30h
skiptohex1:

cmp bh,9h
jna tohex2
add bh,37h
jmp skiptohex2
tohex2:
add bh,30h
skiptohex2:
mov [readbytes],bh
mov [readbytes+1],bl
mov ax,di
ret
;-------------------------------------------------------
toposition:
xor cx,cx
mov ax,position
mov dx,ax
mov cl,10h
mov ah,0
div cl
mov bh,al
mov bl,ah

cmp bl,9h
jna topos1
add bl,37h
jmp skiptopos1
topos1:
add bl,30h
skiptopos1:

cmp bh,9h
jna topos2
add bh,37h
jmp skiptopos2
topos2:
add bh,30h
skiptopos2:
mov [poss+2],bh
mov [poss+3],bl

mov al,dh
mov cl,10h
mov ah,0
div cl
mov bh,al
mov bl,ah

cmp bl,9h
jna topos11
add bl,37h
jmp skiptopos11
topos11:
add bl,30h
skiptopos11:

cmp bh,9h
jna topos22
add bh,37h
jmp skiptopos22
topos22:
add bh,30h
skiptopos22:
mov [poss],bh
mov [poss+1],bl



ret
;-------------------------------------------------------
tobinary:
mov ax,[bx]
mov bh,ah
mov ah,0
cmp al,39h
ja mtn
sub al,30h
jmp blw
mtn:
sub al,37h
blw:
mov bl,10h
mul bl

cmp bh,39h
ja mtn1
sub bh,30h
jmp blw1
mtn1:
sub bh,37h
blw1:
add al,bh
ret
;-------------------------------------------------------

;++++++++++++++++++++++++++++++++++++++++++++++++++ START OF COMPARES

read:
call toposition
add place,2
mov bytesreadnr,0
call readfile
mov bx,dx

call tobinary

; check variants
;mov 0|add 4|push 8|pop 13|inc 17|sub 21|dec 25| or 29|adc 32|sbb 36|and 40|sub 44|xor|48|cmp 52
mov ah,al
and al,11100111b
cmp al,00100110b
jne prec1
jmp prec
prec1:

;****************************************** NR 1
mov al,ah
and al,11111110b
cmp al,10000100b
jne @01
mov cmdcount,65
jmp nr111
@01:
mov al,ah
and al,11111100b
mov cmdcount,0
cmp al,10001000b ; mov registras registras/atmintis
jne @1
jmp nr1
@1:
mov al,ah
and al,11111100b
mov cmdcount,4
cmp al,00000000b ; add registras +=registras/atmintis
jne @2
jmp nr1
@2:
mov al,ah
and al,11111100b
mov cmdcount,29
cmp al,00001000b ; or registras V registras/atmintis
jne @3
jmp nr1
@3:
mov al,ah
and al,11111100b
mov cmdcount,32
cmp al,00010000b ; adc registras+=registras/atmintis
jne @4
jmp nr1
@4:
mov al,ah
and al,11111100b
mov cmdcount,36
cmp al,00011000b ; sbb registras-=registras/atmintis
jne @5
jmp nr1
@5:
mov al,ah
and al,11111100b
mov cmdcount,40
cmp al,00100000b ; and registras & registras/atmintis
jne @6
jmp nr1
@6:
mov al,ah
and al,11111100b
mov cmdcount,44
cmp al,00101000b ; sub registras-=registras/atmintis
jne @7
jmp nr1
@7:
mov al,ah
and al,11111100b
mov cmdcount,48
cmp al,00110000b ; xor registras registras/atmintis
jne @8
jmp nr1
@8:
mov al,ah
and al,11111100b
mov cmdcount,52
cmp al,00111000b ; cmp registras registras/atmintis
jne @9
jmp nr1
@9:
mov al,ah
;****************************************** NR 1 END

;*******************************************NR 2 START
and al,11111100b
cmp al,10000000b ; cmp registras registras/atmintis
jne @10
jmp nr2
@10:
mov al,ah
;*******************************************NR 2 END
;*******************************************NR 3 START
;mov 0|add 4|push 8|pop 13|inc 17|sub 21|dec 25| or 29|adc 32|sbb 36|and 40|sub 44|xor|48|cmp 52
and al,11111110b
cmp al,00000100b ; add AKUMULIATORIUS BETARPISKAS OPERANDAS
jne @11
mov cmdcount,4
jmp nr3
@11:
mov al,ah
and al,11111110b
mov cmdcount,29
cmp al,00001100b ; or
jne @12
jmp nr3
@12:
mov al,ah
and al,11111110b
mov cmdcount,32
cmp al,00010100b ; adc
jne @13
jmp nr3
@13:
mov al,ah
and al,11111110b
mov cmdcount,36
cmp al,00011100b ; sbb
jne @14
jmp nr3
@14:
mov al,ah
and al,11111110b
mov cmdcount,40
cmp al,00100100b ; and
jne @15
jmp nr3
@15:
mov al,ah
and al,11111110b
mov cmdcount,44
cmp al,00101100b ; sub
jne @16
jmp nr3
@16:
mov al,ah
and al,11111110b
mov cmdcount,48
cmp al,00110100b ; xor
jne @17
jmp nr3
@17:
mov al,ah
and al,11111110b
mov cmdcount,52
cmp al,00111100b ; cmp
jne @18
jmp nr3
@18:
mov al,ah
;*******************************************NR 3 END
and al,11100000b

cmp al,01000000b   ; push pop inc dec    wordw
jne @19
jmp nr4
@19:
mov al,ah

;***********************************************

;*******************************************NR 4 START MOV rm operandas
mov al,ah
and al,11111110b
mov cmdcount,0
mov s,0
cmp al,11000110b  ;mov registras/atmintis betarpiskas operandas
jne @20
mov xy,1
jmp nr21
@20:
;***************************************************  mov register oper
mov al,ah
and al,00000111b
mov reg,al
mov al,ah
and al,00001000b
shr al,3
mov w,al
mov al,ah
mov cmdcount,0
and al,11110000b
cmp al,10110000b ; betarpiskas operandas-registras
jne @21
jmp nr31
@21:
mov al,ah


mov atmintis,1
and al,00000001b
mov w,al
mov al,ah
and al,00000010b
shr al,1
xor al,1
mov d,al
mov reg,000
mov cmdcount,0
call cmd
mov @mod,2
mov al,ah
and al,11111100b
cmp al,10100000b           ; mov akumuliatorius atmintis
jne @22
jmp nr32
@22:
mov al,ah
;inc 0|dec 4|mul 8|div 12|push 16|pop 21|call 25|ret 29|jmp 33



;*********************************************** inc dec mul div


and al,11111110b
cmp al,11110110b
jne @23
jmp nr5
@23:
mov al,ah

;********************************************* push pop
and al,11111110b
cmp al,11111110b
jne @24
jmp nr55
@24:
mov al,ah

cmp al,10001111b ; puah pop
jne @25
jmp nr51
@25:

;******************************************** ret
mov al,ah
cmp al,11000011b           ;ret retn
jne @26
jmp nr6
@26:
cmp al,11001111b           ;iret
jne @27
jmp nr6
@27:
cmp al,11001011b           ;retf
jne @28
jmp nr6
@28:

cmp al,11000010b
jne @29
jmp nr61
@29:
cmp al,11001010b
jne @30
jmp nr61
@30:

;---------------------------

mov al,ah
and al,11110000b                ;je jne....
cmp al,01110000b
jne @31
jmp nr7
@31:
mov al,ah
cmp al,11100011b
jne @a
mov cmdcount,112
jmp nr712
@a:
mov al,ah
cmp al,11001101b                 ;int
jne @32
jmp nr8
@32:

;***********************************************
;
and al,11100110b
cmp al,00000110b             ;push pop sergmentiniai
jne @33

jmp nr42
@33:
mov al,ah


;---- call adresas
cmp al,11111111b
jne @34
;jmp nr9
@34:


mov al,ah
and al,11111101b ; mov registrinis
cmp al,10001100b
jne @35
jmp nr11
@35:
mov al,ah
cmp al,11100010b
jne nnnr10
jmp nr711
nnnr10:

cmp al,11101011b; jmp vidinis artimas
jne nnr10
jmp nr71
nnr10:
cmp al,11101001b; jmp vidinis artimas
jne nnr11
jmp nr72
nnr11:

mov al,ah
cmp al,10001010b
jne g1
mov cmdcount,25
jmp nr15; call jmp isorinis tiesioginis
g1:
cmp al,11101010b
jne g2
mov cmdcount,33
jmp nr15; call jmp isorinis tiesioginis
g2:
mov al,ah
cmp al,11101000b
jne nnr16
jmp nr777
nnr16:


cmp al,11101001b
jne nnr16m
mov cmdcount,33
jmp nr16
nnr16m:

;*********************************************************************************************
jmp outt

;*********************************************** ret
;*********************************************************************************************
;*********************************************************************************************
;*********************************************************************************************
;*********************************************************************************************
;*********************************************************************************************
;*********************************************************************************************
;*********************************************************************************************
;*********************************************************************************************
;-------------------------------------------------------
prec:
XOR AH,AH
and al,00011000b
shr al,3
mov dl,2
mul dl
mov ax,[segreg+si]
mov segr,ax
call zero
jmp read
;+++++++++++++++++++++++++++++++++++++++++++++++++++END OF COMPARES
;---------------------------------------------
cmd:
mov cmdplace,0

lea bx,wordcommand
mov si,0
add bx, cmdcount
cmdrepeat:
mov al,[bx]
mov [command+si],al
inc bx
inc si
inc cmdplace
mov dl,20h
cmp [bx],dl
jne cmdrepeat
mov [command+si],dl

; Iraso komandos pavadinima i command masyva. cmdcount seka, kuris narys eina
; Baigiasi space, reiskias reikes padidinti vienu, kai reikes naudoti
ret
cmd2:
mov cmdplace,0

lea bx,wordcommand2
mov si,0
add bx, cmdcount
cmdrepeat1:
mov al,[bx]
mov [command+si],al
inc bx
inc si
inc cmdplace
mov dl,20h
cmp [bx],dl
jne cmdrepeat1
mov [command+si],dl

; Iraso komandos pavadinima i command masyva. cmdcount seka, kuris narys eina
; Baigiasi space, reiskias reikes padidinti vienu, kai reikes naudoti
ret
@register:
mov al,reg

call registerread
mov [register],al
mov [register+1],ah
add overall,2
ret
;---------------------------------------------------
regmem:

cmp @mod,011b
jne mod11
mov al,rm
call registerread
mov atmintis,0
mov [poslinkis],al
mov [poslinkis+1],ah
mov poslinkisdydis,2
jmp mod11nr1
mod11:
call mod000110   ; jeigu ne registras, tai atmintis
call iposlinki
mod11nr1:
ret
;--------------------------------------------------- skirta laikyti memory arba register
membojb:

mov @mod,1
mov operandasdydis,2
cmp w,0
je we
mov @mod,2
mov operandasdydis,4
we:
call bytes
cmp atmintis,1
jne atmintisskip
mov [operandas],'['
mov [operandas+1],ah
mov [operandas+2],al
mov [operandas+3],']'
add operandasdydis,2
cmp w,1
jne wskip
mov [operandas+3],ch
mov [operandas+4],cl
mov [operandas+5],']'
jmp wskip
atmintisskip:

mov [operandas],ah
mov [operandas+1],al
cmp w,0
je wskip
mov [operandas+2],ch
mov [operandas+3],cl
oper:
cmp s,1
jne skipp
mov [operandas+2],ah
mov [operandas+3],al

cmp ah,8
jb pildymas
mov ah,'0'
jmp pildymas1
pildymas:
mov ah,'F'
pildymas1:
mov [operandas],ah
mov [operandas+1],ah
skipp:
mov al,operandasdydis
add overall,al
ret
wskip:
mov al,operandasdydis
add overall,al
ret

;--------------------------------------------------------
registerread:
mov ah,0
mov bl,2
mul bl
mov si,ax

cmp w,0
jne rs
mov ax,[byteregister+si]
jmp rs1
rs:
mov ax,[wordregister+si]     ; naudojamas registras uzrasomas i register masyva
rs1:
ret
;-------------------------------------------------------



;--------------------------------------------------- atminciai arba betarpiskam operandui

;-------------------------------------------------------
mod000110:
mov si,1
mov poslinkisdydis,1
mov poslinkis,'['


cmp rm,000b
jne pp1
lea bx,p0
jmp back
pp1:
cmp rm,001b
jne pp2
lea bx,p1
jmp back
pp2:
cmp rm,010b
jne pp3
lea bx,p2
jmp back
pp3:
cmp rm,011b
jne pp4
lea bx,p3
jmp back
pp4:
cmp rm,100b
jne pp5
lea bx,p4
jmp back
pp5:
cmp rm,101b
jne pp6
lea bx,p5
jmp back
pp6:
cmp rm,110b
jne pp7
cmp @mod,00b
jne @mod11

mov @mod,2
ret
@mod11:
lea bx,p6
jmp back
pp7:
cmp rm,111b
jne pp8
lea bx,p7
jmp back
pp8:

back:
mov al,[bx]
mov [poslinkis+si],al
inc bx
inc si
inc cx
mov dl,'.'
cmp [bx],dl
jne back
xor ax,ax
mov ax,si
mov poslinkisdydis,al
cmp @mod,0
jne decposd
dec poslinkisdydis
decposd:
mov ax,si
xor bx,bx
ret
;----------------------------------------
;------- SELECT MEMORY TYPE
iposlinki:
call bytes
cmp @mod,0
je nmod2
nmod0:
mov cx,bx
lea bx,poslinkis
add bl,poslinkisdydis
mov [bx],ah
mov [bx+1],al
add bx,2
add poslinkisdydis,2
cmp @mod,2
jne nmod2
mov [bx],ch
mov [bx+1],cl
add poslinkisdydis,2
nmod2:
lea bx,[poslinkis]
add bl,poslinkisdydis
mov dl,']'
mov [bx],dl
inc poslinkisdydis
ret
;-------------------------------------------------------
rmregmod:
and al,00000111b
mov rm, al
mov al,ah
and al,00111000b
shr al,3
mov reg,al
mov al,ah
and al,11000000b
shr al,6
mov @mod,al
ret
;-------------------------------------------------------
;---------------------------------------------------



zero:
mov xy,0
mov poslinkisdydis,0
mov operandasdydis,0
mov cmdplace,0
mov cmdcount,0
mov atmintis,0
mov overall,0
mov bytesreadnr,0
mov d,0
mov s,0
mov w,0
xor ax,ax
xor bx,bx
xor cx,cx
xor dx,dx
ret
;------------------------------------------------------
;-------------------------------------------------------- WRITE ADDITIONAL BYTES



;---------------------------------------------------
commandreg:
;mov 0|add 4|push 8|pop 13|inc 17|sub 21|dec 25| or 29|adc 32|sbb 36|and 40|sub 44|xor|48|cmp 52
cmp reg,000b
jne @reg000
mov cmdcount,4;add
@reg000:
cmp reg,001b
jne @reg001
mov cmdcount,29;or
@reg001:
cmp reg,010b
jne @reg010
mov cmdcount,32;adc
@reg010:
cmp reg,011b
jne @reg011
mov cmdcount,36;sbb
@reg011:
cmp reg,100b
jne @reg100
mov cmdcount,40;and
@reg100:
cmp reg,101b
jne @reg101
mov cmdcount,21;sub
@reg101:
cmp reg,110b
jne @reg110
mov cmdcount,48;xor
@reg110:
cmp reg,111b
jne @reg111
mov cmdcount,52;cmp
@reg111:
ret
;-------------------------------------------------------
bytes:

cmp @mod,0
je bytesreturn
call readfile
mov ah,readbytes
mov al,[readbytes+1]
cmp @mod,2
jne bytesreturn
cmp s,1
je bytesreturn
mov [ttbyte],ah
mov [ttbyte+1],al
call readfile
mov ch,readbytes
mov cl,[readbytes+1]
mov ah,ttbyte
mov al,[ttbyte+1]
mov bx,ax
mov ax,cx
mov cx,bx





bytesreturn:

ret
;-------------------------------------------------------
;-read bytes

;""""""""""""""""""""""""""""""""""""""""""""""""""""" START OF NR1
nr1:                     ;1000 10dw   mov
call cmd
mov si,0
mov al,ah
and al,00000001b
mov w,al
mov al,ah
and al,00000010b
shr al,1
mov d,al
jmp nr111skip
nr111:
call cmd
mov si,0
mov al,ah
and al,00000001b
mov w,al
mov al,ah

mov d,1

nr111skip:

call readfile
mov bx,dx
call tobinary
mov ah,al
call rmregmod

call @register
jmp segmentregister
nr11:
mov cmdcount,0
call cmd
call readfile
mov bx,dx
call tobinary
mov ah,al
call rmregmod
mov al,ah
and al,00000010b
shr al,1
mov d,al

mov al,reg
mov dl,2
mul Dl
mov ah,0
mov si,ax
mov ax,[segreg+si]
mov register,ah
mov [register+1],al

segmentregister:
call regmem

lea bx,poslinkis
mov dl,poslinkisdydis
call merge1
mov cl,poslinkisdydis
add overall,cl
mov cx,cmdplace
add overall,cl
add overall,4; del tarpo
call outputdata


call zero


jmp read

ret
;""""""""""""""""""""""""""""""""""""""""""""""""""""" END OF NR1
nr2:
mov si,0
mov al,ah
and al,00000001b
mov w,al
mov al,ah
and al,00000010b
shr al,1
mov s,al
mov d,0 ;    poslinkis---operandas
nr21:
mov d,0
mov al,ah
and al,00000001b
mov w,al


mov atmintis,0
call readfile
mov bx,dx
call tobinary
mov ah,al
call rmregmod
call commandreg
cmp xy,1
jne skipxy
mov cmdcount,0
skipxy:

call cmd
call regmem
call membojb

call merge2
mov al,poslinkisdydis
add overall,al
add overall,5
call outputdata
call zero

jmp read

nr3:
mov si,0
mov al,ah
and al,00000001b
mov w,al
mov al,ah
and al,00000010b
shr al,1
mov d, 1
mov atmintis,0
mov reg,0
jmp skk
nr31:; prijungiama mov register boperandas
mov d,1
skk:
call cmd
mov atmintis,0
jmp skpp
nr32:
call @register
mov w,1
jmp skppp
skpp:
call @register
skppp:
call membojb
lea bx,operandas
mov dl,operandasdydis
call merge1
mov cl,operandasdydis
add overall,cl
mov ax,cmdplace
add overall,al; del tarpo
call outputdata


call zero
jmp read

nr4:
mov al,ah
and al,00000111b
mov reg,al
mov w,1
mov al,ah

shr al,3
and al, 00000011b

cmp al,2
jne ps
mov cmdcount,8
jmp ppid
ps:
cmp al,3
jne ps1
mov cmdcount,13
jmp ppid
ps1:
cmp al,0
jne ps2
mov cmdcount,17
jmp ppid
ps2:
cmp al,1
jne ps3
mov cmdcount,25
jmp ppid
ps3:

ppid: ;push pop inc dec
call @register

jmp nr42skip
nr42:

mov al,ah
and al,00000001b

mov cmdcount,8
cmp al,1
jne nr42skip0
mov cmdcount,13

nr42skip0:
mov al,ah
and al,00011000b
shr al,3
mov dl,2
mul dl
mov ah,0
mov si,ax
mov ax,[segreg+si]
mov register,al
mov [register+1],ah

add overall,2
nr42skip:

call cmd


lea bx,register
xor cx,cx
mov cl,2

call merge3
xor cx,cx
mov cl,2
add overall,cl
mov cx,cmdplace
dec cx
add overall,cl
call outputdata


call zero


jmp read

nr5:
mov al,ah
and al,00000001b
mov w,al

call readfile
mov bx,dx
call tobinary
mov ah,al
call rmregmod

cmp reg,0
jne reg000
mov cmdcount,0
reg000:
cmp reg,1
jne reg111
mov cmdcount,4
reg111:
cmp reg,4
jne reg444
mov cmdcount,8
reg444:
cmp reg,6
jne reg666
mov cmdcount,12
reg666:

;inc 0|dec 4|mul 8|div 12|push 16|pop 21|call 25|ret 29|jmp 33
jmp skipnr5
nr55:
call readfile
mov bx,dx
call tobinary
mov ah,al
call rmregmod
;inc 0|dec 4|mul 8|div 12|push 16|pop 21|call 25|ret 29|jmp 33|ret 37|iret 41|retf 46
cmp reg,0
jne reg0000
mov cmdcount,0
reg0000:
cmp reg,1
jne reg1111
mov cmdcount,4
reg1111:
cmp reg,2
jne reg2222
mov cmdcount,25
reg2222:
cmp reg,3
jne reg3333
mov cmdcount,25
reg3333:
cmp reg,4
jne reg4444
mov cmdcount,33
reg4444:
cmp reg,5
jne reg5555
mov cmdcount,33
reg5555:
cmp reg,6
jne reg6666
mov cmdcount,16
reg6666:



jmp skipnr5
nr51:
call readfile
mov bx,dx
call tobinary
mov ah,al
call rmregmod






cmp reg,6
jne reg66
mov cmdcount,16

reg66:

cmp reg,0
jne reg010
mov cmdcount,21

reg010:

skipnr5:
call cmd2

call regmem

lea bx,poslinkis
xor cx,cx

mov cl,poslinkisdydis

call merge3
xor cx,cx

mov cl,poslinkisdydis
add overall,cl
mov cx,cmdplace
inc cx
add overall,cl
call outputdata


call zero

jmp read

nr6:

mov al,ah
and al,00001111b
;inc 0|dec 4|mul 8|div 12|push 16|pop 21|call 25|ret 29|jmp 33|ret 37|iret 41|retf 46
cmp al,0011b
jne b0011b
mov cmdcount,29
b0011b:
cmp al,1111b
jne b1111b
mov cmdcount,41
b1111b:
cmp al,1011b
jne b1011b
mov cmdcount,46
b1011b:
jmp skipnr6
nr61:
and al,00001111b
mov w,1
mov atmintis,0
cmp al,0010b
jne b00100
mov cmdcount,29
b00100:
cmp al,1010b
jne b10100
mov cmdcount,46
b10100:



mov operandasdydis,0
call cmd2
call membojb

lea bx,operandas
xor cx,cx
mov cl,operandasdydis
call merge3

jmp  skiprnr62
skipnr6:
call cmd2
skiprnr62:


mov cx,cmdplace
inc cx
add overall,cl
mov cl,operandasdydis
add overall,cl
call outputdata
call zero
jmp read

nr7:
mov w,0
mov s,0
mov @mod,1
mov al,ah
;jo 51| jno 54| jb 58| jae 61| je 65| jne 68| jbe 72| ja 76|js 79| jns 82| jp 86| jnp 89| jl 93| jge 96| jle 100| jg 104
and al,00001111b

cmp al,0000b
jne j1
mov cmdcount,51
j1:
cmp al,0001b
jne j11
mov cmdcount,54
j11:
cmp al,0010b
jne j12
mov cmdcount,58
j12:
cmp al,0011b
jne j13
mov cmdcount,61
j13:
cmp al,0100b
jne j41
mov cmdcount,65
j41:
cmp al,0101b
jne j15
mov cmdcount,68
j15:

cmp al,0110b
jne j16
mov cmdcount,72
j16:
cmp al,0111b
jne j17
mov cmdcount,76
j17:
cmp al,1000b
jne j18
mov cmdcount,79
j18:
cmp al,1001b
jne j19
mov cmdcount,82
j19:
cmp al,1010b
jne j101
mov cmdcount,86
j101:
cmp al,1011b
jne j1055
mov cmdcount,89
j1055:
cmp al,1100b
jne j102
mov cmdcount,93
j102:
cmp al,1101b
jne j103
mov cmdcount,96
j103:
cmp al,1110b
jne j104
mov cmdcount,100
j104:
cmp al,1111b
jne j105
mov cmdcount,104
j105:
jmp nr71s
nr712:
mov w,0
mov s,0
mov @mod,1
mov cmdcount,117
jmp nr71s
nr72:
mov w,1
mov s,0
mov @mod,2
mov cmdcount,33
jmp nr71s
nr71:
mov w,0
mov s,0
mov @mod,1
mov cmdcount,33
jmp nr71s
nr777:
mov w,1
mov cmdcount,25

jmp nr71s
nr711:
mov w,0
mov s,0
mov @mod,1
mov cmdcount,107

nr71s:

call cmd2
call readfile
mov [readbytes],bh
mov [readbytes+1],bl
lea bx,readbytes
call tobinary
mov b,al
mov ah,0

cmp w,0
jne w0skip
add ax,position

w0skip:
cmp w,1
jne w1skip
call readfile
mov [readbytes],bh
mov [readbytes+1],bl
lea bx,readbytes
call tobinary
mov ah,al
mov al,b
add ax,position
w1skip:
mov [readbytes],ah
call tohex

mov [poslinkis],bh
mov [poslinkis+1],bl

mov [readbytes],al
call tohex
mov [poslinkis+2],bh
mov [poslinkis+3],bl

mov poslinkisdydis,4



lea bx,poslinkis
xor cx,cx
mov cl,poslinkisdydis
call merge3

mov cx,cmdplace
inc cx
add overall,cl
mov cl,poslinkisdydis
add overall,cl
call outputdata
call zero
jmp read



nr8:
mov w,0
mov @mod,1
mov s,0
mov cmdcount,56; int
call cmd
call bytes
mov poslinkis,ah
mov [poslinkis+1],al
mov poslinkisdydis,2

lea bx,poslinkis
xor cx,cx
mov cl,poslinkisdydis
call merge3

mov cx,cmdplace
inc cx
add overall,cl
mov cl,poslinkisdydis
add overall,cl
call outputdata
call zero
jmp read
nr9:
mov w,1

call readfile
mov bx,dx
call tobinary
mov ah,al
call rmregmod

cmp reg,1
ja regsk
mov cmdcount,25
jmp regsk1
regsk:
mov cmdcount,2
regsk1:
call cmd2

call regmem

cmp @mod,11b
jne bskip
mov cl,@mod
mov reg,cl
call @register
mov ah,register
mov al,[register+1]
mov poslinkis,ah
mov [poslinkis+1],al
mov poslinkisdydis,2
bskip:


mov cl,poslinkisdydis
lea bx,poslinkis

call merge3
mov cx,cmdplace
inc cx
add overall,cl
mov cl,poslinkisdydis
add overall,cl
call outputdata
call zero
jmp read

nr10:
mov cmdcount,33
call cmd2
mov @mod,1
mov w,0
mov s,0
mov atmintis,0
call bytes
mov poslinkis,ah
mov [poslinkis+1],al

lea bx,poslinkis
mov cl,2
mov ax,cmdplace
mov overall,al
mov al,2
add overall,5
call merge3
call outputdata
call zero
jmp read




nr15:
call cmd2
mov s,0
mov @mod,2
mov w,1
call bytes
mov operandas,ah
mov [operandas+1],al
mov [operandas+2],ch
mov [operandas+3],cl
mov [operandas+4],':'
call bytes
mov [operandas+5],ah
mov [operandas+6],al
mov [operandas+7],ch
mov [operandas+8],cl

lea bx,operandas
mov cl,9
call merge3
mov ax,cmdplace
mov overall,al
mov al,2
mov overall,20
call outputdata
call zero
jmp read

nr16:
call cmd2
mov s,0
mov @mod,2
call bytes
mov operandas,ah
mov [operandas+1],al
mov [operandas+2],ch
mov [operandas+3],cl
mov operandasdydis,4


lea bx,operandas
mov cl,4
mov overall,10

call merge3
call outputdata
call zero
jmp read




merge3:




mov si,cmdplace
inc si
merging3:
mov al,[bx]
mov [command+si],al
inc si
inc bx
loop merging3
ret
merge1:
;command,cmdplace,d,register,poslinkis,posd


mov si,cmdplace
inc si ;-kad ant tarpo neuzrasytume
xor cx,cx
mov cl,dl
cmp d,0 ; i reg/mem
jne merge1d0
merge1memregd0:
mov al,[bx]
mov [command+si],al
inc si
inc bx
loop merge1memregd0
mov [command+si],','
inc si
mov al,register
mov ah,[register+1]
mov [command+si],al
inc si
mov [command+si],ah

jmp merge1skip
merge1d0:

mov al,register
mov ah,[register+1]
mov [command+si],al
inc si
mov [command+si],ah
inc si
mov [command+si],','
inc si
merge1memregd1:
mov al,[bx]
mov [command+si],al
inc bx
inc si
loop merge1memregd1
mov [command+si],' '
inc si

mov [command+si],' '

merge1skip:

ret
;-------------------------------------------END OF MERGE1


merge2:
;command,cmdplace,d,register,poslinkis,posd


mov si,cmdplace
inc si ;-kad ant tarpo neuzrasytume
xor cx,cx
lea bx,poslinkis
mov cl,poslinkisdydis
cmp d,1 ; i reg/mem
je merge2d0
merge2memregd0:
mov al,[bx]
mov [command+si],al
inc si
inc bx
loop merge2memregd0


mov [command+si],','
inc si
mov cl,operandasdydis
lea bx,operandas

merge2operandas:
mov al,[bx]
mov [command+si],al
inc si
inc bx
loop merge2operandas
dec bx

jmp merge2skip
merge2d0:

mov cl,operandasdydis
lea bx,operandas

merge2operandas1:
mov al,[bx]
mov [command+si],al
inc si
inc bx
loop merge2operandas1
mov [command+si],','
inc si

lea bx,poslinkis
mov cl,poslinkisdydis
merge2memregd1:
mov al,[bx]
mov [command+si],al
inc bx
inc si
loop merge2memregd1
mov [command+si],','
inc si

merge2skip:

ret
;-------------------------------------------END OF MERGE2

;----------------------------------------
outputdata:
mov ah,40h
mov bx,outputhandle
xor cx,cx
mov cx,7
lea dx,poss
int 21h


mov ah,40h
mov bx,outputhandle
xor cx,cx
mov cx,bytesreadnr
lea dx,bytesread
int 21h

xor ax,ax
xor dx,dx
mov dl,12
sub dx,bytesreadnr
mov ah,40h
mov bx,outputhandle
mov cx,dx
lea dx,spacing
int 21h

mov ah,40h
mov bx,outputhandle
xor cx,cx
mov cl,overall
lea dx,command
int 21h

mov ah,40h
mov bx,outputhandle
xor cx,cx
mov cl,2
lea dx,newline
int 21h


mov cx,20
erase:
mov si,cx
mov [command+si],20h
loop erase
mov bytesreadnr,0
ret


outt:
mov ah,40h
mov bx,outputhandle
xor cx,cx
mov cx,7
lea dx,poss
int 21h

mov ah,40h
mov bx,outputhandle
xor cx,cx
mov cx,bytesreadnr
lea dx,bytesread
int 21h
mov ah,40h
mov bx,outputhandle
xor cx,cx
mov cx,4
lea dx,spacing
int 21h
mov ah,40h
mov bx,outputhandle
xor cx,cx
mov cl,11
lea dx,neatpazinta
int 21h
mov ah,40h
mov bx,outputhandle
xor cx,cx
mov cl,2
lea dx,newline
int 21h
mov bytesreadnr,0
jmp read
end start
