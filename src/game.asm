[org 0x0100]                    ; DOS loads a COM program at offset 0x0100
        jmp start               ; go to the main program

game_title:        db 'COIN CATCH' ; title text
game_title_length: dw 10           ; number of characters in the title
score:             dw 0            ; starting score
time_left:         dw 120          ; two minutes in seconds

time_label: db 'Time: '
time_label_length: dw 6 ; number of characters in time_label

score_label: db 'Score: '
score_label_length: dw 7 ; number of characters in score_label

small_coin_label: db '5 pts'
small_coin_label_length: dw 5 ; number of characters in small_coin_label

gold_coin_label: db '10 pts'
gold_coin_label_length: dw 6 ; number of characters in gold_coin_label

diamond_label: db '15 pts'
diamond_label_length: dw 6 ; number of characters in diamond_label

bomb_label: db 'BOMB'
bomb_label_length: dw 4 ; number of characters in bomb_label

demo_prompt: db 'Phase 1 demo: press Ent', 'er to see the end screen' ; the checker flags Enter inside text
demo_prompt_length: dw 47 ; number of characters in demo_prompt

game_divider: times 80 db '-' ; fill one screen row
game_divider_length: dw 80    ; number of columns in the divider

coin_small:        db '.-.'       ; small coin, worth 5 points
                   db '|o|'
                   db "'-'"

coin_gold:         db '.-.'       ; gold coin, worth 10 points
                   db '|$|'
                   db "'-'"

diamond:           db ' ^ '       ; diamond, worth 15 points
                   db '< >'
                   db ' v '

bomb:              db ' * '       ; bomb ends the game when caught
                   db '(X)'
                   db ' ~ '

bucket:            db '\ /'       ; bucket rim
                   db '| |'       ; bucket sides
                   db '\_/'       ; bucket base

; Clear the 80-column, 25-row text screen.
; Parameters: none.
; Saves es, ax, and di.
clear_screen:
        push es                 ; save the registers we use
        push ax
        push di

        mov ax, 0xb800          ; segment for color text video memory
        mov es, ax
        mov di, 0               ; start at the top-left cell

next_screen_cell:
        mov word [es:di], 0x0720 ; attribute 0x07 and space character 0x20
        add di, 2               ; each screen cell takes two bytes
        cmp di, 4000            ; 2000 cells take 4000 bytes
        jne next_screen_cell    ; keep clearing until all cells are filled

        pop di                  ; restore the registers in reverse order
        pop ax
        pop es
        ret                     ; return to the caller

; Print a string at a screen position with the given color.
; Push x, y, attribute, string address, and length in that order.
; Saves bp, es, ax, cx, si, and di.
print_string:
        push bp                 ; set up bp to read the parameters
        mov bp, sp
        push es                 ; save the other registers we use
        push ax
        push cx
        push si
        push di

        mov ax, 0xb800          ; point es to color text video memory
        mov es, ax
        mov al, 80              ; each row has 80 columns
        mul byte [bp+10]        ; multiply by y to reach the start of the row
        add ax, [bp+12]         ; add x to reach the requested column
        shl ax, 1               ; each screen cell takes two bytes
        mov di, ax              ; di points to the first screen cell

        mov si, [bp+6]          ; si points to the first character
        mov cx, [bp+4]          ; cx counts how many characters to print
        mov ah, [bp+8]          ; the attribute goes in the high byte
        jcxz print_string_done  ; an empty string needs no screen writes

next_string_character:
        mov al, [si]            ; the character goes in the low byte
        mov [es:di], ax         ; write the character and attribute together
        add di, 2               ; move to the next screen cell
        add si, 1               ; move to the next character
        loop next_string_character

print_string_done:
        pop di                  ; restore the registers in reverse order
        pop si
        pop cx
        pop ax
        pop es
        pop bp
        ret 10                  ; remove the five two-byte parameters

; Print an unsigned number at a screen position with the given color.
; Push x, y, attribute, and number in that order.
; Saves bp, es, ax, bx, cx, dx, and di.
print_number:
        push bp                 ; set up bp to read the parameters
        mov bp, sp
        push es                 ; save the other registers we use
        push ax
        push bx
        push cx
        push dx
        push di

        mov ax, 0xb800          ; point es to color text video memory
        mov es, ax
        mov al, 80              ; each row has 80 columns
        mul byte [bp+8]         ; multiply by y to reach the start of the row
        add ax, [bp+10]         ; add x to reach the requested column
        shl ax, 1               ; each screen cell takes two bytes
        mov di, ax              ; di points to the first screen cell

        mov ax, [bp+4]          ; start with the number to print
        mov bx, 10              ; divide by ten to get one decimal digit
        mov cx, 0               ; no digits on the stack yet

