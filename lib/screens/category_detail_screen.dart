import 'package:flutter/material.dart';

import '../models/manifest.dart';

class CategoryDetailScreen extends StatelessWidget {
  const CategoryDetailScreen({
    super.key,
    required this.categoryName,
    required this.quizzes,
    required this.onQuizClick,
  });

  final String categoryName;
  final List<QuizMeta> quizzes;
  final ValueChanged<QuizMeta> onQuizClick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            categoryName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        Expanded(
          child: quizzes.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No quizzes in this category yet.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: quizzes.length,
                  itemBuilder: (_, i) => Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        quizzes[i].title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                ),
                      ),
                      subtitle: Text(quizzes[i].description),
                      onTap: () => onQuizClick(quizzes[i]),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
