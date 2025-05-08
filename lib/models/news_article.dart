// filepath: d:\Github\flutter\jp_learning\lib\models\news_article.dart
class NewsArticle {
  final String title;
  final String summary;
  final String imageUrl;
  // 可能還有 id, publicationDate, source 等欄位

  NewsArticle({
    required this.title,
    required this.summary,
    this.imageUrl = '',
    // 其他必要欄位
  });

  // 當從 API 獲取 JSON 資料時，通常會添加一個 factory constructor
  // 例如:
  // factory NewsArticle.fromJson(Map<String, dynamic> json) {
  //   return NewsArticle(
  //     title: json['title'] ?? '',
  //     summary: json['summary'] ?? '',
  //     imageUrl: json['imageUrl'] ?? '',
  //     // ... 其他欄位的解析 ...
  //   );
  // }

  // 如果需要將物件轉換回 JSON (例如，發送到 API)
  // Map<String, dynamic> toJson() {
  //   return {
  //     'title': title,
  //     'summary': summary,
  //     'imageUrl': imageUrl,
  //     // ... 其他欄位 ...
  //   };
  // }
}
