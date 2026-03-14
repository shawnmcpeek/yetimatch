import 'package:flutter_test/flutter_test.dart';
import 'package:yetimatch/models/quiz.dart';
import 'package:yetimatch/state/quiz_state.dart';

void main() {
  group('QuizState', () {
    late QuizState state;
    late Quiz sampleQuiz;

    setUp(() {
      state = QuizState();
      sampleQuiz = Quiz(
        id: 'test',
        title: 'Test Quiz',
        description: 'Desc',
        questions: [
          Question(
            id: 'q1',
            text: 'Question 1?',
            answers: [
              const Answer(id: 'a1', text: 'A1', characterId: 'c1'),
              const Answer(id: 'a2', text: 'A2', characterId: 'c2'),
            ],
          ),
          Question(
            id: 'q2',
            text: 'Question 2?',
            answers: [
              const Answer(id: 'a1', text: 'A1', characterId: 'c1'),
              const Answer(id: 'a2', text: 'A2', characterId: 'c2'),
            ],
          ),
        ],
        results: [
          const QuizResult(
            characterId: 'c1',
            characterName: 'C1',
            description: 'Result 1',
            traits: [],
          ),
          const QuizResult(
            characterId: 'c2',
            characterName: 'C2',
            description: 'Result 2',
            traits: [],
          ),
        ],
      );
    });

    test('initial state has no quiz and progress 0', () {
      expect(state.currentQuiz, isNull);
      expect(state.currentQuestionIndex, 0);
      expect(state.selectedAnswers, isEmpty);
      expect(state.result, isNull);
      expect(state.isQuizComplete, false);
      expect(state.getProgress(), 0);
    });

    test('startQuiz sets quiz and resets state', () {
      state.startQuiz(sampleQuiz);
      expect(state.currentQuiz, sampleQuiz);
      expect(state.currentQuestionIndex, 0);
      expect(state.selectedAnswers, isEmpty);
      expect(state.result, isNull);
      expect(state.isQuizComplete, false);
    });

    test('answerQuestion updates selectedAnswers and advances index', () {
      state.startQuiz(sampleQuiz);
      state.answerQuestion('a1');
      expect(state.selectedAnswers['q1'], 'a1');
      expect(state.currentQuestionIndex, 1);
      expect(state.isQuizComplete, false);
    });

    test('answerQuestion on last question sets result and completes', () {
      state.startQuiz(sampleQuiz);
      state.answerQuestion('a1');
      state.answerQuestion('a1');
      expect(state.isQuizComplete, true);
      expect(state.result, isNotNull);
      expect(state.result!.characterId, 'c1');
    });

    test('previousQuestion decrements index', () {
      state.startQuiz(sampleQuiz);
      state.answerQuestion('a1');
      expect(state.currentQuestionIndex, 1);
      state.previousQuestion();
      expect(state.currentQuestionIndex, 0);
    });

    test('previousQuestion does nothing at 0', () {
      state.startQuiz(sampleQuiz);
      state.previousQuestion();
      expect(state.currentQuestionIndex, 0);
    });

    test('getProgress returns percentage', () {
      state.startQuiz(sampleQuiz);
      expect(state.getProgress(), 50); // index 0 of 2 questions = (0+1)/2*100
      state.answerQuestion('a1');
      expect(state.getProgress(), 100);
    });

    test('restartQuiz resets to start', () {
      state.startQuiz(sampleQuiz);
      state.answerQuestion('a1');
      state.restartQuiz();
      expect(state.currentQuestionIndex, 0);
      expect(state.selectedAnswers, isEmpty);
      expect(state.result, isNull);
      expect(state.isQuizComplete, false);
    });

    test('answerQuestion no-op when no quiz started', () {
      state.answerQuestion('a1');
      expect(state.currentQuiz, isNull);
      expect(state.selectedAnswers, isEmpty);
    });
  });
}
