# AGENTS.md

Instructions for Codex. Read this whole file before doing anything, then read the four files in `docs/` listed below.

## The project in one paragraph

A falling object game called **Coin Catch**, written in Intel 8088 assembly (NASM, DOS `.COM` file, runs in DOSBox). It is a university COAL course project. The player moves a bucket left and right to catch falling coins and avoid bombs. We are building it in two phases. **You are working on Phase 1 only.**

## Who you are helping

A student learning assembly for the **first time**. The code must be easy to read and easy to explain out loud in a viva. If a classmate who just finished the first few chapters cannot follow a line, rewrite it simpler.

## The three hard rules

1. **Stay inside the book.** The only reference is the course book at `docs/reference/book.txt` (Belal Hashmi's lecture notes, text version of the PDF). If an instruction, directive, interrupt service or technique is not used or taught in the book, do not use it. When unsure, search the book with `grep -n -i "word" docs/reference/book.txt`. If you still cannot find it, **stop and ask the student**. Do not guess.
2. **Keep it beginner simple.** One file, short subroutines, plain loops, no clever tricks. A longer simple solution always beats a shorter clever one.
3. **Phase 1 only.** Do not build falling objects, movement, collision, or the real countdown. Those are Phase 2. Do not add anything the Phase 1 plan does not list.

## Read these first, in this order

| File | What it tells you |
|---|---|
| `docs/PROJECT_SPEC.md` | What the teacher asked for (both phases) |
| `docs/ASSEMBLY_RULES.md` | Allowed and forbidden instructions, calling style, code style |
| `docs/PHASE1_PLAN.md` | The screens, the 3x3 sprites, and the numbered steps to follow |
| `docs/COMMIT_GUIDE.md` | How commit messages must be written (important, read it) |

## Build and run

```
nasm src/game.asm -o build/game.com -l build/game.lst
bash tools/check_rules.sh
```

Run `build/game.com` in DOSBox. If DOSBox is not available in your environment, assemble only and tell the student to run it. Never claim you saw it running if you could not run it.

The assembly must finish with **zero errors and zero warnings**, and `check_rules.sh` must print `OK`.

## How to work (the loop)

Work through `docs/PHASE1_PLAN.md` one step at a time, in order.

1. Pick the next unfinished step.
2. Write only that step's code in `src/game.asm`.
3. Assemble it and run `bash tools/check_rules.sh`.
4. Fix anything that fails.
5. Make **one git commit** for that step, following `docs/COMMIT_GUIDE.md`.
6. Tick the step in `docs/PHASE1_PLAN.md`.
7. Tell the student, in two or three plain sentences, what the step does and what they should see on screen. Then **stop and wait** for them to test it. Do not start the next step until they say so.

## Code style (short version, full version in ASSEMBLY_RULES.md)

- Everything lives in `src/game.asm`. One file, like the book's examples.
- Every subroutine has a short comment block above it: what it does, what parameters it takes from the stack and in which order.
- Comment every line or every small group of lines, in simple words, the way the book does.
- Labels use lowercase and underscores, with meaningful names such as `draw_object` and `print_score`.
- Preserve every register a subroutine uses (push on entry, pop in reverse order on exit), exactly like the book's examples.
- Position, colour and score values live in named variables in the data area or are commented where used. No unexplained numbers.

## Things you must not do

- Do not use `pusha`, `popa`, `push` with a number, shifts by a number bigger than 1, 32-bit registers, `equ`, macros, `%include`, or MASM-style directives. The full list is in `docs/ASSEMBLY_RULES.md`.
- Do not use BIOS or DOS text-printing services to draw the game. All drawing is done by writing straight into video memory at `0xB800`, as taught in chapter 6.
- Do not edit anything inside `docs/reference/`.
- Do not create extra source files, folders, build systems or frameworks.
- Do not change git settings (name, email, branch names) and do not push unless the student asks.
- Do not add trailers such as `Co-authored-by` to commits, and never mention Codex, AI or an assistant in a commit message or in code comments.

## When to stop and ask the student

- You want an instruction or technique that is not in the book.
- A step in the plan seems to conflict with the book or with the teacher's spec.
- Something does not assemble and the fix would mean changing the plan.
- You are about to touch anything outside Phase 1.

Asking is always better than quietly using something the student has not studied.
