# Fridge Witness

A private, zero-seed inventory for what is actually in your fridge.

## What actually works

- First launch is empty: there are no fictional cucumbers or mystery containers
  presented as user data.
- Add a real food/container name, quantity, and optional manually entered use-by
  reminder. Matching names and reminder dates merge without duplicate rows.
- The dashboard reports item types, total units, and reminders needing attention.
- Interrogation produces a truthful inventory summary with overdue and
  due-within-three-days counts.
- Inventory persists locally across relaunches. “Use one” decrements quantity,
  “Remove item” deletes a row, and confirmed erasure clears all fridge data.
- Reminder dates are not freshness or food-safety verdicts. The app cannot
  inspect food or verify package labels.

No backend, account, analytics, ads, or network permission.
