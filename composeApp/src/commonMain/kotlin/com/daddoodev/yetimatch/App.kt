package com.daddoodev.yetimatch

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import com.daddoodev.yetimatch.ui.ThemeMode
import com.daddoodev.yetimatch.ui.ThemeModeToggle
import com.daddoodev.yetimatch.ui.YetiMatchTheme
import com.daddoodev.yetimatch.ui.screens.ErrorScreen
import com.daddoodev.yetimatch.ui.screens.LoadingScreen
import com.daddoodev.yetimatch.ui.screens.QuizScreen
import com.daddoodev.yetimatch.ui.screens.ResultScreen
import com.daddoodev.yetimatch.ui.screens.WelcomeScreen
import com.daddoodev.yetimatch.viewmodels.QuizViewModel

private enum class AppScreen { Home, Quiz, Results }

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun App() {
    var themeMode by remember { mutableStateOf(ThemeMode.System) }
    YetiMatchTheme(themeMode = themeMode) {
        val viewModel = remember { QuizViewModel() }
        val isLoading by viewModel.isLoading.collectAsState()
        val loadError by viewModel.loadError.collectAsState()
        val currentQuiz by viewModel.currentQuiz.collectAsState()
        var currentScreen by remember { mutableStateOf(AppScreen.Home) }

        LaunchedEffect(Unit) {
            viewModel.loadQuizFromResources()
        }

        Scaffold(
            topBar = {
                TopAppBar(
                    title = { Text("YetiMatch") },
                    actions = {
                        ThemeModeToggle(
                            themeMode = themeMode,
                            onThemeModeChange = { themeMode = it }
                        )
                    }
                )
            }
        ) { innerPadding ->
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding)
            ) {
                when {
                    isLoading -> LoadingScreen()
                    loadError != null -> ErrorScreen(
                        message = loadError!!,
                        onRetry = { viewModel.loadQuizFromResources() }
                    )
                    currentScreen == AppScreen.Home -> WelcomeScreen(
                        quizTitle = currentQuiz?.title ?: "YetiMatch",
                        quizDescription = currentQuiz?.description ?: "Discover your type.",
                        onStartQuiz = { currentScreen = AppScreen.Quiz }
                    )
                    currentScreen == AppScreen.Quiz -> QuizScreen(
                        viewModel = viewModel,
                        onQuizComplete = { currentScreen = AppScreen.Results }
                    )
                    else -> ResultScreen(
                        viewModel = viewModel,
                        onRetakeQuiz = {
                            viewModel.restartQuiz()
                            currentScreen = AppScreen.Quiz
                        },
                        onBackToHome = { currentScreen = AppScreen.Home }
                    )
                }
            }
        }
    }
}
