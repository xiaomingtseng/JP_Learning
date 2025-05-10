// filepath: lib/services/article_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nhk_article.dart';

class ArticleService {
  // NHK News Web Easy 的新聞列表 JSON URL
  static const String _nhkNewsListUrl =
      'https://www3.nhk.or.jp/news/easy/news-list.json';
  static const int maxArticlesToDisplay = 10; // 設定要顯示的文章數量上限

  Future<List<NhkArticle>> fetchNhkArticles() async {
    try {
      final response = await http.get(Uri.parse(_nhkNewsListUrl));

      if (response.statusCode == 200) {
        String responseBody = utf8.decode(response.bodyBytes);
        if (responseBody.startsWith('\ufeff')) {
          responseBody = responseBody.substring(1);
        }

        final List<dynamic> jsonData = json.decode(responseBody);
        List<NhkArticle> allFetchedArticles = []; // 用於存放所有解析出來的文章

        if (jsonData.isNotEmpty && jsonData[0] is Map) {
          final Map<String, dynamic> newsByDate = jsonData[0];
          newsByDate.forEach((date, newsList) {
            if (newsList is List) {
              allFetchedArticles.addAll(
                newsList.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> newsData = entry.value;
                  // 確保 NhkArticle.fromJson 能夠處理 newsData 的結構
                  return NhkArticle.fromJson(newsData, index);
                }).toList(),
              );
            }
          });

          // 根據發布日期排序，確保獲取的是最新的文章
          allFetchedArticles.sort(
            (a, b) => b.publishedDate.compareTo(a.publishedDate),
          );

          // 截取指定數量的文章
          if (allFetchedArticles.length > maxArticlesToDisplay) {
            return allFetchedArticles.sublist(0, maxArticlesToDisplay);
          }
          return allFetchedArticles; // 如果總數少於上限，則返回全部
        } else {
          // 如果 JSON 結構與預期的 news-list.json 格式不符
          print('警告: NHK 新聞列表 JSON 結構與預期不符。URL: $_nhkNewsListUrl');
          print('接收到的 jsonData: $jsonData');
          throw Exception('無法解析 NHK 新聞列表 JSON 結構 (非預期格式)');
        }
      } else {
        throw Exception('無法獲取 NHK 新聞列表: ${response.statusCode}');
      }
    } catch (e) {
      print('ArticleService - fetchNhkArticles 錯誤: $e');
      rethrow; // 重新拋出錯誤，以便 UI 層可以處理
    }
  }
}
