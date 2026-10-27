import 'package:flutter/material.dart';

import '../models/saved_quiz_result.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    super.key,
    required this.results,
    required this.loading,
    required this.error,
    required this.onRetry,
    required this.onOpenResult,
  });

  final List<SavedQuizResult> results;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;
  final void Function(SavedQuizResult result) onOpenResult;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No saved results yet. Finish a quiz to build your history.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final r = results[index];
        return ListTile(
          title: Text(r.quizTitle.isEmpty ? r.quizId : r.quizTitle),
          subtitle: Text(r.characterName),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => onOpenResult(r),
        );
      },
    );
  }
}

class HistoryDetailScreen extends StatelessWidget {
  const HistoryDetailScreen({
    super.key,
    required this.result,
  });

  final SavedQuizResult result;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            result.quizTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
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
          if (result.traits.isNotEmpty) ...[
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
          ],
        ],
      ),
    );
  }
}
