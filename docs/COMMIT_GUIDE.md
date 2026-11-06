# Commit Guide

Commit messages in this repo must read like a student wrote them, not like a tool. Read this before your first commit.

## Install the safety hook (do this once, in Step 0)

```
cp tools/commit-msg .git/hooks/commit-msg
chmod +x .git/hooks/commit-msg
```

From then on git rejects messages that break the rules below. If a commit is rejected, do not argue with the hook. Rewrite the message. (The student can remove the hook any time by deleting `.git/hooks/commit-msg`.)

## The rules

- **One short line.** Under 60 characters. No body, no bullet list, no trailers (`Co-authored-by` and similar are not allowed).
- **All lowercase.**
- **No colons, no semicolons, no dashes, no brackets, no quotes, no backticks.**
- **No prefixes** like `feat`, `fix`, `chore`, `docs`, `refactor`.
- **No full stop** at the end.
- **Plain everyday words.** Say what you did the way you would tell a friend. Past tense (`fixed`, `added`, `got`) or just describe the result (`screen clears now`) both work. Mix them up, do not use the same sentence pattern every time.
- **Do not name files, functions or instructions** unless it is the natural way to say it.
- **Never mention Codex, AI, an assistant, or a tool.**
- **Avoid these words**, they sound robotic: implement, introduce, enhance, utilize, streamline, robust, ensure, leverage, comprehensive, seamless, refactor, facilitate, optimize, functionality, improve.
- **Commit with a single `-m`**, for example `git commit -m "screen clears now"`. Do not use a second `-m`.

## When to commit

One commit per step in `docs/PHASE1_PLAN.md`, after the program assembles and `bash tools/check_rules.sh` says `OK`. If something needs fixing later, make a separate small commit for the fix. Do not squash everything into one big commit at the end.

Stage everything with `git add -A` before committing. Do not push unless the student asks.

## Messages for each Phase 1 step

Use these as they are, or reword them slightly in the same relaxed tone.

| Step | Commit message |
|---|---|
| 0 setup | `set up the project and an empty game that just exits` |
| 1 clear screen | `screen clears now` |
| 2 print string | `can print text anywhere on the screen` |
| 3 print number | `numbers show up on screen` |
| 4 print time | `timer shows minutes and seconds` |
| 5 bucket | `bucket draws in its 3x3 box` |
| 6 other sprites | `added the coins diamond and bomb` |
| 7 game screen | `game screen has the timer score and all the objects` |
| 8 start screen | `start screen waits for enter` |
| 9 end screen | `end screen with the final score` |
| 10 connect flow | `all three screens connected now` |
| 11 final check | `cleaned up comments and names before the demo` |

## Fix and small change messages

When something small goes wrong or needs tweaking, pick wording like this. Never reuse the same message twice.

- `fixed the score showing on the wrong row`
- `bomb was drawn one row too low`
- `title was off center so moved it`
- `forgot to save a register in print number`
- `timer showed the seconds wrong`
- `made the bucket green so it stands out`
- `comments were confusing so rewrote a few`
- `renamed a couple of labels to make more sense`
- `removed some test code i left in`
- `end screen text moved up a bit`

## Good and bad

| Sounds like a tool (never) | Sounds like a student (do this) |
|---|---|
| `feat: implement clear_screen subroutine` | `screen clears now` |
| `Add print_string routine to enable text rendering` | `can print text anywhere on the screen` |
| `Refactor draw_object to improve readability` | `rewrote the sprite drawing so its easier to follow` |
| `Fix: correct score position (top-right)` | `fixed the score showing on the wrong row` |
| `Update README.md to reflect Phase 1 progress` | `updated the readme` |
