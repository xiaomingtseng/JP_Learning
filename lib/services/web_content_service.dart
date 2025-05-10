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
}
