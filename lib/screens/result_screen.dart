import 'package:flutter/material.dart';

import '../services/result_share_service.dart';
import '../state/quiz_state.dart';

class ResultScreen extends StatefulWidget {
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
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _shareService = ResultShareService();
  bool _sharing = false;

  Future<void> _share() async {
    final quiz = widget.quizState.currentQuiz;
    final result = widget.quizState.result;
    if (quiz == null || result == null || _sharing) return;

    setState(() => _sharing = true);
    try {
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;
      await _shareService.shareResult(
        quizTitle: quiz.title,
        characterName: result.characterName,
        sharePositionOrigin: origin,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not share: $e')),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.quizState.result;
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
            children:
                result.traits.map((t) => Chip(label: Text(t))).toList(),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _sharing ? null : _share,
            icon: _sharing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.share),
            label: Text(_sharing ? 'Preparing…' : 'Share result'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              widget.quizState.restartQuiz();
              widget.onRetakeQuiz();
            },
            child: const Text('Retake Quiz'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: widget.onBackToHome,
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}
