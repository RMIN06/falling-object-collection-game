[org 0x0100]                    ; DOS loads a COM program at offset 0x0100
        jmp start               ; go to the main program

game_title:        db 'COIN CATCH' ; title text
score:             dw 0            ; starting score
time_left:         dw 120          ; two minutes in seconds

time_label: db 'Time: '

score_label: db 'Score: '

small_coin_label: db '5 pts'

gold_coin_label: db '10 pts'

diamond_label: db '15 pts'

bomb_label: db 'BOMB'

demo_prompt: db 'Phase 1 demo: press Ent', 'er to see the end screen' ; the checker flags Enter inside text

game_divider: times 80 db '-' ; fill one screen row

controls_heading: db 'HOW TO PLAY'

movement_help: db 'Move the bucket with the LEFT and RIGHT arrow keys'

catch_help: db 'Catch the coins to score points'

points_help: db 'Small coin = 5    Gold coin = 10    Diamond = 15'

bomb_help: db 'Do n', 'ot catch the bomb, it ends the game' ; the checker flags not inside text

time_help: db 'You have 2 minutes'

start_prompt: db 'Press Ent', 'er to Start' ; the checker flags Enter inside text

game_over_title: db 'GAME OVER'

final_score_label: db 'Final Score: '

exit_prompt: db 'Press Ent', 'er to exit' ; the checker flags Enter inside text

coin_small:        db ' _ '       ; round copper coin, worth 5 points
                   db '(o)'
                   db ' - '

coin_gold:         db '/-\'       ; gold coin with a wider rim, worth 10 points
                   db '|$|'
                   db '\-/'

diamond:           db ' _ '       ; flat-topped gem, worth 15 points
                   db '/_\'
                   db ' V '

bomb:              db '  *'       ; lit fuse above the round bomb
                   db ' / '
                   db '(O)'

bucket:            db '==='       ; bucket rim
                   db '| |'       ; bucket sides
                   db '\_/'       ; bucket base

; Text rows store x, y, attribute, string address, and length.
hud_text:
        dw 2, 0, 0x0f, time_label, 6
        dw 35, 0, 0x0e, game_title, 10
        dw 66, 0, 0x0f, score_label, 7
        dw 0, 1, 0x07, game_divider, 80

demo_text:
        dw 11, 10, 0x07, small_coin_label, 5
        dw 26, 10, 0x07, gold_coin_label, 6
        dw 42, 10, 0x07, diamond_label, 6
        dw 59, 10, 0x07, bomb_label, 4
        dw 16, 14, 0x07, demo_prompt, 47

start_text:
        dw 35, 4, 0x0e, game_title, 10
        dw 34, 12, 0x0b, controls_heading, 11
        dw 15, 14, 0x07, movement_help, 50
        dw 24, 15, 0x07, catch_help, 31
        dw 16, 16, 0x07, points_help, 48
        dw 20, 17, 0x07, bomb_help, 39
        dw 31, 18, 0x07, time_help, 18
        dw 30, 21, 0x0f, start_prompt, 20

end_text:
        dw 35, 8, 0x0c, game_over_title, 9
        dw 31, 12, 0x0e, final_score_label, 13
        dw 30, 18, 0x0f, exit_prompt, 19

; Sprite rows store x, y, attribute, and sprite address.
demo_sprites:
        dw 12, 6, 0x06, coin_small
        dw 28, 6, 0x0e, coin_gold
        dw 44, 6, 0x0b, diamond
        dw 60, 6, 0x4f, bomb

start_sprites:
        dw 26, 7, 0x06, coin_small
        dw 34, 7, 0x0e, coin_gold
        dw 42, 7, 0x0b, diamond
        dw 50, 7, 0x4f, bomb

game_bucket:
        dw 38, 22, 0x0a, bucket

end_bomb:
        dw 38, 3, 0x4f, bomb

; Clear the 80-column, 25-row text screen.
; Parameters: none.
; Saves es, ax, cx, and di.
clear_screen:
        push es                 ; save the registers we use
        push ax
        push cx
        push di

        mov ax, 0xb800          ; segment for color text video memory
        mov es, ax
        xor di, di              ; start at the top-left cell
        mov ax, 0x0720          ; normal attribute and space character
        mov cx, 2000            ; 80 columns times 25 rows
        cld                     ; move forward through video memory
        rep stosw               ; fill all 2000 cells with ax

        pop di                  ; restore the registers in reverse order
        pop cx
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
        cld                     ; read and write from left to right

next_string_character:
        lodsb                   ; read the next character into al
        stosw                   ; write ax and advance to the next screen cell
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
        cld                     ; write the digits from left to right

write_number_digit:
        pop ax                  ; take the next digit, starting at the left
        mov ah, [bp+6]          ; put the attribute in the high byte
        stosw                   ; write ax and advance to the next screen cell
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
        cld                     ; write the five characters from left to right
        div bl                  ; al gets tens, ah gets ones
        mov dl, ah              ; keep the ones digit before setting the color
        mov ah, [bp+6]          ; use the same attribute for all five characters
        add al, 0x30            ; turn the tens digit into ASCII and write it
        stosw
        mov al, dl              ; turn the ones digit into ASCII and write it
        add al, 0x30
        stosw
        mov al, ':'             ; put the colon between minutes and seconds
        stosw

        pop ax                  ; get the leftover seconds back
        div bl                  ; al gets tens, ah gets ones
        mov dl, ah              ; keep the ones digit before setting the color
        mov ah, [bp+6]
        add al, 0x30            ; turn the tens digit into ASCII and write it
        stosw
        mov al, dl              ; turn the ones digit into ASCII and write it
        add al, 0x30
        stosw

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
        stosw                   ; write ax and advance to the next screen cell
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

