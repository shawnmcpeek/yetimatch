package com.daddoodev.yetimatch.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.daddoodev.yetimatch.models.Answer
import com.daddoodev.yetimatch.models.Question
import com.daddoodev.yetimatch.viewmodels.QuizViewModel

@Composable
fun QuizScreen(
    viewModel: QuizViewModel,
    onQuizComplete: () -> Unit = {}
) {
    val currentQuiz by viewModel.currentQuiz.collectAsState()
    val currentQuestionIndex by viewModel.currentQuestionIndex.collectAsState()
    val isQuizComplete by viewModel.isQuizComplete.collectAsState()
    val progress = viewModel.getProgress()
    
    LaunchedEffect(isQuizComplete) {
        if (isQuizComplete) {
            onQuizComplete()
        }
    }
    
    currentQuiz?.let { quiz ->
        val currentQuestion = quiz.questions.getOrNull(currentQuestionIndex)
        
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp)
        ) {
            // Progress bar
            LinearProgressIndicator(
                progress = { progress / 100f },
                modifier = Modifier.fillMaxWidth(),
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            // Question counter
            Text(
                text = "Question ${currentQuestionIndex + 1} of ${quiz.questions.size}",
                style = MaterialTheme.typography.labelLarge,
                color = MaterialTheme.colorScheme.primary
            )
            
            Spacer(modifier = Modifier.height(24.dp))
            
            // Question text
            currentQuestion?.let { question ->
                Text(
                    text = question.text,
                    style = MaterialTheme.typography.headlineSmall,
                    textAlign = TextAlign.Start
                )
                
                Spacer(modifier = Modifier.height(32.dp))
                
                // Answer options
                LazyColumn(
                    verticalArrangement = Arrangement.spacedBy(12.dp),
                    modifier = Modifier.weight(1f)
                ) {
                    items(
                        items = question.answers,
                        key = { it.id }
                    ) { answer ->
                        AnswerCard(
                            answer = answer,
                            onAnswerSelected = { viewModel.answerQuestion(answer.id) }
                        )
                    }
                }
                
                Spacer(modifier = Modifier.height(16.dp))
                
                // Back button (if not first question)
                if (currentQuestionIndex > 0) {
                    OutlinedButton(
                        onClick = { viewModel.previousQuestion() },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text("Previous Question")
                    }
                }
            }
        }
    }
}

@Composable
fun AnswerCard(
    answer: Answer,
    onAnswerSelected: () -> Unit
) {
    Card(
        onClick = onAnswerSelected,
        modifier = Modifier.fillMaxWidth()
    ) {
        Text(
            text = answer.text,
            style = MaterialTheme.typography.bodyLarge,
            modifier = Modifier.padding(16.dp)
        )
    }
}
