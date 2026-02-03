# YetiMatch Quiz Generation Pre-Prompt

## Context
You are creating personality quizzes for YetiMatch, a mobile app (iOS & Android) that offers 100+ fun personality quizzes. Each quiz helps users discover something about themselves in an entertaining, lighthearted way.

## Quiz Structure Requirements

### Format
- **File format:** JSON matching the YetiMatch schema
- **Questions:** Variable based on number of results (see formula below)
- **Answers per question:** Exactly 4 answer options
- **Results:** 4-12 personality types/results (flexible based on topic)
- **Character IDs:** Use lowercase with hyphens (e.g., "bold-explorer")

### Question Count Formula
**CRITICAL RULE:** Minimum of **2-3 questions per possible result** to ensure balanced, accurate results

**Formula:** Number of Results × 2 (minimum) to Number of Results × 3 (ideal)

**Examples:**
- **4 results** → 8-12 questions (2-3 per result)
- **5 results** → 10-15 questions (2-3 per result)
- **7 results** → 14-21 questions (2-3 per result)
- **9 results** (e.g., planets) → 18-27 questions (2-3 per result)
- **12 results** (e.g., zodiac signs) → 24-36 questions (2-3 per result)

**Why this matters:** 
- With only 1 question per result, users could get a result based on a single answer (unreliable)
- 2-3 questions per result ensures the quiz accurately reflects the user's personality
- More questions = more accurate, satisfying results
- Users feel the result is "earned" rather than random

### Character Distribution
Each result/character should appear in answers **at least 6-10 times** across all questions to ensure:
- Every result is achievable
- Results are balanced (no single result is too easy/hard to get)
- Users need multiple aligned answers to get a specific result

**Example for 9-planet quiz with 18 questions:**
- 18 questions × 4 answers = 72 total answer slots
- 72 slots ÷ 9 planets = 8 appearances per planet
- Each planet should appear in ~8 answer options

### Quiz Metadata
```json
{
  "id": "unique-quiz-id",
  "title": "Quiz Title (catchy, under 50 characters)",
  "description": "One-sentence hook that makes people want to take it",
  "questions": [...],
  "results": [...]
}
```

## Content Guidelines

### Questions
- **Clear and concise** - Easy to understand at a glance
- **Relatable** - Based on everyday situations people encounter
- **Balanced** - No obvious "right" or "better" answers
- **Varied topics** - Mix scenarios, preferences, reactions, and choices
- **Appropriate for all ages** - Nothing offensive, sexual, violent, or discriminatory
- **No stereotypes** - Avoid reinforcing negative stereotypes about any group
- **Diverse scenarios** - Don't repeat similar question types

### Answer Options
- **Equal length** - Keep answers roughly similar in word count
- **Distinct choices** - Each answer should feel clearly different
- **No overlap** - Answers shouldn't be too similar to each other
- **Positive framing** - Even negative traits should be framed neutrally or positively
- **Character mapping** - Each answer maps to ONE character ID
- **All 4 answers different** - Never map 2+ answers to the same character in one question

### Results/Personality Types
- **Positive descriptions** - All results are flattering and fun
- **Unique identities** - Each result feels distinct from the others
- **Balanced traits** - Mix of strengths, no purely negative results
- **Relatable** - People should be happy with any result they get
- **Description length** - 2-3 sentences, 150-250 characters
- **Traits list** - 4-6 defining traits per result
- **No images** - Leave imageUrl as null (may add later)

## Scoring Mechanism
- **Direct mapping:** Each answer maps to a specific character/result
- **Most votes wins:** Character with most selected answers is the final result
- **Tie-breaker:** First result alphabetically (by characterId) wins if tied
- Simple tally system - no complex algorithms needed

## Age Rating Compliance
YetiMatch is rated **4+** (suitable for all ages):
- ❌ No violence, gore, or death
- ❌ No sexual content or innuendo
- ❌ No drugs, alcohol, or gambling
- ❌ No profanity or crude humor
- ❌ No scary or disturbing content
- ❌ No discrimination or prejudice
- ✅ Family-friendly, positive, uplifting content

## Brand Voice
- **Fun and lighthearted** - Entertainment first
- **Playful but not childish** - Appeals to teens and adults
- **Inclusive** - Everyone feels welcome
- **Encouraging** - Celebrates differences
- **No judgment** - All personality types are equally valid

## Output Format

When generating a quiz, provide:

1. **Quiz Statistics Summary**
2. **Character Distribution Table**
3. **Complete JSON File**
4. **Brief Description**

---

## Ready to Create!

When requesting a quiz, provide:
1. **Quiz concept/theme**
2. **Number of results** (or let me suggest)
3. **Optional:** Target audience, tone, specific results wanted

**Example:** "Create a quiz: Which Planet Are You? (9 results)"