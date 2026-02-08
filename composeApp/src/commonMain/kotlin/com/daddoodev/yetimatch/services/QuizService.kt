package com.daddoodev.yetimatch.services

import com.daddoodev.yetimatch.models.Quiz
import com.daddoodev.yetimatch.models.QuizManifest
import com.daddoodev.yetimatch.models.QuizResult
import kotlinx.serialization.json.Json

class QuizService {
    private val json = Json {
        ignoreUnknownKeys = true
        prettyPrint = true
    }

    fun loadManifest(jsonString: String): QuizManifest {
        return json.decodeFromString<QuizManifest>(jsonString)
    }

    /**
     * Load a quiz from JSON string
     */
    fun loadQuiz(jsonString: String): Quiz {
        return json.decodeFromString<Quiz>(jsonString)
    }
    
    /**
     * Calculate quiz result based on answers
     * This uses the simple direct mapping approach we discussed
     */
    fun calculateResult(quiz: Quiz, selectedAnswers: Map<String, String>): QuizResult {
        // Count votes for each character
        val characterVotes = mutableMapOf<String, Int>()
        
        selectedAnswers.forEach { (questionId, answerId) ->
            // Find the question
            val question = quiz.questions.find { it.id == questionId }
            
            // Find the answer
            val answer = question?.answers?.find { it.id == answerId }
            
            // Increment vote count for this character
            answer?.let {
                characterVotes[it.characterId] = (characterVotes[it.characterId] ?: 0) + 1
            }
        }
        
        // Find the character with the most votes
        val winningCharacterId = characterVotes.maxByOrNull { it.value }?.key
            ?: quiz.results.first().characterId  // Fallback to first result
        
        // Return the corresponding result
        return quiz.results.find { it.characterId == winningCharacterId }
            ?: quiz.results.first()  // Fallback to first result
    }
    
    /**
     * Get all available quizzes
     * For now returns a list, but you could load multiple quiz files
     */
    fun getAvailableQuizzes(): List<Quiz> {
        // In a real app, you'd load from multiple JSON files in assets
        // For now, return empty list - you'll populate this when loading from assets
        return emptyList()
    }
}
