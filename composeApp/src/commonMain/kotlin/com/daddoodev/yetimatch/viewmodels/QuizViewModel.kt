package com.daddoodev.yetimatch.viewmodels

import com.daddoodev.yetimatch.loadManifestJson
import com.daddoodev.yetimatch.loadQuizJson
import com.daddoodev.yetimatch.models.Quiz
import com.daddoodev.yetimatch.models.QuizManifest
import com.daddoodev.yetimatch.models.QuizMeta
import com.daddoodev.yetimatch.models.QuizResult
import com.daddoodev.yetimatch.services.QuizService
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class QuizViewModel(private val quizService: QuizService = QuizService()) {

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

    // Loading and error state
    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _loadError = MutableStateFlow<String?>(null)
    val loadError: StateFlow<String?> = _loadError.asStateFlow()

    // Manifest (categories + quiz list)
    private val _manifest = MutableStateFlow<QuizManifest?>(null)
    val manifest: StateFlow<QuizManifest?> = _manifest.asStateFlow()

    // Current quiz being taken
    private val _currentQuiz = MutableStateFlow<Quiz?>(null)
    val currentQuiz: StateFlow<Quiz?> = _currentQuiz.asStateFlow()

    // Current question index (0-based)
    private val _currentQuestionIndex = MutableStateFlow(0)
    val currentQuestionIndex: StateFlow<Int> = _currentQuestionIndex.asStateFlow()

    // Selected answers: questionId -> answerId
    private val _selectedAnswers = MutableStateFlow<Map<String, String>>(emptyMap())
    val selectedAnswers: StateFlow<Map<String, String>> = _selectedAnswers.asStateFlow()

    // Final result
    private val _result = MutableStateFlow<QuizResult?>(null)
    val result: StateFlow<QuizResult?> = _result.asStateFlow()

    // Quiz completion state
    private val _isQuizComplete = MutableStateFlow(false)
    val isQuizComplete: StateFlow<Boolean> = _isQuizComplete.asStateFlow()

    /**
     * Start a new quiz
     */
    fun startQuiz(quiz: Quiz) {
        _currentQuiz.value = quiz
        _currentQuestionIndex.value = 0
        _selectedAnswers.value = emptyMap()
        _result.value = null
        _isQuizComplete.value = false
    }

    /**
     * Load quiz from JSON string
     */
    fun loadQuiz(jsonString: String) {
        val quiz = quizService.loadQuiz(jsonString)
        startQuiz(quiz)
    }

    /**
     * Load manifest (categories + quiz list) from platform resources.
     */
    fun loadManifestFromResources() {
        scope.launch {
            _isLoading.value = true
            _loadError.value = null
            try {
                val json = loadManifestJson()
                _manifest.value = quizService.loadManifest(json)
            } catch (e: Exception) {
                _loadError.value = e.message ?: "Failed to load catalog"
            }
            _isLoading.value = false
        }
    }

    /**
     * Load a quiz by resource path and start it. Runs asynchronously.
     */
    fun loadQuizByPath(path: String) {
        scope.launch {
            _isLoading.value = true
            _loadError.value = null
            try {
                val json = loadQuizJson(path)
                loadQuiz(json)
            } catch (e: Exception) {
                _loadError.value = e.message ?: "Failed to load quiz"
            }
            _isLoading.value = false
        }
    }

    fun getQuizzesInCategory(categoryId: String): List<QuizMeta> {
        val m = _manifest.value ?: return emptyList()
        return m.quizzes.filter { it.categoryId == categoryId }
    }

    fun searchQuizzes(query: String): List<QuizMeta> {
        val m = _manifest.value ?: return emptyList()
        if (query.isBlank()) return emptyList()
        val q = query.lowercase()
        val categoryNames = m.categories.associate { it.id to it.name.lowercase() }
        return m.quizzes.filter { meta ->
            meta.title.lowercase().contains(q) ||
                meta.description.lowercase().contains(q) ||
                categoryNames[meta.categoryId]?.contains(q) == true
        }
    }

    /**
     * Answer the current question
     */
    fun answerQuestion(answerId: String) {
        val quiz = _currentQuiz.value ?: return
        val currentQuestion = quiz.questions.getOrNull(_currentQuestionIndex.value) ?: return

        // Save the answer
        _selectedAnswers.value = _selectedAnswers.value + (currentQuestion.id to answerId)

        // Move to next question or finish
        if (_currentQuestionIndex.value < quiz.questions.size - 1) {
            _currentQuestionIndex.value += 1
        } else {
            finishQuiz()
        }
    }

    /**
     * Go back to previous question
     */
    fun previousQuestion() {
        if (_currentQuestionIndex.value > 0) {
            _currentQuestionIndex.value -= 1
        }
    }

    /**
     * Finish the quiz and calculate result
     */
    private fun finishQuiz() {
        val quiz = _currentQuiz.value ?: return
        _result.value = quizService.calculateResult(quiz, _selectedAnswers.value)
        _isQuizComplete.value = true
    }

    /**
     * Restart the current quiz
     */
    fun restartQuiz() {
        _currentQuiz.value?.let { startQuiz(it) }
    }

    /**
     * Get progress percentage (0-100)
     */
    fun getProgress(): Float {
        val quiz = _currentQuiz.value ?: return 0f
        return (_currentQuestionIndex.value + 1).toFloat() / quiz.questions.size.toFloat() * 100f
    }
}
