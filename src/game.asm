[org 0x0100]                    ; DOS loads a COM program at offset 0x0100
        jmp start               ; go to the main program

game_title:        db 'COIN CATCH' ; title text
game_title_length: dw 10           ; number of characters in the title

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

start:
        call clear_screen       ; clear the screen before drawing the title

        mov ax, 35              ; center the ten-character title in 80 columns
        push ax
        mov ax, 4               ; title row, counting from zero
        push ax
        mov ax, 0x0e            ; bright yellow on black
        push ax
        mov ax, game_title      ; address of the title text
        push ax
        mov ax, [game_title_length] ; number of characters to print
        push ax
        call print_string       ; draw the title

        mov ax, 0x4c00          ; choose the DOS exit service with exit code 0
        int 0x21                ; return to the DOS prompt
