import 'package:flutter/material.dart';

import '../state/quiz_state.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.quizState,
    required this.onQuizComplete,
    required this.onLeaveQuiz,
  });

  final QuizState quizState;
  final VoidCallback onQuizComplete;
  final VoidCallback onLeaveQuiz;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _completionNotified = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Leave quiz?'),
            content: const Text('Your progress on this quiz will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Stay'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Leave'),
              ),
            ],
          ),
        );
        if (leave == true && context.mounted) {
          widget.onLeaveQuiz();
        }
      },
      child: ListenableBuilder(
        listenable: widget.quizState,
        builder: (context, _) {
          if (widget.quizState.isQuizComplete && !_completionNotified) {
            _completionNotified = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.onQuizComplete();
            });
          }
          final quiz = widget.quizState.currentQuiz;
          if (quiz == null) return const SizedBox.shrink();
          final questionIndex = widget.quizState.currentQuestionIndex;
          final question = questionIndex < quiz.questions.length
              ? quiz.questions[questionIndex]
              : null;
          if (question == null) return const SizedBox.shrink();

          final progress = widget.quizState.getProgress() / 100;

          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 16),
                  Text(
                    'Question ${questionIndex + 1} of ${quiz.questions.length}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    question.text,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: ListView.separated(
                      itemCount: question.answers.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final answer = question.answers[i];
                        return Card(
                          child: ListTile(
                            title: Text(answer.text),
                            onTap: () =>
                                widget.quizState.answerQuestion(answer.id),
                          ),
                        );
                      },
                    ),
                  ),
                  if (questionIndex > 0) ...[
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => widget.quizState.previousQuestion(),
                      child: const Text('Previous Question'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
