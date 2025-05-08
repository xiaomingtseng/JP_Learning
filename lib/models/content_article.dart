// filepath: d:\Github\flutter\jp_learning\lib\models\content_article.dart
class ContentArticle {
  final String title;
  final String author;
  final String snippet;
  // 可能還有 id, fullContent, category, tags 等欄位

  ContentArticle({
    required this.title,
    required this.author,
    required this.snippet,
    // 其他必要欄位
  });

  // 同樣，可以添加 fromJson 和 toJson 方法
  // factory ContentArticle.fromJson(Map<String, dynamic> json) {
  //   return ContentArticle(
  //     title: json['title'] ?? '',
  //     author: json['author'] ?? '',
  //     snippet: json['snippet'] ?? '',
  //     // ...
  //   );
  // }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'title': title,
  //     'author': author,
  //     'snippet': snippet,
  //     // ...
  //   };
  // }
}
