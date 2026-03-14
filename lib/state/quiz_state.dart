import 'package:flutter/foundation.dart';

import '../models/quiz.dart';
import '../services/quiz_service.dart';

class QuizState extends ChangeNotifier {
  QuizState({QuizService? quizService})
      : _quizService = quizService ?? QuizService();

  final QuizService _quizService;

  Quiz? _currentQuiz;
  Quiz? get currentQuiz => _currentQuiz;

  int _currentQuestionIndex = 0;
  int get currentQuestionIndex => _currentQuestionIndex;

  final Map<String, String> _selectedAnswers = {};
  Map<String, String> get selectedAnswers =>
      Map<String, String>.unmodifiable(_selectedAnswers);

  QuizResult? _result;
  QuizResult? get result => _result;

  bool _isQuizComplete = false;
  bool get isQuizComplete => _isQuizComplete;

  void startQuiz(Quiz quiz) {
    _currentQuiz = quiz;
    _currentQuestionIndex = 0;
    _selectedAnswers.clear();
    _result = null;
    _isQuizComplete = false;
    notifyListeners();
  }

  void answerQuestion(String answerId) {
    final quiz = _currentQuiz;
    if (quiz == null) return;
    final question =
        _currentQuestionIndex < quiz.questions.length
            ? quiz.questions[_currentQuestionIndex]
            : null;
    if (question == null) return;
    _selectedAnswers[question.id] = answerId;
    if (_currentQuestionIndex < quiz.questions.length - 1) {
      _currentQuestionIndex++;
    } else {
      _result = _quizService.calculateResult(quiz, _selectedAnswers);
      _isQuizComplete = true;
    }
    notifyListeners();
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  void restartQuiz() {
    if (_currentQuiz != null) {
      startQuiz(_currentQuiz!);
    }
  }

  double getProgress() {
    final quiz = _currentQuiz;
    if (quiz == null || quiz.questions.isEmpty) return 0;
    return (_currentQuestionIndex + 1) / quiz.questions.length * 100;
  }
}