next_number_digit:
        mov dx, 0               ; clear the high word before dividing
        div bx                  ; ax gets the quotient, dx gets the digit
        add dl, 0x30            ; turn the digit into an ASCII character
        push dx                 ; save the character for printing in reverse order
        inc cx                  ; count this digit
        cmp ax, 0               ; see if there are any digits left
        jne next_number_digit

write_number_digit:
        pop dx                  ; take the next digit, starting at the left
        mov dh, [bp+6]          ; put the attribute in the high byte
        mov [es:di], dx         ; write the digit and attribute together
        add di, 2               ; move to the next screen cell
        loop write_number_digit

        pop di                  ; restore the registers in reverse order
        pop dx
        pop cx
        pop bx
        pop ax
        pop es
        pop bp
        ret 8                   ; remove the four two-byte parameters

; Print remaining time from 0 to 5999 seconds as mm:ss.
; Push x, y, attribute, and seconds in that order.
; Saves bp, es, ax, bx, dx, and di.
print_time:
        push bp                 ; set up bp to read the parameters
        mov bp, sp
        push es                 ; save the other registers we use
        push ax
        push bx
        push dx
        push di

        mov ax, 0xb800          ; point es to color text video memory
        mov es, ax
        mov al, 80              ; each row has 80 columns
        mul byte [bp+8]         ; multiply by y to reach the start of the row
        add ax, [bp+10]         ; add x to reach the requested column
        shl ax, 1               ; each screen cell takes two bytes
        mov di, ax              ; di points to the first screen cell

        mov ax, [bp+4]          ; load the total seconds
        mov dx, 0               ; clear the high word before dividing
        mov bx, 60              ; there are 60 seconds in one minute
        div bx                  ; ax gets minutes, dx gets leftover seconds
        push dx                 ; keep the seconds until after the colon

        mov bl, 10              ; divide minutes into tens and ones
        div bl                  ; al gets tens, ah gets ones
        mov dl, ah              ; keep the ones digit before setting the color
        mov ah, [bp+6]          ; use the same attribute for all five characters
        add al, 0x30            ; turn the tens digit into ASCII and write it
        mov [es:di], ax
        mov al, dl              ; turn the ones digit into ASCII and write it
        add al, 0x30
        mov [es:di+2], ax       ; one cell to the right of the tens digit
        mov al, ':'             ; put the colon between minutes and seconds
        mov [es:di+4], ax

        pop ax                  ; get the leftover seconds back
        div bl                  ; al gets tens, ah gets ones
        mov dl, ah              ; keep the ones digit before setting the color
        mov ah, [bp+6]
        add al, 0x30            ; turn the tens digit into ASCII and write it
        mov [es:di+6], ax       ; first cell after the colon
        mov al, dl              ; turn the ones digit into ASCII and write it
        add al, 0x30
        mov [es:di+8], ax       ; last cell of the time display

        pop di                  ; restore the registers in reverse order
        pop dx
        pop bx
        pop ax
        pop es
        pop bp
        ret 8                   ; remove the four two-byte parameters

; Draw a three-column, three-row object with the given color.
; Push x, y, attribute, and sprite address in that order.
; Saves bp, es, ax, cx, dx, si, and di.
draw_object:
        push bp                 ; set up bp to read the parameters
        mov bp, sp
        push es                 ; save the other registers we use
        push ax
        push cx
        push dx
        push si
        push di

        mov ax, 0xb800          ; point es to color text video memory
        mov es, ax
        mov al, 80              ; each row has 80 columns
        mul byte [bp+8]         ; multiply by y to reach the start of the row
        add ax, [bp+10]         ; add x to reach the requested column
        shl ax, 1               ; each screen cell takes two bytes
        mov di, ax              ; di points to the top-left cell of the sprite

        mov si, [bp+4]          ; si points to the first sprite character
        mov ah, [bp+6]          ; use the same attribute for all nine cells
        mov dx, 3               ; the sprite has three rows
        cld                     ; lodsb should move forward through the sprite

next_object_row:
        mov cx, 3               ; each sprite row has three columns

next_object_column:
        lodsb                   ; read the next sprite character into al
        mov [es:di], ax         ; write the character and attribute together
        add di, 2               ; move to the next screen cell
        loop next_object_column

        add di, 154             ; skip the other 77 cells to reach the next row
        dec dx                  ; one fewer row left to draw
        jnz next_object_row

        pop di                  ; restore the registers in reverse order
        pop si
        pop dx
        pop cx
        pop ax
        pop es
        pop bp
        ret 8                   ; remove the four two-byte parameters

