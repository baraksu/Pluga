; VERSION 102
.MODEL small
.STACK 100h

.DATA 
mahlaka db ?
kita db ?
sizeOfPluga dw ?  
part_a db 13,10,'part A!',13,10,'$'
part_b db 13,10,'part B!',13,10,'$'
part_c db 13,10,'part C!',13,10,'$'
part_d db 13,10,'part D!',13,10,'$' 
part_e db 13,10,'part E!',13,10,'$'
msg1 db 13,10,'enter number of mahlakas in the pluga:',13,10,'$'
msg2 db 13,10,'enter number of kita in the pluga:',13,10,'$'
msg3 db 13,10,'insert amount of soldiers int the kitas according to kitas order',13,10,'$'
msg4 db 13,10,'the number of soldiers in the first mahlaka is',13,10,'$'             
msg4_2 db 13,10,'the number of soldiers in the next one is:',13,10,'$' 
msg5 db 13,10,'the kita with the max soldiers is:',13,10,'$'
msg6 db 13,10,'the number of soldiers in this kita is:',13,10,'$'
msg7 db 13,10,'the number of the mahlaka with the kita with the max soldiers is:',13,10,'$'
msg db 13,10,"supported values from -127 to 128",13,10, "enter the number: $"
sum dw 0
maxKita db 0   ;we need to get the max so we will chack the kitas if 
               ;it greater the the max value and if it will we wiil put the kitavalue into maxKita in part D        
maxKitaNumber dw 0
maxMahlaka dw 0 ;part e            
crlf db 13,10,'$' 
.CODE      
strat:
mov ax,@data ;data to dataSegment
mov ds,ax                       

call getMahlaka ;get number of mahlakas
call getKita ;get number of kitas 

; print the message1:
mov dx, offset msg
mov ah, 9
int 21h

xor ax,ax
xor dx,dx
xor cx,cx
call scan_num ; get the number to cx.

mov bx, cx




; wait for any key....
mov ah, 0
int 16h


ret ; return to operating system.
; this macro prints a char in al and advances the current cursor position:
putc    macro   char
        push    ax
        mov     al, char
        mov     ah, 0eh
        int     10h     
        pop     ax
endm
call NOSIEM ;number of soldiers in each mahlaka
call maxMahlakaAndKitaSoldiers




exit:
mov ah, 4ch ;end program
int 21h

proc getMahlaka ;get number of mahlakas  
    lea dx,part_a ;print part A
    mov ah,9
    int 21h
    xor ax,ax ;show msg1 
    lea dx,msg1
    mov ah,9
    int 21h
    numberOfMahlakasAndCheck: ;insert number of mahlakas and check if it is
                              ;a number and if its not the user need to insert again
        mov ah,1 ;get a char of mahlakas
        int 21h 
        mov mahlaka,al ;check if the char that was inserted is a number
        cmp al,'0'
        jb numberOfMahlakasAndCheck:
        cmp al,'9'
        ja numberOfMahlakasAndCheck:  
        sub mahlaka,30h  
    ret 
endp getMahlaka 

proc getKita ;get number of kitas 
    lea dx,part_b ;print part B
    mov ah,9
    int 21h
    xor ax,ax  ;show msg2
    lea dx,msg2
    mov ah,9 
    numberOfKitasAndCheck:  ;insert number of mahlakas and check if it is
                            ;a number and if its not the user need to insert again 
    int 21h  ;get number of kita 
    mov ah,1
    int 21h
    cmp al,'0'
    jb numberOfKitasAndCheck
    cmp al,'9'
    ja numberOfKitasAndCheck
    mov kita,al 
    sub kita,30h
    sub al,30h
    
    mul mahlaka         ;size of the pluga
    mov sizeOfpluga,ax
    
    pluga db sizeOfpluga dup(0) ;create the mat
    
    ret
endp getKita

; this procedure gets the multi-digit signed number from the keyboard,
; and stores the result in cx register:
scan_num        proc    near
        push    dx
        push    ax
        push    si
        
        mov     cx, 0

        ; reset flag:
        mov     cs:make_minus, 0

next_digit:

        ; get char from keyboard
        ; into al:
        mov     ah, 00h
        int     16h
        ; and print it:
        mov     ah, 0eh
        int     10h
        xor ah,ah   ;?reset bios
        ; check for minus:
        cmp     al, '-'
        je      set_minus

        ; check for enter key:
        cmp     al, 13  ; carriage return?
        jne     not_cr
        jmp     stop_input
not_cr:


        cmp     al, 8                   ; 'backspace' pressed?
        jne     backspace_checked
        mov     dx, 0                   ; remove last digit by
        mov     al, cl                  ; division:
        div     cs:ten                  ; ax = dx:ax / 10 (dx-rem).
        mov     cl, al
        putc    ' '                     ; clear position.
        putc    8                       ; backspace again.
        jmp     next_digit
backspace_checked:


        ; allow only digits:
        cmp     al, '0'
        jae     ok_ae_0
        jmp     remove_not_digit
ok_ae_0:        
        cmp     al, '9'
        jbe     ok_digit
remove_not_digit:       
        putc    8       ; backspace.
        putc    ' '     ; clear last entered not digit.
        putc    8       ; backspace again.        
        jmp     next_digit ; wait for next input.       
