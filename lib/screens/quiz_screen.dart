import 'package:flutter/material.dart';

import '../state/quiz_state.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({
    super.key,
    required this.quizState,
    required this.onQuizComplete,
  });

  final QuizState quizState;
  final VoidCallback onQuizComplete;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: quizState,
      builder: (context, _) {
        if (quizState.isQuizComplete) {
          WidgetsBinding.instance.addPostFrameCallback((_) => onQuizComplete());
        }
        final quiz = quizState.currentQuiz;
        if (quiz == null) return const SizedBox.shrink();
        final questionIndex = quizState.currentQuestionIndex;
        final question = questionIndex < quiz.questions.length
            ? quiz.questions[questionIndex]
            : null;
        if (question == null) return const SizedBox.shrink();

        final progress = quizState.getProgress() / 100;

        return Padding(
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
                  separatorBuilder: (_, i) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final answer = question.answers[i];
                    return Card(
                      child: ListTile(
                        title: Text(answer.text),
                        onTap: () => quizState.answerQuestion(answer.id),
                      ),
                    );
                  },
                ),
              ),
              if (questionIndex > 0) ...[
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => quizState.previousQuestion(),
                  child: const Text('Previous Question'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
