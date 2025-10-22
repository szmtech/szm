import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/article.dart';

class ArticleService {
  ArticleService({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  String baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');

  Future<List<Article>> fetchArticles({required String userId}) async {
    final uri = Uri.parse('$baseUrl/articles').replace(queryParameters: {'userId': userId});
    final response = await _httpClient.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load articles');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => Article.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Article> fetchArticle({required String id, required String userId}) async {
    final uri = Uri.parse('$baseUrl/articles/$id').replace(queryParameters: {'userId': userId});
    final response = await _httpClient.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load article');
    }

    return Article.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> purchaseArticle({required String id, required String userId}) async {
    final uri = Uri.parse('$baseUrl/articles/$id/purchase');
    final response = await _httpClient.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'userId': userId}));

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to purchase article');
    }
  }
}
