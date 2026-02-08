package com.daddoodev.yetimatch

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.foundation.layout.Spacer
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.daddoodev.yetimatch.ui.LocalSeasonalThemeName
import com.daddoodev.yetimatch.ui.SeasonalThemeManager
import com.daddoodev.yetimatch.ui.ThemeMode
import com.daddoodev.yetimatch.ui.ThemeModeToggle
import com.daddoodev.yetimatch.ui.YetiMatchLogo
import com.daddoodev.yetimatch.ui.YetiMatchTheme
import com.daddoodev.yetimatch.auth.deleteAccount
import com.daddoodev.yetimatch.auth.getCurrentUserId
import com.daddoodev.yetimatch.auth.getCurrentUserEmail
import com.daddoodev.yetimatch.auth.getQuizzesTakenCount
import com.daddoodev.yetimatch.auth.setQuizzesTakenCount
import com.daddoodev.yetimatch.auth.signOut
import com.daddoodev.yetimatch.firestore.ensureUserOnSignIn
import com.daddoodev.yetimatch.firestore.saveQuizResult
import com.daddoodev.yetimatch.preferences.getThemeMode
import com.daddoodev.yetimatch.preferences.setThemeMode
import com.daddoodev.yetimatch.platform.openUrl
import com.daddoodev.yetimatch.ui.screens.CategoryDetailScreen
import com.daddoodev.yetimatch.ui.screens.SignInScreen
import com.daddoodev.yetimatch.ui.screens.SignUpScreen
import com.daddoodev.yetimatch.ui.screens.ErrorScreen
import com.daddoodev.yetimatch.ui.screens.HomeScreen
import com.daddoodev.yetimatch.ui.screens.LoadingScreen
import com.daddoodev.yetimatch.ui.screens.QuizScreen
import com.daddoodev.yetimatch.ui.screens.ResultScreen
import com.daddoodev.yetimatch.ui.screens.WelcomeScreen
import com.daddoodev.yetimatch.viewmodels.QuizViewModel
import kotlinx.coroutines.launch

/** Number of free quizzes before sign-in is required. (Which quizzes are free can be configured later.) */
private const val FREE_QUIZ_LIMIT = 5

