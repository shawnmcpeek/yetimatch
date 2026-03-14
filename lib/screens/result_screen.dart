import 'package:flutter/material.dart';

import '../state/quiz_state.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.quizState,
    required this.onRetakeQuiz,
    required this.onBackToHome,
  });

  final QuizState quizState;
  final VoidCallback onRetakeQuiz;
  final VoidCallback onBackToHome;

  @override
  Widget build(BuildContext context) {
    final result = quizState.result;
    if (result == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'You are...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            result.characterName,
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                result.description,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Traits:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: result.traits
                .map((t) => ActionChip(
                      label: Text(t),
                      onPressed: () {},
                    ))
                .toList(),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () {
              quizState.restartQuiz();
              onRetakeQuiz();
            },
            child: const Text('Retake Quiz'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onBackToHome,
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}
