class Article {
  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.priceCents,
    required this.requiresPurchase,
    required this.updatedAt,
    this.author,
    this.synopsis,
    this.coverImageUrl,
  });

  final String id;
  final String title;
  final String content;
  final int priceCents;
  final bool requiresPurchase;
  final String updatedAt;
  final String? author;
  final String? synopsis;
  final String? coverImageUrl;

  bool get isFree => priceCents == 0;

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      priceCents: (json['priceCents'] as num).toInt(),
      requiresPurchase: json['requiresPurchase'] as bool? ?? false,
      updatedAt: json['updatedAt'] as String,
      author: json['author'] as String?,
      synopsis: json['synopsis'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
    );
  }
}
