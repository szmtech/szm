import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/article_list_page.dart';
import 'services/article_service.dart';
import 'state/article_provider.dart';

void main() {
  runApp(const ReaderApp());
}

class ReaderApp extends StatelessWidget {
  const ReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    const userId = 'demo-user';
    final articleService = ArticleService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ArticleProvider>(
          create: (_) => ArticleProvider(articleService: articleService, userId: userId),
        ),
      ],
      child: MaterialApp(
        title: 'SZM 阅读器',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const ArticleListPage(),
      ),
    );
  }
}
