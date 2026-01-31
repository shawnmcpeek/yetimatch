package com.daddoodev.yetimatch.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.daddoodev.yetimatch.models.QuizMeta
import com.daddoodev.yetimatch.preferences.getAgeVerified
import com.daddoodev.yetimatch.preferences.setAgeVerified

@Composable
fun QuizMetaCard(
    meta: QuizMeta,
    onClick: () -> Unit
) {
    Card(
        onClick = onClick,
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(
                text = meta.title,
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.primary
            )
            Text(
                text = meta.description,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
fun AgeGateDialog(
    onConfirm: () -> Unit,
    onDismiss: () -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Adult content") },
        text = {
            Text("You must be 18 or older to view adult content.")
        },
        confirmButton = {
            TextButton(onClick = onConfirm) {
                Text("I am 18 or older")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}

@Composable
fun CategoryDetailScreen(
    categoryName: String,
    quizzes: List<QuizMeta>,
    onQuizClick: (QuizMeta) -> Unit,
    matureQuizzes: List<QuizMeta> = emptyList(),
    onAdultQuizzesClick: (() -> Unit)? = null,
    onAgeVerifiedPassed: () -> Unit = {}
) {
    var showAgeGate by remember { mutableStateOf(false) }
    val ageVerified = getAgeVerified()

    if (showAgeGate) {
        AgeGateDialog(
            onConfirm = {
                setAgeVerified(true)
                onAgeVerifiedPassed()
                showAgeGate = false
                onAdultQuizzesClick?.invoke()
            },
            onDismiss = { showAgeGate = false }
        )
    }

    Column(modifier = Modifier.fillMaxWidth()) {
        Text(
            text = categoryName,
            style = MaterialTheme.typography.headlineSmall,
            color = MaterialTheme.colorScheme.primary,
            modifier = Modifier.padding(16.dp)
        )
        if (quizzes.isEmpty() && matureQuizzes.isEmpty()) {
            Text(
                text = "No quizzes in this category yet.",
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(16.dp)
            )
        } else {
            LazyColumn(
                contentPadding = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                items(quizzes, key = { it.id }) { meta ->
                    QuizMetaCard(meta = meta, onClick = { onQuizClick(meta) })
                }
                if (matureQuizzes.isNotEmpty() && onAdultQuizzesClick != null) {
                    item(key = "adult_card") {
                        Card(
                            onClick = {
                                if (ageVerified) {
                                    onAdultQuizzesClick()
                                } else {
                                    showAgeGate = true
                                }
                            },
                            modifier = Modifier.fillMaxWidth(),
                            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant),
                            elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
                        ) {
                            Column(modifier = Modifier.padding(16.dp)) {
                                Text(
                                    text = "Adult quizzes",
                                    style = MaterialTheme.typography.titleMedium,
                                    color = MaterialTheme.colorScheme.primary
                                )
                                Text(
                                    text = "18+ only. Tap to verify age and view.",
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}
