import 'package:flutter/material.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/function_icons_row.dart';
import '../widgets/news_card_widget.dart';
import '../widgets/article_list_item_widget.dart';
import '../models/news_article.dart';
import '../models/content_article.dart';
import 'account_screen.dart'; // 匯入 AccountScreen
import 'settings_screen.dart'; // 匯入 SettingsScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchText = "";
  int _selectedIndex = 0;

  final List<NewsArticle> _newsItems = [
    NewsArticle(
      title: '新聞標題 1',
      summary: '這是第一條重要新聞的簡短摘要...',
      imageUrl: 'https://via.placeholder.com/350x150?text=News+1',
    ),
    NewsArticle(
      title: '新聞標題 2',
      summary: '這是第二條新聞的內容概要，非常吸引人。',
      imageUrl: 'https://via.placeholder.com/350x150?text=News+2',
    ),
    NewsArticle(
      title: '新聞標題 3',
      summary: '第三條新聞報導了最新的科技發展。',
      imageUrl: 'https://via.placeholder.com/350x150?text=News+3',
    ),
  ];

  final List<ContentArticle> _contentArticles = List.generate(
    20,
    (index) => ContentArticle(
      title: '文章標題 ${index + 1}',
      author: '作者 ${index + 1}',
      snippet: '這是文章 ${index + 1} 的部分內容預覽，點擊可以查看更多詳情。這段文字會長一點，用來模擬真實的文章摘要。',
    ),
  );

  void _handleSearch(String searchText) {
    setState(() {
      _searchText = searchText;
      print("Search term: $searchText");
    });
  }

  void _onSettingsPressed() {
    print("Settings button pressed");
    // 導航到 SettingsScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _onAccountPressed() {
    print("Account button pressed");
    // 導航到 AccountScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AccountScreen()),
    );
  }

  void _onNotebookPressed() {
    print("Notebook icon pressed");
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('筆記本功能')));
  }

  void _onCameraPressed() {
    print("Camera icon pressed");
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('拍照功能')));
  }

  void _onMicPressed() {
    print("Mic icon pressed");
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('錄音功能')));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHomePageContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FunctionIconsRow(
            // 使用新的 Widget
            onNotebookPressed: _onNotebookPressed,
            onCameraPressed: _onCameraPressed,
            onMicPressed: _onMicPressed,
          ),
          const SizedBox(height: 20),
          _buildNewsSection(),
          const SizedBox(height: 20),
          const Text(
            '推薦文章',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(child: _buildArticlesSection()),
          if (_searchText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Center(child: Text('正在搜尋: $_searchText')),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderPage(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      _buildHomePageContent(),
      _buildPlaceholderPage('翻譯頁面'),
      _buildPlaceholderPage('學習頁面'),
      _buildPlaceholderPage('字典頁面'),
    ];

    PreferredSizeWidget? currentAppBar;
    if (_selectedIndex == 0) {
      currentAppBar = AppBar(
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: _onSettingsPressed,
          tooltip: '設定',
        ),
        title: SearchBarWidget(onSearchChanged: _handleSearch),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: _onAccountPressed,
            tooltip: '使用者帳戶',
          ),
        ],
      );
    }

    return Scaffold(
      appBar: currentAppBar,
      body: IndexedStack(index: _selectedIndex, children: widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '首頁',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.translate_outlined),
            activeIcon: Icon(Icons.translate),
            label: '翻譯',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: '學習',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: '字典',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // _buildFunctionIcon 方法已移至 FunctionIconsRow Widget

  Widget _buildNewsSection() {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: _newsItems.length,
        itemBuilder: (context, index) {
          final news = _newsItems[index];
          return NewsCardWidget(news: news); // 使用新的 Widget
        },
      ),
    );
  }

  Widget _buildArticlesSection() {
    if (_contentArticles.isEmpty) {
      return const Center(child: Text('目前沒有文章'));
    }
    return ListView.builder(
      itemCount: _contentArticles.length,
      itemBuilder: (context, index) {
        final article = _contentArticles[index];
        return ArticleListItemWidget(
          // 使用新的 Widget
          article: article,
          onTap: () {
            print('Tapped on article: ${article.title}');
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('點擊了: ${article.title}')));
          },
        );
      },
    );
  }
}
