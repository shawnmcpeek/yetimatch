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

One document per quiz id (document id = `quizId`). A retake **overwrites** the previous final result for that quiz. Written for signed-in users (including anonymous) when they finish a quiz. In-app history UI is gated on Unlimited.

| Field         | Type     | Description                    |
|---------------|----------|--------------------------------|
| `quizId`      | string   | Quiz ID from manifest          |
| `quizTitle`   | string   | Quiz title                     |
| `characterId` | string   | Result character ID            |
| `characterName` | string | Result character name          |
| `description` | string   | Result description             |
| `traits`      | array    | List of trait strings          |
| `completedAt` | timestamp| When the quiz was completed    |

## Security rules

Production rules live in `firestore.rules` (deploy with Firebase CLI). Users can read/write/delete only their own `users/{userId}` and `users/{userId}/quizResults` documents.
