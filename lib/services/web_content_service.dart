import 'dart:convert'; // 匯入 dart:convert 以使用 utf8
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

class WebContentService {
  Future<String> fetchArticleContent(String url) async {
    if (url.isEmpty) {
      throw Exception('新聞網址為空。');
    }
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // 明確使用 UTF-8 解碼 response.bodyBytes
        final responseBody = utf8.decode(response.bodyBytes);
        final document = html_parser.parse(responseBody);

        final articleBody = document.querySelector('div.content--detail-body');

        if (articleBody != null) {
          final paragraphs = articleBody.querySelectorAll('p');
          if (paragraphs.isNotEmpty) {
            return paragraphs
                .map((p) => p.text.trim())
                .where((text) => text.isNotEmpty)
                .join('\n\n');
          } else {
            return '詳細內容中未找到段落文字。';
          }
        } else {
          final alternativeBody = document.querySelector(
            'div.article-main__body',
          );
          if (alternativeBody != null) {
            final paragraphs = alternativeBody.querySelectorAll('p');
            if (paragraphs.isNotEmpty) {
              return paragraphs
                  .map((p) => p.text.trim())
                  .where((text) => text.isNotEmpty)
                  .join('\n\n');
            } else {
              return '詳細內容中未找到段落文字 (備用結構)。';
            }
          }
          return '無法找到主要新聞內容區域。請檢查網頁結構。';
        }
      } else {
        throw Exception('無法載入新聞頁面，狀態碼: ${response.statusCode}');
      }
    } catch (e) {
      print('抓取新聞內容時發生錯誤: $e');
      throw Exception('無法抓取新聞內容: $e');
    }
  }

  Future<String> fetchEasyArticleContentById(String newsId) async {
    if (newsId.isEmpty) {
      throw Exception('News ID 為空。');
    }

    // 根據 news_id 建構 NHK Easy 新聞的 URL
    // 例如 news_id: "ne2025050911353"
    // URL: "https://www3.nhk.or.jp/news/easy/ne2025050911353/ne2025050911353.html"
    final String easyArticleUrl =
        "https://www3.nhk.or.jp/news/easy/$newsId/$newsId.html";

    try {
      final response = await http.get(Uri.parse(easyArticleUrl));
      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final document = html_parser.parse(responseBody);

        // 新的 CSS 選擇器
        final articleBodyDiv = document.querySelector('div.article-body');

        if (articleBodyDiv != null) {
          final paragraphs = articleBodyDiv.querySelectorAll('p');
          if (paragraphs.isNotEmpty) {
            return paragraphs
                .map((p) => p.text.trim()) // .text 會取得純文字內容
                .where((text) => text.isNotEmpty) // 過濾掉空的段落
                .join('\n\n'); // 用兩個換行符分隔段落
          } else {
            return '在 class="article-body" 中未找到 <p> 標籤。';
          }
        } else {
          return '無法找到 class="article-body" 的 div 元素。請檢查網頁結構或 News ID。';
        }
      } else {
        throw Exception(
          '無法載入 NHK Easy 新聞頁面 (ID: $newsId)，狀態碼: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('抓取 NHK Easy 新聞內容 (ID: $newsId) 時發生錯誤: $e');
      throw Exception('無法抓取 NHK Easy 新聞內容: $e');
    }
  }
}
