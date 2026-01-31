# Mature / Adult Quizzes Implementation

Plan for adding age-gated adult quizzes within existing categories (e.g. Relationship & Love). Come back to this when ready to implement.

## Overview

- Some categories (e.g. **Relationship & Love**) have both **all-ages quizzes** and **adult quizzes**.
- All-ages quizzes are shown to everyone.
- A single **“Adult quizzes”** card at the **bottom** of the category acts as the entry point to mature content.
- Tapping that card runs an **age gate** (birth date or “I am 18+”).
- Once the user passes, they are **globally age-verified** (stored once; no re-prompt in other categories).
- After passing, the user sees the mature quizzes for that category (e.g. “What is your kink?” and similar).

## Decisions

| Item | Choice |
|------|--------|
| Card placement | Bottom of the category quiz list |
| Card copy | **“Adult quizzes”** |
| Age-verified state | **Global** — one gate ever; any “Adult quizzes” card in any category unlocks after that |

## Flow

1. User opens a category (e.g. Relationship & Love).
2. They see normal quizzes first, then at the bottom a card labeled **“Adult quizzes”**.
3. Tapping **“Adult quizzes”**:
   - If **not** yet globally age-verified → show age gate (birth date or 18+ confirmation).
   - If user passes → set global “age-verified”, then show mature quiz list for this category.
   - If user fails or cancels → return to category list; no mature content shown.
4. If **already** globally age-verified → skip gate and show mature quiz list for this category.

## Store / Rating

- App contains adult content → rate **17+** (Apple) / **Mature 17+** (Google).
- In-app gate + clear “Adult quizzes” label demonstrates intent to restrict access.

## Implementation Notes (for later)

- **Manifest / data:** Categories or quizzes need a way to mark “has mature sub-list” and which quiz IDs are mature for that category.
- **State:** Persist “age-verified” (e.g. `SharedPreferences` / `UserDefaults` or account-backed). Global flag, not per-category.
- **UI:** Category detail screen shows normal quizzes, then the “Adult quizzes” card; tapping it runs gate (dialog or small screen), then navigates to mature quiz list or in-place expansion.
- **Reuse:** Same pattern can be used in other categories (e.g. Fun & Entertainment) by adding an “Adult quizzes” card and a mature quiz list for that category.
