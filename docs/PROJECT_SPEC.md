# Project Spec: Catch & Score (falling object game)

Source: the teacher's `Project.docx`. This file is a faithful summary. If anything here ever disagrees with the teacher's document, the teacher's document wins and the student should be told.

## Basics

- Group of two students. Both must take part.
- Judged on: a working game, a tidy screen, clean code (good names, comments, small subroutines, reusing code).
- Platform: Intel 8088, assembled with NASM, runs as a DOS `.COM` program.
- Game reference (only for the idea, graphics may differ): https://i.gifer.com/MPBM.gif

## Our theme

| Role | Our choice |
|---|---|
| Score-giving objects | Three kinds of coin (small coin 5, gold coin 10, diamond 15) |
| Collecting object / player | A bucket |
| Game-ending object | A bomb |
| Game name | **COIN CATCH** (kept in one place in the code so it is easy to rename) |

All objects must look clearly different from each other.

## The three kinds of object

1. **Score-giving objects**: give points when collected.
2. **Collecting object (player)**: moves left and right to catch things.
3. **Game-ending objects**: end the game immediately when collected.

Every object is drawn inside a **3x3 space** (3 columns by 3 rows of screen characters).

## Phase 1 (deadline: 11:59 pm, Sunday 8 November 2026)

Goal: show the interface and every object. Gameplay is not needed yet.

| # | Requirement |
|---|---|
| 1 | All three object categories are displayed, sensibly sized, inside the game area |
| 2 | Every object is drawn using a 3x3 space |
| 3 | A timer is shown on screen displaying the remaining game time |
| 4 | A live score display is present (and can be updated) |
| 5 | A separate start screen with the game name, short instructions or controls, and "Press Enter to Start". The game begins only after Enter is pressed |
| 6 | An end screen that clearly says the game is over and may show the final score |

## Phase 2 (deadline: 11:59 pm, Sunday 29 November 2026). Do NOT build yet

- Game lasts exactly **2 minutes**. At zero the game ends and the end screen shows.
- Player moves with **Left Arrow** and **Right Arrow**, smoothly, and must never leave the screen.
- Three score object types worth **5, 10 and 15** points.
- Objects fall from the top. Speed must be challenging but fair, never extremely slow or extremely fast.
- Live score is at the **top-right corner** and updates the moment something is caught.
- Collision detection: catching a score object adds points, removes or resets that object, and a new one appears.
- Catching a game-ending object ends the game at once and shows the end screen with the final score.
- Start screen shows the game name, graphics or design, and "Press Enter to Start".

## Minimum game flow

```
START SCREEN
     | press Enter
     v
GAME STARTS  (timer 2:00, score 0, objects falling)
     |
     v
PLAYER MOVES LEFT / RIGHT
     |-- catches score object  -> score goes up
     '-- catches game-ending   -> game ends
                                      |
timer reaches 0 also ends the game -> END SCREEN
```

## Requirement to phase table

| Requirement | Phase |
|---|---|
| Game name / start screen | 1 |
| Start using Enter key | 1 |
| Display collecting object | 1 |
| Display score-giving objects | 1 |
| Display game-ending objects | 1 |
| 3x3 object representation | 1 |
| Timer display | 1 |
| Live score display | 1 |
| End screen | 1 |
| Left / right player movement | 2 |
| Falling objects | 2 |
| 5, 10 and 15 point objects | 2 |
| Collision / collection detection | 2 |
| Score updating | 2 |
| Game-ending object functionality | 2 |
| Two-minute gameplay | 2 |
| Complete playable game | 2 |
