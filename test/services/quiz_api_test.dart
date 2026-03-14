import 'dart:io' show Directory, File, Platform;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:yetimatch/config/app_config.dart';
import 'package:yetimatch/services/quiz_api.dart';

void main() {
  setUpAll(() {
    // 1) .env at project root (CWD when you run "flutter test" from repo root)
    final cwdEnv = '${Directory.current.path}/.env';
    if (File(cwdEnv).existsSync()) {
      AppConfig.init(envPath: cwdEnv);
    } else {
      final script = File(Platform.script.toFilePath());
      final projectRoot = script.parent.parent.parent;
      AppConfig.init(envPath: '${projectRoot.path}/.env');
    }
    // 2) Fallback: test/.api_key (gitignored). One line = key; lines starting with # ignored.
    if (AppConfig.apiKey.isEmpty) {
      final keyPath = '${Directory.current.path}/test/.api_key';
      final keyFile = File(keyPath);
      if (keyFile.existsSync()) {
        for (final line in keyFile.readAsLinesSync()) {
          final s = line.trim();
          if (s.isNotEmpty && !s.startsWith('#')) {
            AppConfig.setApiKeyForTesting(s);
            break;
          }
        }
      }
    }
  });

  group('QuizApi', () {
    test('listQuizzes returns empty when apiKey is empty', () async {
      final api = QuizApi(apiKey: '');
      final list = await api.listQuizzes();
      expect(list, isEmpty);
    });

    test('getQuiz returns null when apiKey is empty', () async {
      final api = QuizApi(apiKey: '');
      final quiz = await api.getQuiz('any-id');
      expect(quiz, isNull);
    });

    test('listQuizzes parses API response and maps to QuizMeta', () async {
      final api = QuizApi(
        apiKey: 'test-key',
        baseUrl: 'https://example.com',
        httpClient: (uri, {headers}) async => http.Response(
          '''
          {"quizzes": [
            {"id": "quiz-1", "title": "Quiz One", "description": "First quiz", "categoryId": "fun"}
          ]}
          ''',
          200,
        ),
      );
      final list = await api.listQuizzes();
      expect(list.length, 1);
      expect(list.first.id, 'quiz-1');
      expect(list.first.title, 'Quiz One');
      expect(list.first.categoryId, 'fun');
      expect(list.first.resourcePath, '');
    });

    test('listQuizzes returns empty on non-200 response', () async {
      final api = QuizApi(
        apiKey: 'key',
        baseUrl: 'https://example.com',
        httpClient: (_, {headers}) async => http.Response('', 401),
      );
      final list = await api.listQuizzes();
      expect(list, isEmpty);
    });

    test('listQuizzes filters out quizzes with empty title', () async {
      final api = QuizApi(
        apiKey: 'key',
        baseUrl: 'https://example.com',
        httpClient: (_, {headers}) async => http.Response(
          '{"quizzes": [{"id": "q1", "title": "", "description": "D"}, {"id": "q2", "title": "Valid", "description": "D"}]}',
          200,
        ),
      );
      final list = await api.listQuizzes();
      expect(list.length, 1);
      expect(list.first.title, 'Valid');
    });

    test('getQuiz parses API response to Quiz', () async {
      const quizJson = '''
      {
        "id": "coffee-quiz",
        "title": "Coffee Quiz",
        "description": "Which coffee?",
        "questions": [{"id": "q1", "text": "Q?", "answers": [{"id": "a1", "text": "A", "characterId": "c1"}]}],
        "results": [{"characterId": "c1", "characterName": "C1", "description": "D", "traits": []}]
      }
      ''';
      final api = QuizApi(
        apiKey: 'key',
        baseUrl: 'https://example.com',
        httpClient: (_, {headers}) async => http.Response(quizJson, 200),
      );
      final quiz = await api.getQuiz('coffee-quiz');
      expect(quiz, isNotNull);
      expect(quiz!.id, 'coffee-quiz');
      expect(quiz.title, 'Coffee Quiz');
      expect(quiz.questions.length, 1);
      expect(quiz.results.length, 1);
    });

    test('getQuiz returns null on non-200', () async {
      final api = QuizApi(
        apiKey: 'key',
        baseUrl: 'https://example.com',
        httpClient: (_, {headers}) async => http.Response('', 404),
      );
      final quiz = await api.getQuiz('any');
      expect(quiz, isNull);
    });

    test('getCategoryForQuiz returns mapping for known quiz', () {
      final api = QuizApi(apiKey: 'key');
      expect(api.getCategoryForQuiz('coffee-personality-quiz'), 'fun-entertainment');
      expect(api.getCategoryForQuiz('love-language-quiz'), 'relationship-love');
    });

    test('getCategoryForQuiz returns default for unknown quiz', () {
      final api = QuizApi(apiKey: 'key');
      expect(api.getCategoryForQuiz('unknown-quiz'), 'fun-entertainment');
    });

    test(
      'live API: listQuizzes and getQuiz return real data when API key is set',
      () async {
        expect(
          AppConfig.apiKey.isNotEmpty,
          true,
          reason: 'YETIMATCH_API_KEY must be set (.env or env). No skip—pass or fail.',
        );
        final api = QuizApi(); // real HTTP, no mock
        final list = await api.listQuizzes();
        expect(list, isNotEmpty, reason: 'API should return at least one quiz');
        final quizId = list.first.id;
        final quiz = await api.getQuiz(quizId);
        expect(quiz, isNotNull);
        expect(quiz!.id, quizId);
        expect(quiz.title, isNotEmpty);
        expect(quiz.questions, isNotEmpty,
            reason: 'Quiz from API should have questions');
        expect(quiz.results, isNotEmpty,
            reason: 'Quiz from API should have results');
      },
    );
  });
}
