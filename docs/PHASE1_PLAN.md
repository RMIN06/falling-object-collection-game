# Phase 1 Plan

**Goal:** show the interface and every game object. No gameplay yet.
**Deadline:** 11:59 pm, Sunday 8 November 2026.

Follow the steps at the bottom in order. One step, one commit, then stop and let the student test.

## 1. What Phase 1 delivers

```
START SCREEN --Enter--> GAME SCREEN (static) --Enter--> END SCREEN --Enter--> exit to DOS
```

- **Start screen:** game name, graphics, instructions, "Press Enter to Start". Nothing starts until Enter.
- **Game screen:** top bar with timer (shows `02:00`) and live score (top-right, shows `0`), plus a showcase of every object (three score objects, the bomb) and the bucket at the bottom. Nothing moves yet.
- **End screen:** "GAME OVER" and a final score.
- Every object is drawn in a **3x3 space**.

The game screen showcase and the "press Enter to see the end screen" line are temporary demo pieces. Phase 2 will replace them with real falling objects. Keep them in one subroutine (`show_demo_objects`) so they are easy to delete later.

## 2. Screen basics

Text mode 80 columns by 25 rows. Video memory starts at segment `0xB800`. One screen cell is one word: ASCII in the low byte, attribute in the high byte. Offset of cell (x, y) is `(y * 80 + x) * 2` (book 6.2 and 6.5). Columns are 0 to 79, rows are 0 to 24.

Attributes to use (book 6.2: background in the high nibble, foreground in the low nibble):

| Use | Attribute |
|---|---|
| Normal text | `0x07` |
| Bright white (HUD, prompts) | `0x0F` |
| Bright yellow (title, gold coin, final score) | `0x0E` |
| Brown (small coin) | `0x06` |
| Bright cyan (diamond, headings) | `0x0B` |
| White on red (bomb) | `0x4F` |
| Bright red ("GAME OVER") | `0x0C` |
| Bright green (bucket) | `0x0A` |

## 3. The 3x3 sprites

Each sprite is **nine bytes in a row**: three `db` lines of three characters each, top row first. Use plain ASCII only. Spaces count, they are drawn too.

```nasm
coin_small:     db '.-.'          ; small coin, 5 points, attribute 0x06
                db '|o|'
                db "'-'"

coin_gold:      db '.-.'          ; gold coin, 10 points, attribute 0x0E
                db '|$|'
                db "'-'"

diamond:        db ' ^ '          ; diamond, 15 points, attribute 0x0B
                db '< >'
                db ' v '

bomb:           db ' * '          ; bomb, ends the game, attribute 0x4F
                db '(X)'
                db ' ~ '

bucket:         db '\ /'          ; player, attribute 0x0A
                db '| |'
                db '\_/'
```

The attribute is passed to the drawing routine, not stored in the sprite. If the student wants different shapes, any 3x3 ASCII design is fine as long as the four object types look clearly different from each other and the bomb stays obviously dangerous.

## 4. Screen layouts

All positions are (x, y) of the top-left cell. Text is placed with `print_string`. Centered text uses `x = (80 - length) / 2`, already worked out below.

### Start screen

| Row | Content | x | Attribute |
|---|---|---|---|
| 4 | `COIN CATCH` | 35 | `0x0E` |
| 7 to 9 | sprites side by side: `coin_small` x=26, `coin_gold` x=34, `diamond` x=42, `bomb` x=50 | as listed | each its own |
| 12 | `HOW TO PLAY` | 34 | `0x0B` |
| 14 | `Move the bucket with the LEFT and RIGHT arrow keys` | 15 | `0x07` |
| 15 | `Catch the coins to score points` | 24 | `0x07` |
| 16 | `Small coin = 5    Gold coin = 10    Diamond = 15` | 16 | `0x07` |
| 17 | `Do not catch the bomb, it ends the game` | 20 | `0x07` |
| 18 | `You have 2 minutes` | 31 | `0x07` |
| 21 | `Press Enter to Start` | 30 | `0x0F` (optional blinking: `0x8F`) |

### Game screen

