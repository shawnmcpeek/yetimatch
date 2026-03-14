class QuizManifest {
  const QuizManifest({
    required this.categories,
    required this.quizzes,
  });

  final List<Category> categories;
  final List<QuizMeta> quizzes;

  factory QuizManifest.fromJson(Map<String, dynamic> json) {
    return QuizManifest(
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      quizzes: (json['quizzes'] as List<dynamic>?)
              ?.map((e) => QuizMeta.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class QuizMeta {
  const QuizMeta({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    this.resourcePath = '',
  });

  final String id;
  final String title;
  final String description;
  final String categoryId;
  final String resourcePath;

  factory QuizMeta.fromJson(Map<String, dynamic> json) {
    return QuizMeta(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      resourcePath: json['resourcePath'] as String? ?? '',
    );
  }
}
