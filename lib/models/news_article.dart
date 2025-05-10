// filepath: d:\Github\flutter\jp_learning\lib\models\news_article.dart
class NewsArticle {
  final String title;
  final String summary;
  final String imageUrl;
  final String newsWebUrl; // 新增網頁連結欄位

  NewsArticle({
    required this.title,
    required this.summary,
    this.imageUrl = '',
    this.newsWebUrl = '', // 初始化
  });

  // 當從 API 獲取 JSON 資料時，通常會添加一個 factory constructor
  // 例如:
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title:
          json['title_with_ruby'] ??
          json['title'] ??
          '標題載入失敗', // NHK Easy News 的帶假名標題
      summary: json['title'] ?? '詳細內容待載入', // NHK Easy News 的原始標題作為摘要
      imageUrl: json['news_web_image_uri'] ?? '', // NHK Easy News 的圖片網址
      newsWebUrl: json['news_web_url'] ?? '', // 解析 news_web_url
    );
  }

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
