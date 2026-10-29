import 'package:flutter_test/flutter_test.dart';
import 'package:yetimatch/state/quiz_state.dart';
import 'package:yetimatch/models/quiz.dart';

void main() {
  test('QuizState completion stays complete after last answer', () {
    final quiz = Quiz(
      id: 't',
      title: 'T',
      description: 'D',
      questions: [
        Question(
          id: 'q1',
          text: 'Q?',
          answers: [
            Answer(id: 'a1', text: 'A', characterId: 'c1'),
          ],
        ),
      ],
      results: [
        QuizResult(
          characterId: 'c1',
          characterName: 'Hero',
          description: 'You are a hero',
          traits: const ['brave'],
        ),
      ],
    );
    final state = QuizState();
    state.startQuiz(quiz);
    expect(state.isQuizComplete, isFalse);
    state.answerQuestion('a1');
    expect(state.isQuizComplete, isTrue);
    expect(state.result?.characterName, 'Hero');
  });
}
