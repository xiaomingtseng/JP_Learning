import 'package:flutter/material.dart';
import '../models/content_article.dart';

class ArticleListItemWidget extends StatelessWidget {
  final ContentArticle article;
  final VoidCallback onTap;

  const ArticleListItemWidget({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.0,
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0),
      child: ListTile(
        title: Text(
          article.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${article.author}\n${article.snippet}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        onTap: onTap,
      ),
    );
  }
}
