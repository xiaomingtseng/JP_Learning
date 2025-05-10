import 'package:flutter/material.dart';
import 'package:ruby_text/ruby_text.dart';
import '../models/news_article.dart';
import '../services/web_content_service.dart';
import '../utils/text_parser.dart'; // 假設您有此檔案來解析 RubyTextData

class NewsDetailScreen extends StatefulWidget {
  final NewsArticle newsArticle;

  const NewsDetailScreen({super.key, required this.newsArticle});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  final WebContentService _contentService = WebContentService();
  String? _scrapedContent;
  bool _isLoadingContent = true;
  String? _contentError;

  @override
  void initState() {
    super.initState();
    _fetchArticleDetailContent();
  }

  Future<void> _fetchArticleDetailContent() async {
    if (widget.newsArticle.newsWebUrl.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoadingContent = false;
          _contentError = '沒有提供新聞網頁連結。';
        });
      }
      return;
    }

    try {
      final content = await _contentService.fetchArticleContent(
        widget.newsArticle.newsWebUrl,
      );
      if (mounted) {
        setState(() {
          _scrapedContent = content;
          _isLoadingContent = false;
          _contentError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _contentError = e.toString();
          _isLoadingContent = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<RubyTextData> titleData = parseRubyTextToData(
      widget.newsArticle.title,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.newsArticle.title.replaceAll(RegExp(r'<[^>]*>'), ''),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (widget.newsArticle.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  widget.newsArticle.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
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
                        size: 100,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            if (widget.newsArticle.imageUrl.isNotEmpty)
              const SizedBox(height: 16.0),

            if (titleData.isNotEmpty)
              RubyText(
                titleData,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                rubyStyle: TextStyle(
                  fontSize:
                      Theme.of(context).textTheme.bodySmall?.fontSize ?? 10.0,
                  color:
                      Theme.of(context).textTheme.bodySmall?.color ??
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
              )
            else
              Text(
                widget.newsArticle.title.replaceAll(RegExp(r'<[^>]*>'), ''),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 8.0),

            // 顯示來自 JSON 的摘要
            Text(
              "摘要: ${widget.newsArticle.summary}",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16.0),
            const Divider(),
            const SizedBox(height: 8.0),
            Text(
              "詳細內容:",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),

            if (_isLoadingContent)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_contentError != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '無法載入詳細內容: $_contentError',
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else if (_scrapedContent != null && _scrapedContent!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _scrapedContent!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.5), // 增加行高以提高可讀性
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('沒有找到詳細內容或內容為空。'),
              ),
          ],
        ),
      ),
    );
  }
}
