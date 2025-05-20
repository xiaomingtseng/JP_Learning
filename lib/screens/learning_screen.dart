import 'package:flutter/material.dart';
import '../models/learning_set.dart';
import 'learning_set_detail_screen.dart';
import '../services/learning_set_service.dart'; // 導入 LearningSetService

class LearningSetGridItem extends StatelessWidget {
  final LearningSet learningSet;
  final VoidCallback onTap;

  const LearningSetGridItem({
    super.key,
    required this.learningSet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // 使內部元件水平延展
          children: <Widget>[
            // 使用色彩取代圖片
            Expanded(
              flex: 3,
              child: Container(
                color: learningSet.color,
                child: const Center(
                  child: Icon(
                    Icons.school_outlined,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // 文字區段
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    learningSet.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.0,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${learningSet.itemCount} 項',
                    style: TextStyle(fontSize: 11.0, color: Colors.grey[700]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  Map<String, List<LearningSet>> _groupedAndFilteredSets = {};
  final TextEditingController _searchController = TextEditingController();
  final LearningSetService _learningSetService =
      LearningSetService(); // 實例化 Service
  List<LearningSet> _masterLearningSets = []; // 用於存儲從 Service 獲取的原始數據
  bool _isLoading = true; // 加載狀態

  @override
  void initState() {
    super.initState();
    _loadLearningSets(); // 修改 initState 以調用新的加載方法
    _searchController.addListener(_performGroupingAndFiltering);
  }

  Future<void> _loadLearningSets() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _masterLearningSets = await _learningSetService.fetchAllLearningSets();
      _performGroupingAndFiltering(); // 獲取數據後立即進行分組和過濾
    } catch (e) {
      // 處理錯誤，例如顯示一個錯誤訊息
      print('Error loading learning sets: $e');
      if (mounted) {
        // Check if the widget is still in the tree
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('無法載入學習集: $e')));
      }
    }
    if (mounted) {
      // Check if the widget is still in the tree
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _performGroupingAndFiltering() {
    final query = _searchController.text.toLowerCase();
    List<LearningSet> setsToProcess;

    // 使用 _masterLearningSets 進行過濾
    if (query.isEmpty) {
      setsToProcess = _masterLearningSets;
    } else {
      setsToProcess =
          _masterLearningSets.where((set) {
            // 保留原有的過濾邏輯，但可以根據 LearningSet 的實際欄位調整
            final titleMatch = set.title.toLowerCase().contains(query);
            final categoryMatch = set.category.toLowerCase().contains(query);
            // description 和 author 可能為 null，需要檢查
            final descriptionMatch =
                set.description?.toLowerCase().contains(query) ?? false;
            final authorMatch =
                set.author?.toLowerCase().contains(query) ?? false;
            return titleMatch ||
                categoryMatch ||
                descriptionMatch ||
                authorMatch;
          }).toList();
    }

    final Map<String, List<LearningSet>> tempGrouped = {};
    for (var set in setsToProcess) {
      (tempGrouped[set.category] ??= []).add(set);
    }

    final sortedKeys =
        tempGrouped.keys.toList()..sort((a, b) {
          if (a == 'JLPT') return -1;
          if (b == 'JLPT') return 1;
          return a.compareTo(b);
        });

    final Map<String, List<LearningSet>> finalGrouped = {
      for (var key in sortedKeys) key: tempGrouped[key]!,
    };
    if (mounted) {
      // Check if the widget is still in the tree
      setState(() {
        _groupedAndFilteredSets = finalGrouped;
      });
    }
  }

  void _navigateToLearningSetDetail(LearningSet set) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LearningSetDetailScreen(learningSet: set),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_performGroupingAndFiltering);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double gridItemHeight = 160.0; // 預期卡片高度
    const int crossAxisCount = 2; // 垂直方向顯示的行數
    const double gridViewVerticalSpacing = 10.0;
    const double horizontalGridViewHeight =
        (gridItemHeight * crossAxisCount) +
        (gridViewVerticalSpacing * (crossAxisCount - 1));

    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜尋學習集 (例如: N5, 旅遊)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 20,
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchController.clear(),
                        )
                        : null,
              ),
            ),
          ),
          Expanded(
            child:
                _isLoading // 根據加載狀態顯示 UI
                    ? const Center(
                      child: CircularProgressIndicator(),
                    ) // 顯示加載指示器
                    : _groupedAndFilteredSets.isEmpty
                    ? Center(
                      child: Text(
                        _searchController.text.isEmpty
                            ? '沒有可用的學習集'
                            : '找不到符合 "${_searchController.text}" 的學習集',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                    : ListView.builder(
                      itemCount: _groupedAndFilteredSets.keys.length,
                      itemBuilder: (context, index) {
                        String category = _groupedAndFilteredSets.keys
                            .elementAt(index);
                        List<LearningSet> setsInCategory =
                            _groupedAndFilteredSets[category]!;

                        if (setsInCategory.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16.0,
                                top: 16.0,
                                bottom: 8.0,
                                right: 16.0,
                              ),
                              child: Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: horizontalGridViewHeight,
                              child: GridView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                itemCount: setsInCategory.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      mainAxisSpacing: 10.0,
                                      crossAxisSpacing: gridViewVerticalSpacing,
                                      childAspectRatio: 0.85,
                                    ),
                                itemBuilder: (context, itemIndex) {
                                  final set = setsInCategory[itemIndex];
                                  return LearningSetGridItem(
                                    learningSet: set,
                                    onTap:
                                        () => _navigateToLearningSetDetail(set),
                                  );
                                },
                              ),
                            ),
                            if (index < _groupedAndFilteredSets.keys.length - 1)
                              const Divider(
                                indent: 16,
                                endIndent: 16,
                                height: 20,
                              ),
                          ],
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
