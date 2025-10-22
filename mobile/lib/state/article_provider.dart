import 'package:flutter/foundation.dart';

import '../models/article.dart';
import '../services/article_service.dart';

class ArticleProvider extends ChangeNotifier {
  ArticleProvider({required this.articleService, required this.userId});

  final ArticleService articleService;
  final String userId;

  List<Article> _articles = <Article>[];
  bool _isLoading = false;
  String? _errorMessage;

  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadArticles() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _articles = await articleService.fetchArticles(userId: userId);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Article?> refreshArticle(String id) async {
    try {
      final article = await articleService.fetchArticle(id: id, userId: userId);
      final index = _articles.indexWhere((item) => item.id == id);
      if (index >= 0) {
        _articles[index] = article;
        notifyListeners();
      }
      return article;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> purchaseArticle(String id) async {
    try {
      await articleService.purchaseArticle(id: id, userId: userId);
      await refreshArticle(id);
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }
}
