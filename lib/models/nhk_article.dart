// filepath: lib/models/nhk_article.dart
class NhkArticle {
  final String newsId;
  final String title;
  final String publishedDate;
  final String pageUrl; // 這將直接來自 JSON 中的 news_web_url
  final String? imageUrl;

  NhkArticle({
    required this.newsId,
    required this.title,
    required this.publishedDate,
    required this.pageUrl,
    this.imageUrl,
  });

  factory NhkArticle.fromJson(Map<String, dynamic> json, int index) {
    // *** 請根據您實際的 JSON 結構修改以下欄位名稱 ***
    String newsId = json['news_id']?.toString() ?? 'unknown_id_$index';
    String title = json['title'] ?? '無標題';
    String publishedDate =
        json['pubDate'] ?? json['publication_time'] ?? ''; // 嘗試不同的日期欄位
    String pageUrl = json['news_web_url'] ?? ''; // 直接使用 JSON 中的 URL
    String? imageUrl = json['image_url'] ?? json['image']?['url']; // 嘗試不同的圖片欄位

    if (pageUrl.isEmpty) {
      // 如果 pageUrl 為空，可以考慮拋出錯誤或提供一個預設的不可用 URL
      print("警告: News ID $newsId 的 pageUrl 為空。");
      // pageUrl = 'https://www.nhk.or.jp/unavailable-article/'; // 或者其他處理方式
    }

    return NhkArticle(
      newsId: newsId,
      title: title,
      publishedDate: publishedDate,
      pageUrl: pageUrl,
      imageUrl: imageUrl,
    );
  }
}
