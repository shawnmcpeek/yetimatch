# Adding a new quiz

Quizzes are served live from Firestore by the `ymApi` Cloud Function (in the
`daddoodev` repo, `functions/src/index.ts`) — not bundled with the app. Adding
one is a two-step process: write the JSON, then seed it.

## 1. Write the quiz JSON

Create a file in the `daddoodev` repo at `src/quizzes/your_quiz_name.json`
(underscore-separated filename, per the existing files in that folder) shaped
like this:

```json
{
  "id": "your-quiz-id",
  "title": "Which Thing Are You?",
  "description": "One or two sentences shown on the quiz card.",
  "categoryId": "who-am-i",
  "questions": [
    {
      "id": "q1",
      "text": "Question text?",
      "answers": [
        { "id": "q1a1", "text": "Answer text", "characterId": "result-a" },
        { "id": "q1a2", "text": "Answer text", "characterId": "result-b" }
      ]
    }
  ],
  "results": [
    {
      "characterId": "result-a",
      "characterName": "Display Name",
      "description": "Result description shown to the user.",
      "traits": ["Trait One", "Trait Two"]
    }
  ]
}
```

Notes:
- `id` becomes the Firestore document ID — lowercase, hyphenated, unique across all quizzes.
- Every `characterId` used in `answers` must have a matching entry in `results`.
- `categoryId` must be one of:

  | id | name |
  |---|---|
  | `relationship-love` | Relationship & Love |
  | `who-am-i` | Who Am I? |
  | `career-success` | Career & Success |
  | `friendship-social` | Friendship & Social |
  | `personality-self` | Personality & Self-Discovery |
  | `fun-entertainment` | Fun & Entertainment |
  | `wellness-mindset` | Wellness & Mindset |
  | `pop-culture-fandom` | Pop Culture & Fandom |

## 2. Seed it

From the `daddoodev` repo, first time only, authenticate so the script can
write to Firestore:

```bash
gcloud auth application-default login
```

Then, from `functions/`:

```bash
npm run seed
```

This reads every file in `src/quizzes/` and upserts it into the live
`quizzes` Firestore collection — no redeploy needed. It re-seeds *all*
quizzes in that folder each run (not just the new one), overwriting existing
docs with the local file's content, so make sure you haven't left stray
edits in other quiz files before running it.

## 3. Verify

```bash
curl -H "X-API-Key: <see AppConfig.ymV2QuizApiKey>" \
  "https://ymapi-tkbt6ug22q-uc.a.run.app/ym/v2/quizzes/your-quiz-id"
```

Should return the quiz JSON back. The app will pick it up next time it
fetches the quiz list — no app update required.
