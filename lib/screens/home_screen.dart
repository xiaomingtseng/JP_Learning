import 'package:flutter/material.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/function_icons_row.dart';
import '../widgets/news_card_widget.dart';
import '../widgets/article_list_item_widget.dart';
import '../models/news_article.dart';
import '../models/content_article.dart';
import '../services/news_service.dart'; // 匯入 NewsService
import '../models/note_models.dart';
import '../services/note_service.dart';
import 'account_screen.dart';
import 'settings_screen.dart';
import 'translate_screen.dart';
import 'learning_screen.dart';
import 'dictionary_screen.dart';
import 'notebooks_screen.dart'; // 匯入 NotebooksScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchText = "";
  int _selectedIndex = 0;

  List<NewsArticle> _newsItems = []; // 初始化為空列表
  bool _isLoadingNews = true; // 新聞載入狀態
  String? _newsError; // 新聞載入錯誤訊息

  final NewsService _newsService = NewsService(); // 建立 NewsService 實例

  final NoteService _noteService = NoteService(); // 建立 NoteService 實例
  List<Group> _groups = [];
  bool _isLoading = true;
  String? _errorMessage;

  final List<ContentArticle> _contentArticles = List.generate(
    20,
    (index) => ContentArticle(
      title: '文章標題 ${index + 1}',
      author: '作者 ${index + 1}',
      snippet: '這是文章 ${index + 1} 的部分內容預覽，點擊可以查看更多詳情。這段文字會長一點，用來模擬真實的文章摘要。',
    ),
  );

  @override
  void initState() {
    super.initState();
    _fetchNewsData(); // 在 initState 中呼叫擷取新聞的方法
    _loadGroups(); // 在 initState 中呼叫載入群組的方法
  }

  Future<void> _fetchNewsData() async {
    // 只有在 widget 仍然 mounted 時才設定載入狀態
    if (mounted) {
      setState(() {
        _isLoadingNews = true;
        _newsError = null;
      });
    }
    try {
      final articles = await _newsService.fetchNewsArticles();
      // 檢查 widget 是否仍然 mounted
      if (mounted) {
        setState(() {
          _newsItems = articles;
          _isLoadingNews = false;
        });
      }
    } catch (e) {
      // 檢查 widget 是否仍然 mounted
      if (mounted) {
        setState(() {
          _newsError = e.toString();
          _isLoadingNews = false;
        });
      }
      print("HomeScreen - Error fetching news: $e");
    }
  }

  Future<void> _loadGroups() async {
    // 只有在 widget 仍然 mounted 時才設定初始載入狀態
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      final groups = await _noteService.getAllGroups();
      // 檢查 widget 是否仍然 mounted
      if (mounted) {
        setState(() {
          _groups = groups;
          _isLoading = false;
        });
      }
    } catch (e) {
      // 檢查 widget 是否仍然 mounted
      if (mounted) {
        setState(() {
          _errorMessage = '載入群組失敗: $e';
          _isLoading = false;
        });
      }
      print('載入群組時發生錯誤: $e');
    }
  }

  Future<void> _addGroup() async {
    final TextEditingController nameController = TextEditingController();
    final groupName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('新增群組'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(hintText: '群組名稱'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('新增'),
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop(nameController.text.trim());
                }
              },
            ),
          ],
        );
      },
    );

    if (groupName != null && groupName.isNotEmpty) {
      setState(() {
        _isLoading = true; // 顯示載入指示器
      });
      try {
        final newGroup = await _noteService.createGroup(groupName);
        if (newGroup != null) {
          await _loadGroups(); // 重新載入群組列表
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('新增群組失敗')));
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('新增群組時發生錯誤: $e')));
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleSearch(String searchText) {
    setState(() {
      _searchText = searchText;
      print("Search term: $searchText");
    });
  }

  void _onSettingsPressed() {
    print("Settings button pressed");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _onAccountPressed() {
    print("Account button pressed");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AccountScreen()),
    );
  }

  void _onNotebookPressed() {
    print("Notebook icon pressed");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(title: const Text('我的筆記群組')),
              body: _buildNotebookBody(),
              floatingActionButton: FloatingActionButton(
                onPressed: _addGroup,
                tooltip: '新增群組',
                child: const Icon(Icons.add),
              ),
            ),
      ),
    );
  }

  Widget _buildNotebookBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            ElevatedButton(onPressed: _loadGroups, child: const Text('重試')),
          ],
        ),
      );
    }
    if (_groups.isEmpty) {
      return const Center(
        child: Text('目前沒有群組。\n點擊右下角按鈕新增一個吧！', textAlign: TextAlign.center),
      );
    }
    return ListView.builder(
      itemCount: _groups.length,
      itemBuilder: (context, index) {
        final group = _groups[index];
        return ListTile(
          title: Text(group.name),
          leading: const Icon(Icons.folder_open_outlined), // 群組圖示
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // 導航到 NotebooksScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => NotebooksScreen(
                      groupId: group.id,
                      groupName: group.name,
                      noteService: _noteService, // 傳遞 NoteService 實例
                    ),
              ),
            ).then((_) {
              // 從 NotebooksScreen 返回後，可以選擇性地重新載入群組
              // 例如，如果 NotebooksScreen 中有刪除群組的功能
              // _loadGroups();
            });
          },
        );
      },
    );
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FunctionIconsRow(
            onNotebookPressed: _onNotebookPressed,
            onCameraPressed: _onCameraPressed,
            onMicPressed: _onMicPressed,
          ),
          const SizedBox(height: 20),
          const Text(
            '每日新聞',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildNewsSection(),
          const SizedBox(height: 20),
          const Text(
            '推薦文章',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildArticlesSection(),
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
      const TranslateScreen(),
      const LearningScreen(),
      const DictionaryScreen(),
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
        // selectedItemColor: Theme.of(context).primaryColor,
        // unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildNewsSection() {
    if (_isLoadingNews) {
      return const SizedBox(
        height: 180, // 與 PageView 高度一致
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_newsError != null) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '無法載入新聞:\n$_newsError',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    }

    if (_newsItems.isEmpty) {
      return const SizedBox(height: 180, child: Center(child: Text('目前沒有新聞')));
    }

    return SizedBox(
      height: 180, // 您可以根據 NewsCardWidget 的內容調整此高度
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: _newsItems.length,
        itemBuilder: (context, index) {
          final news = _newsItems[index];
          return NewsCardWidget(news: news);
        },
      ),
    );
  }

  Widget _buildArticlesSection() {
    if (_contentArticles.isEmpty) {
      return const Center(child: Text('目前沒有文章'));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _contentArticles.length,
      itemBuilder: (context, index) {
        final article = _contentArticles[index];
        return ArticleListItemWidget(
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
