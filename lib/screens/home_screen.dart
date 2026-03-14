import 'package:flutter/material.dart';

import '../models/manifest.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.manifest,
    required this.searchQuery,
    required this.onSearchQueryChange,
    required this.onCategoryClick,
    required this.onQuizClick,
  });

  final QuizManifest? manifest;
  final String searchQuery;
  final ValueChanged<String> onSearchQueryChange;
  final ValueChanged<String> onCategoryClick;
  final ValueChanged<QuizMeta> onQuizClick;

  @override
  Widget build(BuildContext context) {
    final filtered = _filterQuizzes(manifest, searchQuery);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: onSearchQueryChange,
            decoration: const InputDecoration(
              hintText: 'Search quizzes...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: searchQuery.isNotEmpty
              ? (filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No quizzes match "$searchQuery"',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => _QuizMetaCard(
                        meta: filtered[i],
                        onTap: () => onQuizClick(filtered[i]),
                      ),
                    ))
              : (manifest == null
                  ? const SizedBox.shrink()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: (manifest!.categories.length + 1) ~/ 2,
                      itemBuilder: (_, rowIndex) {
                        final i = rowIndex * 2;
                        final left = manifest!.categories[i];
                        final right = i + 1 < manifest!.categories.length
                            ? manifest!.categories[i + 1]
                            : null;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _CategoryCard(
                                  category: left,
                                  onTap: () =>
                                      onCategoryClick(left.id),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: right != null
                                    ? _CategoryCard(
                                        category: right,
                                        onTap: () =>
                                            onCategoryClick(right.id),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        );
                      },
                    )),
        ),
      ],
    );
  }

  List<QuizMeta> _filterQuizzes(QuizManifest? m, String query) {
    if (m == null || query.isEmpty) return [];
    final q = query.toLowerCase();
    final categoryNames = {
      for (final c in m.categories) c.id: c.name.toLowerCase(),
    };
    return m.quizzes.where((meta) {
      return meta.title.toLowerCase().contains(q) ||
          meta.description.toLowerCase().contains(q) ||
          (categoryNames[meta.categoryId]?.contains(q) ?? false);
    }).toList();
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = categoryCardColor(
      theme.colorScheme,
      theme.brightness,
    );
    return Card(
      elevation: 2,
      color: cardColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                category.name,
                style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                category.description,
                style: theme.textTheme.bodySmall,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizMetaCard extends StatelessWidget {
  const _QuizMetaCard({required this.meta, required this.onTap});

  final QuizMeta meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          meta.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        subtitle: Text(meta.description),
        onTap: onTap,
      ),
    );
  }
}
