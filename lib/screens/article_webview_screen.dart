// filepath: lib/screens/article_webview_screen.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleWebViewScreen extends StatefulWidget {
  final String url;
  final String? title; // 文章標題，用於 AppBar

  const ArticleWebViewScreen({super.key, required this.url, this.title});

  @override
  State<ArticleWebViewScreen> createState() => _ArticleWebViewScreenState();
}

class _ArticleWebViewScreenState extends State<ArticleWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoadingPage = true; // 用於顯示載入指示器
  String? _loadingError; // 用於顯示載入錯誤

  @override
  void initState() {
    super.initState();

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted) // 允許 JavaScript
          ..setBackgroundColor(const Color(0x00000000)) // 背景透明
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                // 您可以在這裡更新載入進度條，如果需要的話
                print('WebView is loading (progress : $progress%)');
              },
              onPageStarted: (String url) {
                if (mounted) {
                  setState(() {
                    _isLoadingPage = true;
                    _loadingError = null;
                  });
                }
                print('Page started loading: $url');
              },
              onPageFinished: (String url) {
                if (mounted) {
                  setState(() {
                    _isLoadingPage = false;
                  });
                }
                print('Page finished loading: $url');
              },
              onWebResourceError: (WebResourceError error) {
                // 處理載入錯誤
                if (mounted) {
                  setState(() {
                    _isLoadingPage = false;
                    _loadingError = '''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
                ''';
                  });
                }
                print('WebResourceError: ${error.description}');
              },
              onNavigationRequest: (NavigationRequest request) {
                // 您可以在這裡決定是否允許導航到特定 URL
                // 例如，阻止打開外部應用程式的連結，除非您明確希望這樣做
                // if (request.url.startsWith('https://www.youtube.com/')) {
                //   print('Blocking navigation to ${request.url}');
                //   return NavigationDecision.prevent;
                // }
                print('Allowing navigation to ${request.url}');
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.url)); // 載入傳入的 URL
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? '文章'), // 如果沒有提供標題，則顯示 '文章'
        actions: [
          // 可以加入刷新按鈕
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _controller.reload();
            },
            tooltip: '重新整理',
          ),
          // 可以加入更多操作，例如分享、複製連結等
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoadingPage) const Center(child: CircularProgressIndicator()),
          if (_loadingError != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '無法載入頁面',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _loadingError!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('重試'),
                      onPressed: () async {
                        await _controller.reload();
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
