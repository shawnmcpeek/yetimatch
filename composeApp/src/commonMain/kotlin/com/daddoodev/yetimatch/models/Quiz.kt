package com.daddoodev.yetimatch.models

import kotlinx.serialization.Serializable

@Serializable
data class Quiz(
    val id: String,
    val title: String,
    val description: String,
    val questions: List<Question>,
    val results: List<QuizResult>
)

@Serializable
data class Question(
    val id: String,
    val text: String,
    val answers: List<Answer>
)

@Serializable
data class Answer(
    val id: String,
    val text: String,
    val characterId: String  // Maps to which personality/character this answer represents
)

@Serializable
data class QuizResult(
    val characterId: String,
    val characterName: String,
    val description: String,
    val traits: List<String>,
    val imageUrl: String? = null  // Optional image for the character
)
