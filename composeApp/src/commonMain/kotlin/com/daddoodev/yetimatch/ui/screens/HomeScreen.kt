package com.daddoodev.yetimatch.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.daddoodev.yetimatch.models.Category
import com.daddoodev.yetimatch.models.QuizManifest
import com.daddoodev.yetimatch.models.QuizMeta
import com.daddoodev.yetimatch.ui.YetiMatchLogo

@Composable
fun CategoryCard(
    category: Category,
    onClick: () -> Unit
) {
    Card(
        onClick = onClick,
        modifier = Modifier
            .fillMaxWidth()
            .padding(4.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(
                text = category.name,
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.primary
            )
            Text(
                text = category.description,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
fun HomeScreen(
    manifest: QuizManifest?,
    searchQuery: String,
    onSearchQueryChange: (String) -> Unit,
    onCategoryClick: (String) -> Unit,
    onQuizClick: (QuizMeta) -> Unit
) {
    val filteredQuizzes = remember(manifest, searchQuery) {
        if (manifest == null || searchQuery.isBlank()) emptyList()
        else {
            val q = searchQuery.lowercase()
            val categoryNames = manifest.categories.associate { it.id to it.name.lowercase() }
            manifest.quizzes.filter { meta ->
                meta.title.lowercase().contains(q) ||
                    meta.description.lowercase().contains(q) ||
                    categoryNames[meta.categoryId]?.contains(q) == true
            }
        }
    }

    Column(modifier = Modifier.fillMaxWidth()) {
        YetiMatchLogo(size = 80.dp, modifier = Modifier.padding(top = 16.dp))
        Spacer(modifier = Modifier.height(16.dp))
        OutlinedTextField(
            value = searchQuery,
            onValueChange = onSearchQueryChange,
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            placeholder = { Text("Search quizzes...") },
            singleLine = true
        )

        if (searchQuery.isNotBlank()) {
            if (filteredQuizzes.isEmpty()) {
                Text(
                    text = "No quizzes match \"$searchQuery\"",
                    style = MaterialTheme.typography.bodyLarge,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.padding(16.dp)
                )
            } else {
                LazyColumn(
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    items(filteredQuizzes, key = { it.id }) { meta ->
                        QuizMetaCard(meta = meta, onClick = { onQuizClick(meta) })
                    }
                }
            }
        } else if (manifest != null) {
            LazyVerticalGrid(
                columns = GridCells.Fixed(2),
                contentPadding = PaddingValues(16.dp),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                items(manifest.categories, key = { it.id }) { cat ->
                    CategoryCard(category = cat, onClick = { onCategoryClick(cat.id) })
                }
            }
        }
    }
}

