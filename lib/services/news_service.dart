import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';

class NewsService {
  final String _newsListUrl = 'https://www3.nhk.or.jp/news/easy/news-list.json';

  Future<List<NewsArticle>> fetchNewsArticles() async {
    try {
      final response = await http.get(Uri.parse(_newsListUrl));

      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> rootList = json.decode(responseBody);
        List<NewsArticle> articles = [];
        // 計算三天前的日期
        final DateTime threshold = DateTime.now().subtract(
          const Duration(days: 10),
        );

        // 遍歷每個日期分組
        for (final group in rootList) {
          if (group is Map<String, dynamic>) {
            group.forEach((dateKey, newsList) {
              try {
                final DateTime newsDate = DateTime.parse(dateKey);
                // 如果日期在三天以內（包含三天前當天）
                if (newsDate.isAfter(threshold) ||
                    newsDate.isAtSameMomentAs(threshold)) {
                  if (newsList is List<dynamic>) {
                    articles.addAll(
                      newsList
                          .map(
                            (item) => NewsArticle.fromJson(
                              item as Map<String, dynamic>,
                            ),
                          )
                          .toList(),
                    );
                  }
                }
              } catch (e) {
                print("日期解析錯誤，日期: $dateKey, 異常: $e");
              }
            });
          }
        }
        return articles;
      } else {
        throw Exception('無法載入新聞: ${response.statusCode}');
      }
    } catch (e) {
      print('擷取新聞時發生錯誤: $e');
      throw Exception('無法載入新聞: $e');
    }
  }
}
