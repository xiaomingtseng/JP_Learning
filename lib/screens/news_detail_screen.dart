import 'package:flutter/material.dart';
import 'package:ruby_text/ruby_text.dart';
import 'package:audioplayers/audioplayers.dart'; // 匯入 audioplayers
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

  final AudioPlayer _audioPlayer = AudioPlayer(); // 建立 AudioPlayer 實例
  PlayerState? _playerState;
  bool _isAudioLoading = false;
  String? _audioError;
  String _fullAudioUrl = "";

  @override
  void initState() {
    super.initState();
    _fetchArticleDetailContent();
    _prepareAudioUrl(); // 準備音訊 URL
    _audioPlayer.onPlayerStateChanged.listen((PlayerState s) {
      if (mounted) {
        setState(() => _playerState = s);
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.release(); // 釋放 AudioPlayer 資源
    _audioPlayer.dispose();
    super.dispose();
  }

  void _prepareAudioUrl() {
    String voiceUriFromJson = widget.newsArticle.newsEasyVoiceUri;
    if (voiceUriFromJson.isNotEmpty) {
      String fileNamePart =
          voiceUriFromJson.endsWith('.m4a')
              ? voiceUriFromJson.substring(
                0,
                voiceUriFromJson.length - '.m4a'.length,
              )
              : voiceUriFromJson;

      if (fileNamePart.isNotEmpty) {
        _fullAudioUrl =
            "https://vod-stream.nhk.jp/news/easy_audio/$fileNamePart/index.m3u8";
      }
    }
  }

  Future<void> _playAudio() async {
    if (_fullAudioUrl.isEmpty) {
      if (mounted) {
        setState(() {
          _audioError = "沒有提供有效的音訊連結。";
          _isAudioLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isAudioLoading = true;
        _audioError = null;
      });
    }

    try {
      await _audioPlayer.play(UrlSource(_fullAudioUrl));
      if (mounted) {
        setState(() {
          _isAudioLoading = false;
        });
      }
    } catch (e) {
      print("播放音訊錯誤: $e");
      if (mounted) {
        setState(() {
          _audioError = "無法播放音訊: $e";
          _isAudioLoading = false;
        });
      }
    }
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
  }

  Future<void> _fetchArticleDetailContent() async {
    if (widget.newsArticle.newsId.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoadingContent = false;
          _contentError = '沒有提供新聞 ID。';
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingContent = true;
        _contentError = null;
      });
    }

    try {
      final content = await _contentService.fetchEasyArticleContentById(
        widget.newsArticle.newsId,
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

    bool canPlayAudio = _fullAudioUrl.isNotEmpty;
    bool isPlaying = _playerState == PlayerState.playing;
    bool isPaused = _playerState == PlayerState.paused;

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

            Text(
              "摘要: ${widget.newsArticle.summary}",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16.0),
            const Divider(),

            // 音訊播放控制
            const SizedBox(height: 8.0),
            Text(
              "新聞音訊:",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            if (canPlayAudio)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      size: 36.0,
                    ),
                    onPressed:
                        _isAudioLoading
                            ? null
                            : (isPlaying ? _pauseAudio : _playAudio),
                    tooltip: isPlaying ? "暫停" : "播放",
                  ),
                  if (isPlaying || isPaused) // 只有在播放或暫停時才顯示停止按鈕
                    IconButton(
                      icon: const Icon(Icons.stop_circle_outlined, size: 36.0),
                      onPressed: _isAudioLoading ? null : _stopAudio,
                      tooltip: "停止",
                    ),
                  if (_isAudioLoading)
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ),
                ],
              )
            else
              const Text("此新聞沒有提供音訊。"),
            if (_audioError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "音訊錯誤: $_audioError",
                  style: const TextStyle(color: Colors.red),
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
