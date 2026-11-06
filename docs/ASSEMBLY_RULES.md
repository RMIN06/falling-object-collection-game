# Assembly Rules

These rules keep the code inside the course book (`docs/reference/book.txt`) and runnable on a real Intel 8088. Section numbers refer to the book's table of contents.

**Phase 1 only needs chapters 1 to 8.** Chapter 9 (timer and keyboard interrupt hooking) is for Phase 2 and must not be used in Phase 1.

## 1. Program skeleton

Same shape as every example in the book (section 1.7 and onwards):

```nasm
[org 0x0100]
        jmp start

; ---- data goes here (variables, strings, sprites) ----

; ---- subroutines go here ----

start:
        ; ---- main program goes here ----

        mov ax, 0x4c00          ; terminate program
        int 0x21
```

Assemble with `nasm src/game.asm -o build/game.com -l build/game.lst`.

## 2. Allowed

Everything below appears in the book's own examples. Use these freely.

| Group | What | Book section |
|---|---|---|
| Moving data | `mov`, `xchg` | ch 1, 2 |
| Arithmetic | `add`, `sub`, `inc`, `dec`, `mul`, `div` | ch 1, 4.3, 6.4, 6.5 |
| Comparing | `cmp`, `test` | 3.1 |
| Jumps | `jmp`, `je`, `jne`, `jz`, `jnz`, `ja`, `jae`, `jb`, `jbe`, `jl`, `jle`, `jg`, `jge`, `jc`, `jnc`, `jcxz`. Use `ja` and `jb` for unsigned numbers (all our values) | 3.2 |
| Loops | `loop` (count in `cx`) | ch 3 |
| Logic and bits | `and`, `or`, `xor` | 4.5, 4.6 |
| Shifts | `shl reg, 1` and `shr reg, 1`. For any bigger count, load the count in `cl` first (see section 4 of this file) | 4.2 |
| Subroutines | `call`, `ret`, `ret n`, `push`, `pop`, `bp` as frame pointer | ch 5 |
| String instructions | `cld`, `lodsb`, `stosw`, `movsw`, `rep` | ch 7 |
| Segment override | `[es:di]`, `[cs:var]` | 2.6, 6.2 |
| Video memory | segment `0xB800`, one word per screen cell, ASCII in the low byte, attribute in the high byte | 6.2 |
| Screen position | `offset = (y * 80 + x) * 2` | 6.5 |
| Keyboard | `mov ah, 0` then `int 0x16` returns the key in `al` (Enter is 13) | 8.3 |
| Exit | `mov ax, 0x4c00` then `int 0x21` | 1.7 |
| Data | `db`, `dw`, `times` | 2.1 |

## 3. Forbidden (will fail `tools/check_rules.sh`)

| Forbidden | Why |
|---|---|
| `pusha`, `popa` | Not on the 8088 |
| `push 5` (push with a number) | Not on the 8088. Put the number in a register first: `mov ax, 5` then `push ax`. `push word [var]` is fine because the book uses it |
| `shl ax, 3`, `shr ax, 2` (count other than 1) | Not on the 8088. Use `mov cl, 3` then `shl ax, cl` |
| `imul`, `movzx`, `movsx`, `enter`, `leave`, `bound` | Not on the 8088 |
| `eax`, `ebx`, `ecx`, `edx`, `esi`, `edi`, `ebp`, `esp` | 32-bit registers belong to the protected mode chapter, not our course so far |
| `equ`, `%define`, `%macro`, `%include`, `%assign`, `struc` | Not taught in the book |
| `proc`, `endp`, `.model`, `.data`, `.code`, `assume` | That is MASM style. The book uses NASM |
| Hooking `INT 8` or `INT 9`, using `in` / `out` | Chapter 9. Phase 2 only |
| Printing the game with `INT 10h` or `INT 21h` text services | We draw directly into video memory instead (chapter 6) |

## 4. Ask the student first

These exist on the 8088 but the book does not use them. Do not use them unless the student says yes: `lea`, `neg`, `not`, `cbw`, `cwd`, `sar`, `sal`, `xlat`, `loope`, `loopne`, anything from chapters 10 to 17.

### The shift by cl pattern (the 8088 way)

```nasm
        mov cl, 4               ; shift count goes in cl
        shr dx, cl              ; shift dx right by 4
```

Multiplying by 2 is simply `shl ax, 1` (book section 6.5).

## 5. How subroutines must look

This is exactly the style of the book's `printstr` (examples 6.2 and 6.4, chapter 5.5).

**Caller side:** push parameters one by one using a register, then `call`.

```nasm
        mov ax, 30
        push ax                 ; x position
        mov ax, 20
        push ax                 ; y position
        call some_routine
```

**Subroutine side:** set up `bp`, save every register you use, do the work, restore in reverse order, and clean the parameters with `ret n` where `n` is 2 times the number of parameters.

```nasm
some_routine:
        push bp
        mov bp, sp
        push ax                 ; save registers we use
        push bx

        mov ax, [bp+4]          ; last parameter pushed
        mov bx, [bp+6]          ; the one pushed before it
        ; ... work ...

        pop bx                  ; restore in reverse order
        pop ax
        pop bp
        ret 4                   ; 2 parameters x 2 bytes
```

Parameter positions after `push bp` and `mov bp, sp`:

| Place | Contains |
|---|---|
| `[bp+0]` | saved `bp` |
| `[bp+2]` | return address |
| `[bp+4]` | the **last** parameter pushed |
| `[bp+6]` | the one pushed before that |
| `[bp+8]`, `[bp+10]`, ... | earlier parameters, going up by 2 |

If a subroutine writes to the screen it saves and restores `es` too, and it sets `es` to `0xB800` itself (`mov ax, 0xb800` then `mov es, ax`), because the 8088 cannot load a segment register with a number directly (section 6.2).

## 6. Code style

- **One file**: `src/game.asm`. Order inside it: skeleton, data, subroutines, then `start:`.
- **Comment block above every subroutine**: what it does, parameters in the order they are pushed, and which registers it keeps safe.
- **Comment on every line** or every tight group of lines, in simple words, like the book's own examples.
- **Names**: lowercase with underscores. Subroutines are verbs (`draw_object`, `print_number`, `show_start_screen`). Variables are nouns (`score`, `time_left`, `bucket_x`).
- **No magic numbers**: any number that has a meaning is either a named variable in the data area or explained in a comment on that line (for example `mov di, 160 ; one row down is 80 words = 160 bytes`).
- **Small subroutines**: each does one job and should fit on one screen. Reuse them. Do not copy and paste a drawing loop.
- **Clear labels for loops and jumps**: `next_row`, `next_column`, `wait_for_enter`.
- **Direction flag**: call `cld` before using `lodsb`, `stosw`, `movsw`.

## 7. A note about the book text file

`docs/reference/book.txt` was extracted from a PDF, so a few lines contain glitches. For example example 6.4 shows `mull byte [bp+10]` and `mov dial`, which are really `mul byte [bp+10]` and `mov di, ax`. If a book line looks wrong, trust the surrounding explanation and ask the student.
