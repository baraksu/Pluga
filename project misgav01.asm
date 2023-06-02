;version 200 final

.MODEL small
.STACK 100h

.DATA    



mahlaka db ? ;number of mahlakas
kita db ?    ;number of kitas
sizeOfPluga dw ?  ;size of the array mahlaka*kita
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
sum dw 0
maxKita db 0   ;we need to get the max so we will chack the kitas if 
               ;it greater the the max value and if it will we wiil put the kitavalue into maxKita in part D        
maxKitaNumber dw 0
maxMahlaka dw 0 ;part e            
crlf db 13,10,'$' 
msg10 db 13,10,'the next kita',13,10,'$'
temp01 dw 0
msg100 db      '      _                 ',13,10,
       db      ' _ __| |_  _ __ _ __ _  ',13,10,
       db      '| ,_ \ | || / _` / _` | ',13,10,
       db      '| .__/_|\_,_\__, \__,_| ',13,10,
       db      '|_|         |___/       ',13,10,'$'
.CODE      
strat:
mov ax,@data ;data to dataSegment
mov ds,ax                       
lea dx,msg100
mov ah,9
int 21h
xor ax,ax
xor dx,dx
call getMahlaka ;get number of mahlakas
call getKita ;get number of kitas
pluga db sizeOfpluga dup(0) ;create the mat
lea dx,msg3 ;print msg3
mov ah,9
int 21h

mov si,0 ;counter for the array
mov cx,sizeOfPluga
insertLoop: ;insert the number of soldiers in the kitas
    
    mov temp01,cx
    lea dx,msg10
    mov ah,9
    int 21h 
    call scan_num ; get the number to cx.
    lea dx,crlf ;enter line
    mov ah,9
    int 21h
    lea bx,pluga ;put the number that was inserted in the array
    mov [bx+si],cl
    inc si      
    mov cx,temp01
    loop insertLoop
    
    
mov bx, cx


; this macro prints a char in al and advances the current cursor position:
putc    macro   char
        push    ax
        mov     al, char
        mov     ah, 0eh
        int     10h     
        pop     ax
endm

call NOSIEM
call maxMahlakaAndKitaSoldiers




exit:
mov ah, 4ch ;end program
int 21h

proc getMahlaka ;get number of mahlakas ;parameters:mahlaka 
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
endp getMahlaka ;;the proc get a digit from the user check if its a number if not insert a digit again and put it in mahlaka

proc getKita ;get number of kitas and create pluga (the array) ;parameters:kita
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
    jb numberOfKitasAndCheck ;not a number
    cmp al,'9'
    ja numberOfKitasAndCheck ;not a number
    mov kita,al 
    sub kita,30h ;to get the number itself
    sub al,30h 
    
    mul mahlaka         ;size of the pluga
    mov sizeOfpluga,ax
    
    ret
endp getKita ;the proc get a digit from the user check if its a number if not insert a digit again and put it in kita

; this procedure gets the multi-digit signed number from the keyboard,
; and stores the result in cx register:
scan_num        proc    near ;from the ToBin code 
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
scan_num        endp ;the proc get a multiply digits number from the user chack if its a number, delete ot enter if enter end the insert if delete its delete the last number that was inserted if its not a number delete it and wait for the next digit. 

proc NOSIEM ;print the number of soldiers in each mahlaka ;parameters:mahlakaa, sizeOfPluga, kita, pluga, sum, 
    lea dx,part_d ; print part d
    mov ah,9
    int 21h
    xor cx,cx
    mov cl,mahlaka  ;for the loop
    sub cx,sizeOfPluga;because mahlaka grew the value of sizeOfPluga
    xor si,si  
    xor bp,bp
    mahlakaloop: 
        push cx ;for keeping it and for the inside loop
        xor cx,cx
        mov cl,kita ;for the loop
        numberOfSoldiersloop:
            xor ax,ax 
            lea bx,pluga
            mov al,[bx+si] ;put the value of the array's [si] cell in al
            add sum,ax ;ax because it will be just in al cut sum is a word
            inc si 
            loop numberOfsoldiersloop 
            mov ax,sum
            push ax
            push bx
            push cx
            push dx  
    
        mov bx,10 ;divide in 10 later
        xor cx,cx 
        convertLoop:
            xor dx,dx
            div bx ;divide the sum in 10
            add dx,'0' ;the modolu - add 48 
            push dx ;push it to the stack so we will pop it out and print it according to the order
            inc cx
            cmp ax,0
            jne convertLoop ;push all the digits of sum
        
        cmp bp,0
        je firstMahlakaPrint 
        jmp anotherMahlaka
        
        firstMahlakaPrint:
            lea dx,msg4 ;print msg4
            mov ah,9
            int 21h 
            inc bp
            jmp printLoop
        anotherMahlaka:
            lea dx,msg4_2 ;print mag4_2
            mov ah,9
            int 21h     
        printLoop:
            
            pop dx   ;pop the digits of sum
            mov ah,02h  ;print the digits one after one
            int 21h
            loop printLoop   
        pop dx
        pop cx
        pop bx
        pop ax
        mov sum,0 ;for the next mahlkaka
        pop cx
        loop mahlakaloop                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
    ret
