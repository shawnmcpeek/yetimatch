# Firestore schema (YetiMatch)

Enable **Firestore** in Firebase Console for your project (Build → Firestore Database → Create database). Use **test mode** or **production rules** as needed.

## Collections

### `users/{userId}`

One document per authenticated user (Firebase Auth UID). Created or updated on sign-in/sign-up.

| Field       | Type     | Description        |
|------------|----------|--------------------|
| `email`    | string   | User email         |
| `createdAt`| timestamp| First sign-in time |

Later you can add: `isPaid`, `tier`, etc.

### `users/{userId}/quizResults` (subcollection)

One document per quiz completion. Written for every signed-in user when they finish a quiz (free or paid). Visibility in the app can be gated by tier (e.g. show last 10 for free, full history for paid).

| Field         | Type     | Description                    |
|---------------|----------|--------------------------------|
| `quizId`      | string   | Quiz ID from manifest          |
| `quizTitle`   | string   | Quiz title                     |
| `characterId` | string   | Result character ID            |
| `characterName` | string | Result character name          |
| `description` | string   | Result description             |
| `traits`      | array    | List of trait strings          |
| `completedAt` | timestamp| When the quiz was completed    |

## Security rules (example)

- Users can read/write only their own `users/{userId}` and `users/{userId}/quizResults` documents (e.g. `request.auth != null && request.auth.uid == userId`).