private sealed class AppScreen {
    data object Home : AppScreen()
    data class CategoryDetail(val categoryId: String) : AppScreen()
    data object LoadingQuiz : AppScreen()
    /** Sign in screen. pendingQuizId = null when opened from menu. */
    data class SignIn(val pendingQuizId: String?) : AppScreen()
    /** Sign up screen. pendingQuizId = null when opened from menu. */
    data class SignUp(val pendingQuizId: String?) : AppScreen()
    data object Welcome : AppScreen()
    data object Quiz : AppScreen()
    data object Results : AppScreen()
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun App() {
    // Initialize seasonal themes
    LaunchedEffect(Unit) {
        try {
            SeasonalThemeManager.initialize(loadThemesJson())
        } catch (e: Exception) {
            println("Failed to load seasonal themes: ${e.message}")
        }
    }
    
    var themeMode by remember { mutableStateOf(getThemeMode()) }
    YetiMatchTheme(themeMode = themeMode) {
        val viewModel = remember { QuizViewModel() }
        val isLoading by viewModel.isLoading.collectAsState()
        val loadError by viewModel.loadError.collectAsState()
        val manifest by viewModel.manifest.collectAsState()
        val currentQuiz by viewModel.currentQuiz.collectAsState()
        var currentScreen by remember { mutableStateOf<AppScreen>(AppScreen.Home) }
        var searchQuery by remember { mutableStateOf("") }
        var menuExpanded by remember { mutableStateOf(false) }
        var signedInEmail by remember { mutableStateOf(getCurrentUserEmail()) }
        var showDeleteConfirm by remember { mutableStateOf(false) }
        var deleteError by remember { mutableStateOf<String?>(null) }
        val scope = rememberCoroutineScope()

        LaunchedEffect(Unit) {
            viewModel.loadManifestFromResources()
        }

        LaunchedEffect(currentScreen, isLoading, currentQuiz) {
            if (currentScreen is AppScreen.LoadingQuiz && !isLoading) {
                currentScreen = if (currentQuiz != null) AppScreen.Welcome else AppScreen.Home
            }
        }

        val showBack = currentScreen is AppScreen.CategoryDetail ||
            currentScreen is AppScreen.SignIn ||
            currentScreen is AppScreen.SignUp
        val topBarTitle = when (val s = currentScreen) {
            is AppScreen.CategoryDetail -> manifest?.categories?.find { it.id == s.categoryId }?.name ?: "Category"
            is AppScreen.SignIn -> "Sign in"
            is AppScreen.SignUp -> "Sign up"
            else -> "YetiMatch"
        }

        Scaffold(
            topBar = {
                TopAppBar(
                    title = {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            YetiMatchLogo(size = 32.dp)
                            Spacer(modifier = Modifier.padding(8.dp))
                            Text(topBarTitle)
                        }
                    },
                    navigationIcon = {
                        if (showBack) {
                            IconButton(onClick = { currentScreen = AppScreen.Home }) {
                                Text("<")
                            }
                        }
                    },
                    actions = {
                        ThemeModeToggle(
                            themeMode = themeMode,
                            onThemeModeChange = { newMode ->
                                setThemeMode(newMode)
                                themeMode = newMode
                            }
                        )
                        Box {
                            IconButton(onClick = { menuExpanded = true }) {
                                Text("⋮")
                            }
                            DropdownMenu(
                                expanded = menuExpanded,
                                onDismissRequest = { menuExpanded = false }
                            ) {
                            if (signedInEmail != null) {
                                DropdownMenuItem(
                                    text = {
                                        Text(
                                            "Account",
                                            style = MaterialTheme.typography.bodyMedium
                                        )
                                    },
                                    onClick = { menuExpanded = false }
                                )
                                DropdownMenuItem(
                                    text = { Text(signedInEmail ?: "") },
                                    onClick = { menuExpanded = false }
                                )
                                DropdownMenuItem(
                                    text = { Text("Sign out") },
                                    onClick = {
                                        signOut()
                                        signedInEmail = null
                                        menuExpanded = false
                                    }
                                )
                                DropdownMenuItem(
                                    text = {
                                        Text(
                                            "Delete account",
                                            style = MaterialTheme.typography.bodyMedium,
                                            color = MaterialTheme.colorScheme.error
                                        )
                                    },
                                    onClick = {
                                        menuExpanded = false
                                        showDeleteConfirm = true
                                    }
                                )
                            } else {
                                DropdownMenuItem(
                                    text = { Text("Sign in") },
                                    onClick = {
                                        currentScreen = AppScreen.SignIn(null)
                                        menuExpanded = false
                                    }
                                )
                            }
                            HorizontalDivider()
                            DropdownMenuItem(
                                text = {
                                    Text(
                                        "Quiz history",
                                        style = MaterialTheme.typography.bodySmall,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant
                                    )
                                },
                                onClick = { menuExpanded = false },
                                enabled = false
                            )
                            DropdownMenuItem(
                                text = {
                                    Text(
                                        "Share results",
                                        style = MaterialTheme.typography.bodySmall,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant
                                    )
                                },
                                onClick = { menuExpanded = false },
                                enabled = false
                            )
                            DropdownMenuItem(
                                text = {
                                    Text(
                                        "Recommendations",
                                        style = MaterialTheme.typography.bodySmall,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant
                                    )
                                },
                                onClick = { menuExpanded = false },
                                enabled = false
                            )
                            HorizontalDivider()
                            DropdownMenuItem(
                                text = { Text("Privacy policy") },
                                onClick = {
                                    menuExpanded = false
                                    openUrl(AppConfig.PRIVACY_POLICY_URL)
                                }
                            )
                            DropdownMenuItem(
                                text = { Text("Support") },
                                onClick = {
                                    menuExpanded = false
                                    openUrl(AppConfig.SUPPORT_URL)
                                }
                            )
                            HorizontalDivider()
                            DropdownMenuItem(
                                text = {
                                    Text(
                                        "Upgrade to Premium",
                                        style = MaterialTheme.typography.labelLarge,
                                        color = MaterialTheme.colorScheme.primary
                                    )
                                },
                                onClick = { menuExpanded = false }
                            )
                            }
                        }
                    }
                )

                if (showDeleteConfirm) {
                    AlertDialog(
                        onDismissRequest = { showDeleteConfirm = false },
                        title = { Text("Delete account?") },
                        text = {
                            Text(
                                "Your account and all associated data will be permanently deleted. This cannot be undone."
                            )
                        },
                        confirmButton = {
                            TextButton(
                                onClick = {
                                    showDeleteConfirm = false
                                    scope.launch {
                                        deleteAccount().fold(
                                            onSuccess = {
                                                signOut()
                                                setQuizzesTakenCount(0)
                                                signedInEmail = null
                                                currentScreen = AppScreen.Home
                                            },
                                            onFailure = { e ->
                                                deleteError = e.message ?: "Could not delete account"
                                            }
                                        )
                                    }
                                }
                            ) {
                                Text("Delete", color = MaterialTheme.colorScheme.error)
                            }
                        },
                        dismissButton = {
                            TextButton(onClick = { showDeleteConfirm = false }) {
                                Text("Cancel")
                            }
                        }
                    )
                }
                deleteError?.let { msg ->
                    AlertDialog(
                        onDismissRequest = { deleteError = null },
                        title = { Text("Error") },
                        text = { Text(msg) },
                        confirmButton = {
                            TextButton(onClick = { deleteError = null }) {
                                Text("OK")
                            }
                        }
                    )
                }
            }
        ) { innerPadding ->
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding)
            ) {
                when {
                    isLoading && manifest == null -> LoadingScreen(message = "Loading...")
                    loadError != null && manifest == null -> ErrorScreen(
                        message = loadError!!,
                        onRetry = { viewModel.loadManifestFromResources() }
                    )
                    currentScreen is AppScreen.SignIn -> {
                        val signIn = currentScreen as AppScreen.SignIn
                        val pendingQuizId = signIn.pendingQuizId
                        SignInScreen(
                            message = if (pendingQuizId != null)
                                "You've completed $FREE_QUIZ_LIMIT free quizzes. Sign in to continue."
                            else
                                "Sign in to sync your progress and unlock features.",
                            onSuccess = {
                                scope.launch { ensureUserOnSignIn() }
                                signedInEmail = getCurrentUserEmail()
                                if (pendingQuizId != null) {
                                    currentScreen = AppScreen.LoadingQuiz
                                    viewModel.loadQuizById(pendingQuizId)
                                } else {
                                    currentScreen = AppScreen.Home
                                }
                            },
                            onGoToSignUp = { currentScreen = AppScreen.SignUp(pendingQuizId) },
                            onCancel = { currentScreen = AppScreen.Home }
                        )
                    }
                    currentScreen is AppScreen.SignUp -> {
                        val signUp = currentScreen as AppScreen.SignUp
                        val pendingQuizId = signUp.pendingQuizId
                        SignUpScreen(
                            message = if (pendingQuizId != null)
                                "You've completed $FREE_QUIZ_LIMIT free quizzes. Create an account to continue."
                            else
                                "Create an account to sync your progress and unlock features.",
                            onSuccess = {
                                scope.launch { ensureUserOnSignIn() }
                                signedInEmail = getCurrentUserEmail()
                                if (pendingQuizId != null) {
                                    currentScreen = AppScreen.LoadingQuiz
                                    viewModel.loadQuizById(pendingQuizId)
                                } else {
                                    currentScreen = AppScreen.Home
                                }
                            },
                            onGoToSignIn = { currentScreen = AppScreen.SignIn(pendingQuizId) },
                            onCancel = { currentScreen = AppScreen.Home }
                        )
                    }
                    currentScreen is AppScreen.LoadingQuiz -> LoadingScreen(message = "Loading quiz...")
                    currentScreen == AppScreen.Home -> HomeScreen(
                        manifest = manifest,
                        searchQuery = searchQuery,
                        onSearchQueryChange = { searchQuery = it },
                        onCategoryClick = { id -> currentScreen = AppScreen.CategoryDetail(id) },
                        onQuizClick = { meta ->
                            if (getQuizzesTakenCount() >= FREE_QUIZ_LIMIT && getCurrentUserEmail() == null) {
                                currentScreen = AppScreen.SignIn(meta.id)
                            } else {
                                currentScreen = AppScreen.LoadingQuiz
                                viewModel.loadQuizById(meta.id)
                            }
                        }
                    )
                    currentScreen is AppScreen.CategoryDetail -> {
                        val categoryId = (currentScreen as AppScreen.CategoryDetail).categoryId
                        val categoryName = manifest?.categories?.find { it.id == categoryId }?.name ?: ""
                        val quizzes = viewModel.getQuizzesInCategory(categoryId)
                        CategoryDetailScreen(
                            categoryName = categoryName,
                            quizzes = quizzes,
                            onQuizClick = { meta ->
                                if (getQuizzesTakenCount() >= FREE_QUIZ_LIMIT && getCurrentUserEmail() == null) {
                                    currentScreen = AppScreen.SignIn(meta.id)
                                } else {
                                    currentScreen = AppScreen.LoadingQuiz
                                    viewModel.loadQuizById(meta.id)
                                }
                            }
                        )
                    }
                    currentScreen == AppScreen.Welcome -> WelcomeScreen(
                        quizTitle = currentQuiz?.title ?: "YetiMatch",
                        quizDescription = currentQuiz?.description ?: "",
                        onStartQuiz = { currentScreen = AppScreen.Quiz }
                    )
                    currentScreen == AppScreen.Quiz -> QuizScreen(
                        viewModel = viewModel,
                        onQuizComplete = {
                            val q = currentQuiz
                            val r = viewModel.result.value
                            setQuizzesTakenCount(getQuizzesTakenCount() + 1)
                            getCurrentUserId()?.let { _ ->
                                q?.let { quiz ->
                                    r?.let { res ->
                                        scope.launch { ensureUserOnSignIn(); saveQuizResult(quiz.id, quiz.title, res) }
                                    }
                                }
                            }
                            currentScreen = AppScreen.Results
                        }
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