endp NOSIEM ;calculate the sum of soldiers in each mahlaka and print it

proc maxMahlakaAndKitaSoldiers ;find the kita and the nahlaka with the max soldiers ;parameters:mahlaka, kita, sizeOfPluga, newMax, pluga, maxKitaNumber, maxMahlaka, maxKita 
    lea dx,part_e ;print part e
    mov ah,9
    int 21h 
    lea dx,msg7  ;print msg7
    int 21h      
    xor cx,cx               
    mov cl,mahlaka ;how many times in the mahlaka loop
    sub cx,sizeOfPluga ;because mahlaka grew the value of sizeOfPluga
    xor si,si
    mahlakaLoop2:
        push cx ;for keeping the value because the inside loop that using cx too
        xor cx,cx
        mov cl,kita ;hoe many times in the kita loop
        kitaLoop:    
            mov al,maxKita ;put the value of maxkita in al for line 325
            lea bx,pluga 
            cmp [bx+si],al ;check if the kita: pluga[si] is greater than the maxKita
            ja newMax ;there is a new maxkita
            jmp continue ;if tyhe kita isn't greater
            newMax:
                mov al,[bx+si] ;because the kita: pluga[si] is greater tham max we put the kita's value int the max               
                mov maxKita,al ;put the new maxkita in maxkita
                mov maxKitaNumber,si ;the number of the maxkita in the array
                inc maxKitaNumber ;si start from 0 bet the number of the kitas from 1
                mov maxMahlaka,si               
                inc maxMahlaka ;because its start from 0 not from 1
            continue:
                inc si
            loop kitaLoop
        pop cx ;for the loop
        loop mahlakaLoop2
        
        xor ax,ax 
        mov ax,maxMahlaka   
        div kita ;get the max mahlaka number
        cmp ah,0
        je clearly ;if ah(modolu) equal 0 the max mahlaka is just al
        cmp al,0
        je mahlaka1 ;if al equal 0 its the first mahlaka (the maxMahlaka)
        
        mov dl,al ;print the number of the max mahlaka
        add dl,31h ;31 and not 30 because its start from 0 and we want it to atart from 1
        mov ah,2
        int 21h
        jmp con1
        
        clearly:
        mov dl,al  ;print the number of the max mahlaka
        add dl,30h 
        mov ah,2
        int 21h
        jmp con1
        
        mahlaka1:
        mov dl,'1' ;print the number of the max mahlaka
        mov ah,2
        int 21h
        
        con1:
        mov ah,9 ;print msg5
        lea dx,msg5                           
        int 21h
        xor ax,ax
        mov al,mahlaka
        sub ax,sizeOfPluga ;it will be just in al and not in ah
        mov mahlaka,al
        mov ax,maxKitaNumber
        div mahlaka ;get the max kita number because till now we had the maxnKitaNumber of the whole array
        cmp al,0
        je kita1 ;if the number is 0 its the first kita
        mov dl,al
        add dl,30h ;print the number of the kita
        mov ah,2
        int 21h 
        jmp con2
        
        kita1:  ;print if the maxKitaNumber is 1
        mov dl,'1'
        mov ah,2
        int 21h
        
        con2:
        lea dx,msg6 ;print msg6
        mov ah,9
        int 21h
        xor ah,ah
        mov al,maxKita
        push ax
        push bx
        push cx
        push dx
        mov bx,10 ;for divide in 10
        xor cx,cx
        convertLoop2:
            xor dx,dx
            div bx ;get one after one dig and push it so kater we will be able to print it accordint to the original order
            add dx,'0' ;become the number
            push dx
            inc cx
            cmp ax,0  ;divide in 10 and push till we have no more digits of maxKita
            jne convertLoop2
        printLoop2:
            pop dx ;will be just in dl
            mov ah,2 ;print the dig
            int 21h
            loop printLoop2
        
        pop dx
        pop cx
        pop bx
        pop ax            
    ret
endp maxMahlakaAndKitaSoldiers ;print the number of the mahlaka with the kita with the max soldiers
                               ;print the number of the kita with the max Soldiers
                               ;print the number of the soldiers of the kita with the max number of soldiers
                               
END

