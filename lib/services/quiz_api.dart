import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/manifest.dart';
import '../models/quiz.dart';

const _baseUrl = 'https://ymapi-tkbt6ug22q-uc.a.run.app/ym/v2';

/// Injectable for tests. If null, uses [http.get].
typedef HttpClient = Future<http.Response> Function(
  Uri uri, {
  Map<String, String>? headers,
});

final _quizIdToCategory = <String, String>{
  'fabulous-five': 'personality-self',
  'coffee-personality-quiz': 'fun-entertainment',
  'learning-style-quiz': 'wellness-mindset',
  'mythical-beast-quiz': 'who-am-i',
  'pet-personality-quiz': 'fun-entertainment',
  'planet-personality-quiz': 'who-am-i',
  'season-personality-quiz': 'personality-self',
  'traveler-personality-quiz': 'personality-self',
  'yetimatch-soulmate': 'who-am-i',
  'spirit-composer-match': 'who-am-i',
  'love-language-quiz': 'relationship-love',
  'compatibility-style-quiz': 'relationship-love',
};

class QuizApi {
  QuizApi({
    String? apiKey,
    String? baseUrl,
    HttpClient? httpClient,
  })  : apiKey = apiKey ?? AppConfig.apiKey,
        baseUrl = baseUrl ?? _baseUrl,
        _httpClient = httpClient ?? _defaultHttpClient;

  final String apiKey;
  final String baseUrl;
  final HttpClient _httpClient;

  static Future<http.Response> _defaultHttpClient(
    Uri uri, {
    Map<String, String>? headers,
  }) =>
      http.get(uri, headers: headers);

  Future<List<QuizMeta>> listQuizzes() async {
    if (apiKey.isEmpty) return [];
    final uri = Uri.parse('$baseUrl/quizzes');
    final response = await _httpClient(
      uri,
      headers: {'X-API-Key': apiKey},
    );
    if (response.statusCode != 200) return [];
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final list = body['quizzes'] as List<dynamic>? ?? [];
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      final id = m['id'] as String? ?? '';
      return QuizMeta(
        id: id,
        title: m['title'] as String? ?? '',
        description: m['description'] as String? ?? '',
        categoryId: m['categoryId'] as String? ?? getCategoryForQuiz(id),
        resourcePath: '',
      );
    }).where((q) => q.title.isNotEmpty).toList();
  }

  Future<Quiz?> getQuiz(String id) async {
    if (apiKey.isEmpty) return null;
    final uri = Uri.parse('$baseUrl/quizzes/$id');
    final response = await _httpClient(
      uri,
      headers: {'X-API-Key': apiKey},
    );
    if (response.statusCode != 200) return null;
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    return Quiz.fromJson(map);
  }

  String getCategoryForQuiz(String quizId) =>
      _quizIdToCategory[quizId] ?? 'fun-entertainment';
}