ok_digit:


        ; multiply cx by 10 (first time the result is zero)
        push    ax
        mov     al,cl
        mul     cs:ten                  ; dx:ax = ax*10
        mov     cl, al
        pop     ax

        ; check if the number is too big
        ; (result should be 16 bits)
        cmp     ah, 0
        jne     too_big

        ; convert from ascii code:
        sub     al, 30h

        ; add al to cx:
        mov     ah, 0
        mov     dl, cl      ; backup, in case the result will be too big.
        add     cl, al
        jc      too_big2    ; jump if the number is too big.

        jmp     next_digit

set_minus:
        mov     cs:make_minus, 1
        jmp     next_digit

too_big2:
        mov     cl, dl      ; restore the backuped value before add.
        mov     dx, 0       ; dx was zero before backup!
too_big:
        mov     al, cl
        div     cs:ten  ; reverse last dx:ax = ax*10, make ax = dx:ax / 10
        mov     cl, al
        putc    8       ; backspace.
        putc    ' '     ; clear last entered digit.
        putc    8       ; backspace again.        
        jmp     next_digit ; wait for enter/backspace.
        
        
stop_input:
        ; check flag:
        cmp     cs:make_minus, 0
        je      not_minus
        neg     cl
not_minus:

        pop     si
        pop     ax
        pop     dx
        ret
make_minus      db      ?       ; used as a flag.
ten             dw      10      ; used as multiplier.
scan_num        endp

proc NOSIEM ;number of soldiers in each mahlaka
    lea dx,part_d
    mov ah,9
    int 21h
    xor cx,cx
    mov cl,mahlaka
    sub cx,sizeOfPluga
    xor si,si  
    xor bp,bp
    mahlakaloop: 
        push cx
        xor cx,cx
        mov cl,kita
        numberOfSoldiersloop:
            xor ax,ax
            mov al,pluga[si]
            add sum,ax
            inc si 
            loop numberOfsoldiersloop 
            mov ax,sum
            push ax
            push bx
            push cx
            push dx  
    
        mov bx,10
        xor cx,cx 
        convertLoop:
            xor dx,dx
            div bx
            add dx,'0'
            push dx
            inc cx
            cmp ax,0
            jne convertLoop
        
        cmp bp,0
        je firstMahlakaPrint
        jmp anotherMahlaka
        
        firstMahlakaPrint:
            lea dx,msg4
            mov ah,9
            int 21h 
            inc bp
            jmp printLoop
        anotherMahlaka:
            lea dx,msg4_2
            mov ah,9
            int 21h     
        printLoop:
            
            pop dx
            mov ah,02h
            int 21h
            loop printLoop   
        pop dx
        pop cx
        pop bx
        pop ax
        mov sum,0
        pop cx
        loop mahlakaloop                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
    ret
endp NOSIEM

proc maxMahlakaAndKitaSoldiers ;find the kita and the nahlaka with the max soldiers 
    lea dx,part_e
    mov ah,9
    int 21h 
    lea dx,msg7
    int 21h      
    xor cx,cx               
    mov cl,mahlaka ;how many times in the mahlaka loop
    sub cx,sizeOfPluga
    xor si,si
    mahlakaLoop2:
        push cx ;for keeping the value because the inside loop that using cx too
        xor cx,cx
        mov cl,kita ;hoe many times in the kita loop
        kitaLoop:    
        mov al,maxKita 
            cmp pluga[si],al ;check if the kita: pluga[si] is greater than the maxKita
            ja newMax 
            jmp continue ;if tyhe kita isn't greater
            newMax:
                mov al,pluga[si] ;because the kita: pluga[si] is greater tham max we put the kita's value int the max               
                mov maxKita,al
                mov maxKitaNumber,si
                inc maxKitaNumber ;si start from 0 bet the number of the kitas from 1
                mov maxMahlaka,si               
                inc maxMahlaka
            continue:
                inc si
            loop kitaLoop
        pop cx
        loop mahlakaLoop2
        
        xor ax,ax 
        mov ax,maxMahlaka   
        div kita 
        cmp ah,0
        jne maxMahlakaIsNum1
        mov dl,al
        add dl,30h
        mov ah,2
        int 21h
        jmp con
        maxMahlakaIsNum1:
            mov dl,'1'
            mov ah,2
            int 21h
        con:    
        mov ah,9
        lea dx,msg5
        int 21h
        xor ax,ax
        mov al,mahlaka
        sub ax,sizeOfPluga ;it will be just in al and not in ah
        mov mahlaka,al
        mov ax,maxKitaNumber
        div mahlaka
        cmp ah,0
        jne maxKitaIsNum1
        mov dl,al
        add dl,30h
        mov ah,2
        int 21h
        jmp con1:
        maxKitaIsNum1:
            mov dl,'1'
            mov ah,2
            int 21h
        con1:     
        lea dx,msg6
        mov ah,9
        int 21h
        xor ah,ah
        mov al,maxKita
        push ax
        push bx
        push cx
        push dx
        mov bx,10
        xor cx,cx
        convertLoop2:
            xor dx,dx
            div bx
            add dx,'0'
            push dx
            inc cx
            cmp ax,0
            jne convertLoop2
        pop dx
        mov dl,maxKita
        add dl,30h
        mov ah,2
        int 21h
        pop dx
        pop cx
        pop bx
        pop ax            
    ret
endp maxMahlakaAndKitaSoldiers


END