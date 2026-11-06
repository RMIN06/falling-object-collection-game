[org 0x0100]                    ; DOS loads a COM program at offset 0x0100
        jmp start               ; go to the main program

; Data goes here.

; Subroutines go here.

start:
        mov ax, 0x4c00          ; choose the DOS exit service with exit code 0
        int 0x21                ; return to the DOS prompt
