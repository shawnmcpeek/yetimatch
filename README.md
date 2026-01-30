# YetiMatch - KMP Setup Instructions

## File Structure

Here's where each file should go in your KMP project:

```
YetiMatch/
├── composeApp/
│   └── src/
│       └── commonMain/
│           ├── kotlin/
│           │   └── com/
│           │       └── daddoodev/
│           │           └── yetimatch/
│           │               ├── models/
│           │               │   └── Quiz.kt
│           │               ├── services/
│           │               │   └── QuizService.kt
│           │               ├── viewmodels/
│           │               │   └── QuizViewModel.kt
│           │               └── ui/
│           │                   └── screens/
│           │                       ├── QuizScreen.kt
│           │                       └── ResultScreen.kt
│           └── resources/
│               └── quizzes/
│                   └── sample_quiz.json
```

## Step-by-Step Setup

### 1. Create the directory structure
Navigate to your project's `composeApp/src/commonMain/kotlin/com/daddoodev/yetimatch/` directory and create these folders:
- `models`
- `services`
- `viewmodels`
- `ui/screens`

### 2. Place the Kotlin files

- **Quiz.kt** → `models/Quiz.kt`
- **QuizService.kt** → `services/QuizService.kt`
- **QuizViewModel.kt** → `viewmodels/QuizViewModel.kt`
- **QuizScreen.kt** → `ui/screens/QuizScreen.kt`
- **ResultScreen.kt** → `ui/screens/ResultScreen.kt`

### 3. Add the JSON file

Create a `resources` folder in `composeApp/src/commonMain/` (if it doesn't exist) and add:
- **sample_quiz.json** → `composeApp/src/commonMain/resources/quizzes/sample_quiz.json`

### 4. Update your dependencies

Make sure your `composeApp/build.gradle.kts` includes:

```kotlin
kotlin {
    sourceSets {
        commonMain.dependencies {
            // Compose Multiplatform dependencies
            implementation(compose.runtime)
            implementation(compose.foundation)
            implementation(compose.material3)
            implementation(compose.ui)
            implementation(compose.components.resources)
            
            // Kotlinx serialization for JSON
            implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.0")
            
            // Coroutines for StateFlow
            implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
        }
    }
}
```

Also make sure the serialization plugin is applied in your `build.gradle.kts`:

```kotlin
plugins {
    // ... other plugins
    kotlin("plugin.serialization") version "1.9.20"
}
```

### 5. Loading the quiz in your app

Here's a simple example of how to use these files in your `App.kt`:

```kotlin
@Composable
fun App() {
    MaterialTheme {
        val viewModel = remember { QuizViewModel() }
        var showResults by remember { mutableStateOf(false) }
        
        // Load quiz from resources
        LaunchedEffect(Unit) {
            // You'll need to load the JSON from resources
            // This is platform-specific, so you may need to create an expect/actual function
            val quizJson = loadQuizFromResources() // Implement this based on your platform
            viewModel.loadQuiz(quizJson)
        }
        
        if (showResults) {
            ResultScreen(
                viewModel = viewModel,
                onRetakeQuiz = { showResults = false },
                onBackToHome = { /* Navigate to home */ }
            )
        } else {
            QuizScreen(
                viewModel = viewModel,
                onQuizComplete = { showResults = true }
            )
        }
    }
}
```

### 6. Loading JSON from resources (platform-specific)

You'll need to create an `expect/actual` function to load the JSON:

**commonMain:**
```kotlin
expect fun loadQuizJson(): String
```

**androidMain:**
```kotlin
import android.content.Context
import androidx.compose.ui.platform.LocalContext

actual fun loadQuizJson(): String {
    // Load from Android assets
    return context.assets.open("quizzes/sample_quiz.json")
        .bufferedReader()
        .use { it.readText() }
}
```

**iosMain:**
```kotlin
actual fun loadQuizJson(): String {
    // Load from iOS bundle
    val path = NSBundle.mainBundle.pathForResource("sample_quiz", "json", "quizzes")
    return NSString.stringWithContentsOfFile(path!!, NSUTF8StringEncoding, null) as String
}
```

## How it works

1. **Quiz.kt** - Defines the data models for quizzes, questions, answers, and results
2. **QuizService.kt** - Handles loading quizzes and calculating results using the simple direct mapping approach
3. **QuizViewModel.kt** - Manages quiz state, navigation between questions, and result calculation
4. **QuizScreen.kt** - UI for displaying questions and answer options
5. **ResultScreen.kt** - UI for displaying the final personality result
6. **sample_quiz.json** - Example quiz data with the "Fabulous Five" personality types

## Next Steps

1. Copy all files to the correct locations
2. Update your dependencies
3. Create the expect/actual functions for loading JSON from resources
4. Customize the quiz JSON with your own questions and personality types
5. Add more quizzes by creating additional JSON files
6. Style the UI to match your brand (add colors, fonts, images)

## Tips

- Start with the sample quiz to test everything works
- You can create multiple quiz JSON files and load them dynamically
- Consider adding images for each personality result
- Add sharing functionality so users can share their results
- Consider adding analytics to track which results are most popular

Good luck with YetiMatch! 🏔️
