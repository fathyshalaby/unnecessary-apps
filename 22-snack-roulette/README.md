# Snack Roulette

Enter the snacks. Let fate choose what you eat.

## What actually works

- Comma-separated pantry input is trimmed, deduplicated, and validated locally.
- A spin chooses an option at random and avoids repeating the immediately previous pick when possible.
- The pantry starts empty instead of pretending the user owns seeded snacks.
- The pantry list, latest result, and complete 20-spin local history survive relaunch.
- Empty input visibly disables spinning until at least one valid option exists.
- Spins can be deleted individually, recent or complete history can be browsed,
  and confirmed complete erasure removes pantry, ruling, and history together.

This app has no backend, analytics, ads, or network permission.