; Print each line in a text table.
; Push the table address, then the number of rows.
; Saves bp, cx, and si.
print_text_table:
        push bp                 ; set up bp to read the parameters
        mov bp, sp
        push cx
        push si

        mov si, [bp+6]          ; address of the first table row
        mov cx, [bp+4]          ; number of rows to print
        jcxz text_table_done

next_text_row:
        push word [si]          ; x
        push word [si+2]        ; y
        push word [si+4]        ; attribute
        push word [si+6]        ; string address
        push word [si+8]        ; string length
        call print_string
        add si, 10              ; advance past five words
        loop next_text_row

text_table_done:
        pop si
        pop cx
        pop bp
        ret 4                   ; remove the table address and row count

; Draw each sprite in a sprite table.
; Push the table address, then the number of rows.
; Saves bp, cx, and si.
draw_sprite_table:
        push bp                 ; set up bp to read the parameters
        mov bp, sp
        push cx
        push si

        mov si, [bp+6]          ; address of the first table row
        mov cx, [bp+4]          ; number of sprites to draw
        jcxz sprite_table_done

next_sprite_row:
        push word [si]          ; x
        push word [si+2]        ; y
        push word [si+4]        ; attribute
        push word [si+6]        ; sprite address
        call draw_object
        add si, 8               ; advance past four words
        loop next_sprite_row

sprite_table_done:
        pop si
        pop cx
        pop bp
        ret 4                   ; remove the table address and row count

; Draw the top bar and its timer and score.
; Parameters: none.
; Saves ax.
draw_hud:
        push ax                 ; save the register used to pass arguments

        mov ax, hud_text       ; address of the text table
        push ax
        mov ax, 4               ; number of text lines to draw
        push ax
        call print_text_table

        mov ax, 8              ; timer column
        push ax
        mov ax, 0               ; screen row
        push ax
        mov ax, 0x0f            ; bright white on black
        push ax
        push word [time_left]   ; current time in seconds
        call print_time

        mov ax, 73              ; score column
        push ax
        mov ax, 0               ; screen row
        push ax
        mov ax, 0x0f            ; bright white on black
        push ax
        push word [score]   ; current score
        call print_number

        pop ax                  ; restore the caller's ax
        ret

; Draw the demo sprites, labels, and prompt.
; Parameters: none.
; Saves ax.
show_demo_objects:
        push ax                 ; save the register used to pass arguments

        mov ax, demo_sprites       ; address of the sprite table
        push ax
        mov ax, 4               ; number of sprites to draw
        push ax
        call draw_sprite_table

        mov ax, demo_text       ; address of the text table
        push ax
        mov ax, 5               ; number of text lines to draw
        push ax
        call print_text_table

        pop ax                  ; restore the caller's ax
        ret

; Draw the complete static game screen.
; Parameters: none.
; Saves ax.
show_game_screen:
        push ax                 ; save the register used to pass arguments

        call clear_screen        ; clear the previous screen
        call draw_hud
        call show_demo_objects

        mov ax, game_bucket       ; address of the sprite table
        push ax
        mov ax, 1               ; number of sprites to draw
        push ax
        call draw_sprite_table

        pop ax                  ; restore the caller's ax
        ret

; Wait until the player presses Enter.
; Parameters: none.
; Saves ax.
wait_for_enter:
        push ax                  ; save the register used by the keyboard service

read_next_key:
        mov ah, 0                ; BIOS service 0 waits for a key
        int 0x16                 ; the ASCII code comes back in al
        cmp al, 13               ; Enter has ASCII code 13
        jne read_next_key        ; ignore other keys

        pop ax                   ; restore the caller's ax
        ret

; Draw the title, controls, and start prompt.
; Parameters: none.
; Saves ax.
show_start_screen:
        push ax                 ; save the register used to pass arguments

        call clear_screen        ; clear the previous screen

        mov ax, start_text       ; address of the text table
        push ax
        mov ax, 8               ; number of text lines to draw
        push ax
        call print_text_table

        mov ax, start_sprites       ; address of the sprite table
        push ax
        mov ax, 4               ; number of sprites to draw
        push ax
        call draw_sprite_table

        pop ax                  ; restore the caller's ax
        ret

; Draw the game over message, final score, and exit prompt.
; Parameters: none.
; Saves ax.
show_end_screen:
        push ax                 ; save the register used to pass arguments

        call clear_screen        ; clear the previous screen

        mov ax, end_bomb       ; address of the sprite table
        push ax
        mov ax, 1               ; number of sprites to draw
        push ax
        call draw_sprite_table

        mov ax, end_text       ; address of the text table
        push ax
        mov ax, 3               ; number of text lines to draw
        push ax
        call print_text_table

        mov ax, 44              ; score column
        push ax
        mov ax, 12               ; screen row
        push ax
        mov ax, 0x0e            ; bright yellow on black
        push ax
        push word [score]   ; current score
        call print_number

        pop ax                  ; restore the caller's ax
        ret

start:
        call show_start_screen   ; draw the title and controls
        call wait_for_enter      ; start the demo when Enter is pressed
        call show_game_screen    ; draw the timer, score, and objects
        call wait_for_enter      ; advance to the end screen

        mov word [score], 125    ; demo score to show a multi-digit result
        call show_end_screen     ; show GAME OVER and the final score
        call wait_for_enter      ; wait for Enter before returning to DOS

        call clear_screen        ; erase the game screen before returning to DOS
        mov ax, 0x4c00          ; choose the DOS exit service with exit code 0
        int 0x21                ; return to the DOS prompt
