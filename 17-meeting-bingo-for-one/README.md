# Meeting Bingo for One

Tap corporate clichés until your soul earns a tiny prize.

## What actually works

- A fresh 3×3 board is dealt from a pool of 24 meeting clichés.
- The center free space is marked automatically.
- Tapping a cliché marks or unmarks it; rows, columns, and diagonals detect bingo.
- The current board and marks survive relaunch with local `UserDefaults`.
- Each dealt board can increment the completed-game count only once, even if a
  winning line is later broken and restored; that won-state survives relaunch.
- Completed-game count is stored locally on the device.
- “Deal a new meeting” resets the board without a network request or account.
- Confirmed “Erase all bingo data” resets both the board and game statistics.

This app intentionally has no backend, analytics, ads, or network permission. It is a complete offline utility, not a mock screen.
