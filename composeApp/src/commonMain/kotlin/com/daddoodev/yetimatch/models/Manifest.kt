package com.daddoodev.yetimatch.models

import kotlinx.serialization.Serializable

@Serializable
data class QuizManifest(
    val categories: List<Category>,
    val quizzes: List<QuizMeta>
)

@Serializable
data class Category(
    val id: String,
    val name: String,
    val description: String
)

@Serializable
data class QuizMeta(
    val id: String,
    val title: String,
    val description: String,
    val categoryId: String,
    val resourcePath: String,
    val mature: Boolean = false
)
