# Coin Catch

A falling object game for the COAL course project, written in Intel 8088 assembly (NASM, DOS .COM file).
Catch coins in the bucket, avoid the bomb.

## Build

```
nasm src/game.asm -o build/game.com -l build/game.lst
```

## Run

Open `build/game.com` in DOSBox.

## Status

- Phase 1 (screens, objects, timer and score display): in progress
- Phase 2 (full gameplay): not started

## Folder layout

| Path | What is in it |
|---|---|
| `src/game.asm` | the whole game |
| `docs/` | project spec, rules, plan and commit guide |
| `docs/reference/` | the course book |
| `tools/` | rule checker and commit message hook |
| `build/` | assembled output (not committed) |

## Using Codex

`AGENTS.md` is read automatically. It points to everything in `docs/`.
