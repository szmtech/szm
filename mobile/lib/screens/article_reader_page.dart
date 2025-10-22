import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../state/article_provider.dart';

class ArticleReaderPage extends StatefulWidget {
  const ArticleReaderPage({super.key, required this.articleId, this.initialArticle});

  final String articleId;
  final Article? initialArticle;

  @override
  State<ArticleReaderPage> createState() => _ArticleReaderPageState();
}

class _ArticleReaderPageState extends State<ArticleReaderPage> {
  Article? _article;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _article = widget.initialArticle;
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final provider = context.read<ArticleProvider>();
    final result = await provider.refreshArticle(widget.articleId);
    if (!mounted) return;

    setState(() {
      _article = result ?? _article;
      _errorMessage = provider.errorMessage;
      _isLoading = false;
    });
  }

  Future<void> _handlePurchase() async {
    final provider = context.read<ArticleProvider>();
    setState(() {
      _isLoading = true;
    });
    final success = await provider.purchaseArticle(widget.articleId);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _errorMessage = success ? null : provider.errorMessage;
      if (success) {
        _article = provider.articles.firstWhere((article) => article.id == widget.articleId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final article = _article;

    return Scaffold(
      appBar: AppBar(
        title: Text(article?.title ?? '文章详情'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading && article == null
            ? const Center(child: CircularProgressIndicator())
            : article == null
                ? Center(child: Text(_errorMessage ?? '文章不存在'))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        article.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      if (article.author != null)
                        Text(
                          article.author!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      const SizedBox(height: 4),
                      Text(
                        '更新于 ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(article.updatedAt))}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Divider(height: 32),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            article.content,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
                          ),
                        ),
                      ),
                      if (article.requiresPurchase)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(
                                '完整内容需付费解锁',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _isLoading ? null : _handlePurchase,
                                child: Text('支付 ¥ ${(article.priceCents / 100).toStringAsFixed(2)}'),
                              ),
                              if (_errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                            ],
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}