| Row | Content | x | Attribute |
|---|---|---|---|
| 0 | `Time: ` then the time as `02:00` | label 2, time 8 | `0x0F` |
| 0 | `COIN CATCH` | 35 | `0x0E` |
| 0 | `Score: ` then the score number | label 66, number 73 | `0x0F` |
| 1 | divider line of 80 `-` characters | 0 | `0x07` |
| 6 to 8 | demo sprites: `coin_small` x=12, `coin_gold` x=28, `diamond` x=44, `bomb` x=60 | as listed | each its own |
| 10 | labels under them: `5 pts` x=11, `10 pts` x=26, `15 pts` x=42, `BOMB` x=59 | as listed | `0x07` |
| 14 | `Phase 1 demo: press Enter to see the end screen` | 16 | `0x07` |
| 22 to 24 | `bucket` at x=38 | 38 | `0x0A` |

The score sits at the **top-right** because the teacher requires it there in Phase 2. The number is left-aligned at x=73 so up to five digits fit before column 79.

### End screen

| Row | Content | x | Attribute |
|---|---|---|---|
| 3 to 5 | `bomb` sprite | 38 | `0x4F` |
| 8 | `GAME OVER` | 35 | `0x0C` |
| 12 | `Final Score: ` then the score number | label 31, number 44 | `0x0E` |
| 18 | `Press Enter to exit` | 30 | `0x0F` |

For the Phase 1 demo, when the student presses Enter on the game screen the program sets `score` to `125` (comment it clearly as a demo value) so the end screen proves that multi-digit numbers print correctly. Phase 2 will calculate the real score.

## 5. Data (variables) to define

```nasm
score:      dw 0          ; live score, starts at 0
time_left:  dw 120        ; remaining seconds, 2 minutes (only displayed in Phase 1)
```

Strings use `db` plus a length, exactly like the book's `message` and `length` in example 6.2. Define the 80-character divider with `times 80 db '-'`.

## 6. Subroutines to write

Each one follows the style in `docs/ASSEMBLY_RULES.md` section 5 (parameters on the stack, `bp` frame, save and restore registers, `ret n`).

| Subroutine | Parameters (push in this order) | `ret` | Based on |
|---|---|---|---|
| `clear_screen` | none | `ret` | book 6.2 `clrscr` |
| `print_string` | x, y, attribute, string address, length | `ret 10` | book 6.5 example 6.4 `printstr` |
| `print_number` | x, y, attribute, number | `ret 8` | book 6.4 example 6.3 `printnum` plus the x, y, attribute idea from 6.5 |
| `print_time` | x, y, attribute, seconds | `ret 8` | uses `div` like `print_number`. Prints `mm:ss`, so 120 shows as `02:00` |
| `draw_object` | x, y, attribute, sprite address | `ret 8` | see below |
| `draw_hud` | none (reads `score` and `time_left`) | `ret` | calls `print_string`, `print_time`, `print_number` |
| `wait_for_enter` | none | `ret` | book 8.3 keyboard service |
| `show_start_screen`, `show_game_screen`, `show_end_screen` | none | `ret` | calls the routines above |
| `show_demo_objects` | none | `ret` | draws the four demo sprites and labels. Phase 2 deletes it |

### How `draw_object` works

1. Work out the offset of the top-left cell: `di = (y * 80 + x) * 2` with `mul` and `shl ax, 1`, as in example 6.4.
2. Point `si` at the sprite, and put the attribute in `ah`.
3. For each of 3 rows, for each of 3 columns: load the next sprite character into `al` (`lodsb`), then write the word `ax` to video memory (`stosw`, or `mov [es:di], ax` and `add di, 2`).
4. After the 3 characters of a row, jump `di` to the start of the next row. The row is 80 cells wide and we already moved 3, so add `(80 - 3) * 2 = 154` bytes.
5. Use `cx` for the columns and `dx` (or another saved register) for the rows. Call `cld` first.

### How `wait_for_enter` works

```nasm
wait_for_enter:
        mov ah, 0               ; service 0 - wait for a key
        int 0x16                ; BIOS keyboard service, key comes back in al
        cmp al, 13              ; 13 is the Enter key
        jne wait_for_enter      ; any other key, keep waiting
        ret
```

