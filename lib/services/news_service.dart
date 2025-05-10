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
        // API 回傳的是一個 List，其中包含一個 Map (或多個，如果 API 設計如此)
        // 每個 Map 的 key 是日期，value 是新聞列表
        final List<dynamic> rootList = json.decode(responseBody);

        if (rootList.isNotEmpty) {
          // 我們假設只處理第一個日期分組的物件
          // 這個物件是一個 Map<String, List<dynamic>>
          final Map<String, dynamic> dateGroupMap =
              rootList[0] as Map<String, dynamic>;

          if (dateGroupMap.keys.isNotEmpty) {
            // 取得第一個日期鍵 (例如 "2025-05-09")
            final String dateKey = dateGroupMap.keys.first;
            // 取得該日期下的新聞列表 (List<dynamic>)
            final List<dynamic> newsListJson =
                dateGroupMap[dateKey] as List<dynamic>;

            List<NewsArticle> articles =
                newsListJson
                    .map(
                      (item) =>
                          NewsArticle.fromJson(item as Map<String, dynamic>),
                    )
                    .toList();
            return articles;
          } else {
            return []; // 日期分組的 Map 為空
          }
        } else {
          return []; // API 回傳的根列表為空
        }
      } else {
        throw Exception('無法載入新聞: ${response.statusCode}');
      }
    } catch (e) {
      print('擷取新聞時發生錯誤: $e');
      throw Exception('無法載入新聞: $e');
    }
  }
}
