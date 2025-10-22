import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/article_provider.dart';
import '../widgets/article_card.dart';
import 'article_reader_page.dart';

class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key});

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArticleProvider>().loadArticles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SZM 阅读器'),
      ),
      body: Consumer<ArticleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('加载失败：${provider.errorMessage}'),
              ),
            );
          }

          if (provider.articles.isEmpty) {
            return const Center(child: Text('暂无文章'));
          }

          return RefreshIndicator(
            onRefresh: provider.loadArticles,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.articles.length,
              itemBuilder: (context, index) {
                final article = provider.articles[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ArticleCard(
                    article: article,
                    onTap: () async {
                      await Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (_) => ArticleReaderPage(articleId: article.id, initialArticle: article),
                      ));
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