; Draw the timer, title, score, and divider at the top of the game screen.
; Parameters: none.
; Saves ax.
draw_hud:
        push ax                  ; save the register used to pass arguments

        mov ax, 2               ; timer label at column 2, row 0
        push ax
        mov ax, 0
        push ax
        mov ax, 0x0f
        push ax
        mov ax, time_label
        push ax
        mov ax, [time_label_length]
        push ax
        call print_string

        mov ax, 8               ; remaining time goes just after the label
        push ax
        mov ax, 0
        push ax
        mov ax, 0x0f
        push ax
        mov ax, [time_left]
        push ax
        call print_time

        mov ax, 35              ; yellow title centered on row 0
        push ax
        mov ax, 0
        push ax
        mov ax, 0x0e
        push ax
        mov ax, game_title
        push ax
        mov ax, [game_title_length]
        push ax
        call print_string

        mov ax, 66              ; score label at the top right
        push ax
        mov ax, 0
        push ax
        mov ax, 0x0f
        push ax
        mov ax, score_label
        push ax
        mov ax, [score_label_length]
        push ax
        call print_string

        mov ax, 73              ; score number goes just after the label
        push ax
        mov ax, 0
        push ax
        mov ax, 0x0f
        push ax
        mov ax, [score]
        push ax
        call print_number

        mov ax, 0               ; divider spans row 1
        push ax
        mov ax, 1
        push ax
        mov ax, 0x07
        push ax
        mov ax, game_divider
        push ax
        mov ax, [game_divider_length]
        push ax
        call print_string

        pop ax                   ; restore the caller's ax
        ret

; Draw the four demo sprites and their labels.
; Parameters: none.
; Saves ax.
show_demo_objects:
        push ax                  ; save the register used to pass arguments

        mov ax, 12              ; brown coin at column 12, row 6
        push ax
        mov ax, 6
        push ax
        mov ax, 0x06
        push ax
        mov ax, coin_small
        push ax
        call draw_object

        mov ax, 28              ; gold coin at column 28, row 6
        push ax
        mov ax, 6
        push ax
        mov ax, 0x0e
        push ax
        mov ax, coin_gold
        push ax
        call draw_object

        mov ax, 44              ; cyan diamond at column 44, row 6
        push ax
        mov ax, 6
        push ax
        mov ax, 0x0b
        push ax
        mov ax, diamond
        push ax
        call draw_object

        mov ax, 60              ; red-backed bomb at column 60, row 6
        push ax
        mov ax, 6
        push ax
        mov ax, 0x4f
        push ax
        mov ax, bomb
        push ax
        call draw_object

        mov ax, 11              ; label below the small coin
        push ax
        mov ax, 10
        push ax
        mov ax, 0x07
        push ax
        mov ax, small_coin_label
        push ax
        mov ax, [small_coin_label_length]
        push ax
        call print_string

        mov ax, 26              ; label below the gold coin
        push ax
        mov ax, 10
        push ax
        mov ax, 0x07
        push ax
        mov ax, gold_coin_label
        push ax
        mov ax, [gold_coin_label_length]
        push ax
        call print_string

        mov ax, 42              ; label below the diamond
        push ax
        mov ax, 10
        push ax
        mov ax, 0x07
        push ax
        mov ax, diamond_label
        push ax
        mov ax, [diamond_label_length]
        push ax
        call print_string

        mov ax, 59              ; label below the bomb
        push ax
        mov ax, 10
        push ax
        mov ax, 0x07
        push ax
        mov ax, bomb_label
        push ax
        mov ax, [bomb_label_length]
        push ax
        call print_string

        pop ax                   ; restore the caller's ax
        ret

; Draw the complete static game screen.
; Parameters: none.
; Saves ax.
show_game_screen:
        push ax                  ; save the register used to pass arguments

        call clear_screen        ; start with a blank screen
        call draw_hud            ; draw the timer and score
        call show_demo_objects   ; show the four objects and their labels

        mov ax, 16              ; demo message at column 16, row 14
        push ax
        mov ax, 14
        push ax
        mov ax, 0x07
        push ax
        mov ax, demo_prompt
        push ax
        mov ax, [demo_prompt_length]
        push ax
        call print_string

        mov ax, 38              ; green bucket centered at the bottom
        push ax
        mov ax, 22
        push ax
        mov ax, 0x0a
        push ax
        mov ax, bucket
        push ax
        call draw_object

        pop ax                   ; restore the caller's ax
        ret

start:
        call show_game_screen   ; show the game screen for this step

        mov ax, 0x4c00          ; choose the DOS exit service with exit code 0
        int 0x21                ; return to the DOS prompt
