import 'package:flutter/material.dart';
import 'package:ruby_text/ruby_text.dart'; // 匯入 ruby_text
import '../models/news_article.dart';
import '../screens/news_detail_screen.dart';
import '../utils/text_parser.dart'; // 匯入解析函數

class NewsCardWidget extends StatelessWidget {
  final NewsArticle news;

  const NewsCardWidget({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    List<RubyTextData> titleData = parseRubyTextToData(news.title);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(newsArticle: news),
          ),
        );
      },
      child: Card(
        elevation: 1.0,
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Stack(
          children: [
            if (news.imageUrl.isNotEmpty)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Image.network(
                    news.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (
                      BuildContext context,
                      Widget child,
                      ImageChunkEvent? loadingProgress,
                    ) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                        ),
                      );
                    },
                    errorBuilder: (
                      BuildContext context,
                      Object exception,
                      StackTrace? stackTrace,
                    ) {
                      return const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(4.0),
                    bottomRight: Radius.circular(4.0),
                  ),
                  color: Colors.black.withOpacity(0.6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (titleData.isNotEmpty)
                      RubyText(
                        titleData,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        rubyStyle: const TextStyle(
                          // 設定假名的樣式
                          fontSize: 10, // 假名字體大小
                          color: Colors.white70,
                        ),
                      )
                    else // 如果解析後 titleData 為空，顯示原始標題的純文字版本
                      Text(
                        news.title.replaceAll(RegExp(r'<[^>]*>'), ''),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