## 7. Steps

Tick a box here when the step is done and committed. Commit wording is in `docs/COMMIT_GUIDE.md`, step numbers match.

- [x] **Step 0: project setup.** Run `git init` if there is no repo yet, then install the commit hook from `docs/COMMIT_GUIDE.md`. The `.gitignore` and `README.md` are already provided. Create `src/game.asm` with only the skeleton from `ASSEMBLY_RULES.md` section 1 so it assembles and exits. *Student sees:* nothing, the program just returns to DOS.
- [x] **Step 1: `clear_screen`.** Fill all 2000 cells with a space and attribute `0x07`. Test by calling it from `start:`. *Student sees:* a blank screen.
- [x] **Step 2: `print_string`.** Add the five-parameter routine. Test by printing `COIN CATCH` in yellow at (35, 4). *Student sees:* the title in the middle.
- [x] **Step 3: `print_number`.** Print `125` at (10, 10), then `0` and `45821` to prove one-digit and five-digit numbers work. *Student sees:* the numbers.
- [ ] **Step 4: `print_time`.** Add `time_left` and print `120` as `02:00`, then test `75` as `01:15` and `9` as `00:09`. *Student sees:* correctly formatted times.
- [ ] **Step 5: `draw_object` with the bucket.** Add the `bucket` sprite and draw it at (38, 22). *Student sees:* a green 3x3 bucket at the bottom center.
- [ ] **Step 6: the other sprites.** Add `coin_small`, `coin_gold`, `diamond`, `bomb`. Draw all five in a quick test. Check all five fit in 3x3 and look different. *Student sees:* five distinct objects.
- [ ] **Step 7: game screen.** Write `draw_hud`, `show_demo_objects` and `show_game_screen` following section 4. *Student sees:* the full game screen with timer `02:00`, score `0` at the top-right, the four demo objects with labels, and the bucket.
- [ ] **Step 8: start screen.** Write `wait_for_enter` and `show_start_screen`. *Student sees:* the title screen, and nothing happens until Enter is pressed.
- [ ] **Step 9: end screen.** Write `show_end_screen`. *Student sees:* GAME OVER and the final score.
- [ ] **Step 10: connect the flow.** In `start:` call: `show_start_screen`, `wait_for_enter`, `show_game_screen`, `wait_for_enter`, set `score` to the demo value `125`, `show_end_screen`, `wait_for_enter`, exit. *Student sees:* the whole Phase 1 flow from start to end.
- [ ] **Step 11: final check.** Read the whole file once. Make sure every subroutine has its comment block, names are meaningful, and `check_rules.sh` prints `OK`. Walk through the checklist below and tell the student which items pass. Update `README.md` if anything changed. *Student sees:* the same game, tidier code.

## 8. Phase 1 acceptance checklist

| # | Teacher requirement | Where it is covered | Done |
|---|---|---|---|
| 1 | All three object categories displayed | Game screen: score objects, bucket, bomb | [ ] |
| 2 | Every object in a 3x3 space | `draw_object` and the 3-line sprites | [ ] |
| 3 | Timer on screen showing remaining time | `print_time` in `draw_hud`, shows `02:00` | [ ] |
| 4 | Live score display present | `print_number` in `draw_hud` at top-right, and on the end screen | [ ] |
| 5 | Start screen with name, instructions, "Press Enter to Start", and the game begins only on Enter | `show_start_screen` and `wait_for_enter` | [ ] |
| 6 | End screen showing game over and final score | `show_end_screen` | [ ] |
| 7 | Assembles with no errors or warnings | `nasm` output | [ ] |
| 8 | Nothing outside the book | `bash tools/check_rules.sh` says `OK` | [ ] |

## 9. Not in Phase 1 (do not build, only keep in mind)

- Falling objects, left/right movement, collisions, real scoring.
- The real countdown. In Phase 2 it will come from hooking the timer interrupt (book 9.4, example 9.7) and the arrow keys from hooking the keyboard interrupt (book 9.2 and example 9.4).
- Because of that, keep `draw_object` general (any x, any y, any sprite, any attribute) so Phase 2 can reuse it by just changing `y`.
