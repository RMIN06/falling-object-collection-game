[org 0x0100]                    ; DOS loads a COM program at offset 0x0100
        jmp start               ; go to the main program

; Data goes here.

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

start:
        call clear_screen       ; clear the screen before returning to DOS
        mov ax, 0x4c00          ; choose the DOS exit service with exit code 0
        int 0x21                ; return to the DOS prompt
