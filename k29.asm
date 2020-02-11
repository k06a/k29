; Swirl by k06a
; Dedicated to my wife 9ka
org   100h
; [106h] == 0

main:
    mov si, 100
    mov di, RRR

    ; Setting video mode 320x200x256
    mov al, 13h
    int 10h

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Enumerate all the screen points in 1 dimension ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    paint:
    push cx
        
        ; Register ES set to video memory
        mov ax, 0A000h
        mov es, ax
       
        mov bh, 0FAh ;mov  bx, 320*200
        mov ax, si
        lp1:
        
            mov cx, 160
            lp2:
                ; Store into DX the length of vector K1
                
                pusha
                    mul  ax
                    xchg ax, cx
                    mul  ax
                    add  ax, cx
                    xor  dx, dx
                    mov  bx, [kruch] ;mov  bx, 40    ; K1 = 40
                    div  bx
                    mov  bx, sp
                    mov  word [bx+10], ax
                popa
                
                ; Put in [sin] tg of an angle to K2
                
                fninit
                mov   word [si], ax    ; COS
                fild  word [si]
                mov   word [si], cx    ; SIN
                fild  word [si]
                fpatan
                fimul word [vnum]
                fmul  dword [glad]
                fist  word [si]
                add   dx, [si]
                
                ; Draw pixel
                dec  bx                
                mov  byte [es:bx], dl

            dec cx
            cmp cx, -160
            jg  lp2
            
        dec ax
        cmp al, -100
        jg  lp1
            
    pop cx

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Loop shift of pallete
    ; CL - durty, sicne starting position doesn't matter
    ; CH - MATTER!!! Speed of rotation
    loop_pal_out:
        add  cl, ch ; [DELTA]
        
        ;;;;;;;;;;;;;;;;;;;;;;;;
        ; CL - Cycled Shifting ;
        ; AL := 0, AH := XXh   ;
        ;;;;;;;;;;;;;;;;;;;;;;;;
        setPalette:
            xor  al, al ; To erase the flag
            setPalette_loop:
                mov  ah, al            
                
                cmp al, 0 ; was ah!!
                jl  no_inv
                not ah
                no_inv:
                
                shr  ah, 1
                add  al, cl ; + delta
                ;call setColor
                
                ;;;;;;;;;;;;;;;;;;;;;;;;;
                ; AL - Number on pllete ;
                ; AH - Grayscale color  ;
                ;;;;;;;;;;;;;;;;;;;;;;;;;
                setColor:
                pusha

                    mov dx, 03c8h
                    out dx, al
                    inc dx
                    
                    mov bx, di
                    mov cx, 3
                    mmm:               
                        mov al, ah
                        and al, [bx]
                        out dx, al
                        inc bx
                    loop mmm

                        
                popa
                ;;;;;;;;;;;;;;;;;;;;;;;;    
                
                sub  al, cl ; - delta
            
                inc  al
            jnz  setPalette_loop
        ;;;;;;;;;;;;;;;;;;;;;;;;
    
        ; Check key press
        mov  ah, 0Bh ; AX := 0B00h
        int  21h
        cmp  al, 0ffh

        jmp_loop_pal_out:
        jne  loop_pal_out

        ; Key press
        mov  ah, 08h
        int  21h

        label_push_space:
            cmp  al, ' '
            jne  label_push_left
            mov  ch, 0

        label_push_left:
            cmp  al, 75
            jne  label_push_right
            dec  ch

        label_push_right:
            cmp  al, 77
            jne  label_push_down
            inc  ch
    
        label_push_down:
            cmp  al, 80
            jne  label_push_up
            dec  [kruch]
            jnz  paint_me
            inc  [kruch]
            paint_me:
            jmp  paint

        label_push_up:
            cmp  al, 72
            jne  label_push_R
            inc  [kruch]
            jmp  paint
    
        label_push_R:
            cmp  al, 'r'
            jne  label_push_G
            not  byte [di]
            
        label_push_G:
            cmp  al, 'g'
            jne  label_push_B
            not  byte [di+1]
            
        label_push_B:
            cmp  al, 'b'
            jne  label_push_digit
            not  byte [di+2]
        
        label_push_digit:
            sub  al, '0'
            cmp  al, 9
            ja   label_push_esc
            mov  byte [vnum], al
            jmp  paint
        
        label_push_esc:
            cmp  al, 27-'0'
            jne  jmp_loop_pal_out
            ret
;main   endp

RRR   db 0
GGG   db 255
BBB   db 0

glad  dd 40.75 ; 163/4
vnum  dw 3
kruch dw 13

sign  db 'Dedicated to my wife 9'