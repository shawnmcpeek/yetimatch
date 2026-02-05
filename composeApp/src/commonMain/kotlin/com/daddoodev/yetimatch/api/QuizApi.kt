package com.daddoodev.yetimatch.api

import com.daddoodev.yetimatch.models.Quiz
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.request.get
import io.ktor.client.request.header
import io.ktor.client.request.headers
import kotlinx.serialization.Serializable

private const val BASE_URL = "https://ymapi-tkbt6ug22q-uc.a.run.app/ym/v2"

@Serializable
data class QuizListResponse(
    val quizzes: List<QuizListItem>
)

@Serializable
data class QuizListItem(
    val id: String,
    val title: String = "",
    val description: String = "",
    val lastModified: Long? = null,
    val categoryId: String? = null
)

private val QUIZ_ID_TO_CATEGORY = mapOf(
    "fabulous-five" to "personality-self",
    "coffee-personality-quiz" to "fun-entertainment",
    "learning-style-quiz" to "wellness-mindset",
    "mythical-beast-quiz" to "who-am-i",
    "pet-personality-quiz" to "fun-entertainment",
    "planet-personality-quiz" to "who-am-i",
    "season-personality-quiz" to "personality-self",
    "traveler-personality-quiz" to "personality-self",
    "yetimatch-soulmate" to "who-am-i",
    "spirit-composer-match" to "who-am-i",
    "love-language-quiz" to "relationship-love",
    "compatibility-style-quiz" to "relationship-love"
)

class QuizApi(private val httpClient: HttpClient) {

    suspend fun listQuizzes(): List<QuizListItem> {
        val response: QuizListResponse = httpClient.get("$BASE_URL/quizzes") {
            headers {
                header("X-API-Key", ApiConfig.API_KEY)
            }
        }.body()
        // Filter out incomplete entries (missing title)
        return response.quizzes.filter { it.title.isNotBlank() }
    }

    suspend fun getQuiz(id: String): Quiz {
        return httpClient.get("$BASE_URL/quizzes/$id") {
            headers {
                header("X-API-Key", ApiConfig.API_KEY)
            }
        }.body()
    }

    fun getCategoryForQuiz(quizId: String): String =
        QUIZ_ID_TO_CATEGORY[quizId] ?: "fun-entertainment"
}
