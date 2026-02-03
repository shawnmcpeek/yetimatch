package com.daddoodev.yetimatch.ui.screens

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.decodeToImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.daddoodev.yetimatch.loadResourceBytes
import com.daddoodev.yetimatch.ui.ResultScreenAd
import com.daddoodev.yetimatch.viewmodels.QuizViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

@Composable
fun ResultScreen(
    viewModel: QuizViewModel,
    onRetakeQuiz: () -> Unit = {},
    onBackToHome: () -> Unit = {}
) {
    val result by viewModel.result.collectAsState()
    
    result?.let { quizResult ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            // Result title
            Text(
                text = "You are...",
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.primary
            )

            Spacer(modifier = Modifier.height(16.dp))

            // Result image: imageUrl is path relative to resources, e.g. "quizzes/images/summit_steve.png"
            var resultBitmap by remember(quizResult.imageUrl) { mutableStateOf<ImageBitmap?>(null) }
            LaunchedEffect(quizResult.imageUrl) {
                resultBitmap = quizResult.imageUrl?.let { path ->
                    withContext(Dispatchers.Default) {
                        loadResourceBytes(path)?.decodeToImageBitmap()
                    }
                }
            }
            resultBitmap?.let { bitmap ->
                Image(
                    bitmap = bitmap,
                    contentDescription = quizResult.characterName,
                    modifier = Modifier
                        .size(160.dp)
                        .padding(bottom = 8.dp),
                    contentScale = ContentScale.Fit
                )
            }

            // Character name
            Text(
                text = quizResult.characterName,
                style = MaterialTheme.typography.displaySmall,
                textAlign = TextAlign.Center
            )
            
            Spacer(modifier = Modifier.height(24.dp))
            
            // Description card
            Card(
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(
                    modifier = Modifier.padding(20.dp)
                ) {
                    Text(
                        text = quizResult.description,
                        style = MaterialTheme.typography.bodyLarge,
                        textAlign = TextAlign.Center
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(24.dp))
            
            // Traits section
            Text(
                text = "Your Traits:",
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.primary
            )
            
            Spacer(modifier = Modifier.height(12.dp))
            
            // Trait chips
            FlowRow(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.Center,
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                quizResult.traits.forEach { trait ->
                    AssistChip(
                        onClick = { },
                        label = { Text(trait) },
                        modifier = Modifier.padding(horizontal = 4.dp)
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(32.dp))
            
            // Action buttons
            Button(
                onClick = {
                    viewModel.restartQuiz()
                    onRetakeQuiz()
                },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Retake Quiz")
            }
            
            Spacer(modifier = Modifier.height(12.dp))
            
            OutlinedButton(
                onClick = onBackToHome,
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Back to Home")
            }

            Spacer(modifier = Modifier.height(24.dp))

            ResultScreenAd()
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun FlowRow(
    modifier: Modifier = Modifier,
    horizontalArrangement: Arrangement.Horizontal = Arrangement.Start,
    verticalArrangement: Arrangement.Vertical = Arrangement.Top,
    content: @Composable androidx.compose.foundation.layout.FlowRowScope.() -> Unit
) {
    androidx.compose.foundation.layout.FlowRow(
        modifier = modifier,
        horizontalArrangement = horizontalArrangement,
        verticalArrangement = verticalArrangement,
        content = content
    )
}
