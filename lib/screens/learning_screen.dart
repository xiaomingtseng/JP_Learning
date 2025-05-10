import 'package:flutter/material.dart';
import '../models/learning_set.dart';
import 'learning_set_detail_screen.dart';

// 模擬的學習集資料 (之後會從 API 或本地資料庫獲取)
final List<LearningSet> _allLearningSets = [
  // JLPT 單字集 (保留 category、title 與 color)
  LearningSet(
    id: 'jlpt_n1_vocab',
    title: 'JLPT N1 單字集',
    category: 'JLPT',
    color: Colors.blue,
  ),
  LearningSet(
    id: 'jlpt_n2_vocab',
    title: 'JLPT N2 單字集',
    category: 'JLPT',
    color: Colors.green,
  ),
  LearningSet(
    id: 'jlpt_n3_vocab',
    title: 'JLPT N3 單字集',
    category: 'JLPT',
    color: Colors.orange,
  ),
  LearningSet(
    id: 'jlpt_n4_vocab',
    title: 'JLPT N4 單字集',
    category: 'JLPT',
    color: Colors.red,
  ),
  LearningSet(
    id: 'jlpt_n5_vocab',
    title: 'JLPT N5 單字集',
    category: 'JLPT',
    color: Colors.purple,
  ),
  // 其他分類保持不變
  LearningSet(
    id: 'minna_1_vocab',
    title: '大家的日本語 第1課 單字',
    description: '學習《大家的日本語》第一課的生詞。',
    author: '教材同步',
    itemCount: 30,
    category: '教科書',
    color: Colors.cyan,
  ),
  LearningSet(
    id: 'travel_phrases',
    title: '日本旅遊常用短句',
    description: '包含問路、點餐、購物等實用短句。',
    author: '旅行達人',
    itemCount: 50,
    category: '生活',
    color: Colors.deepOrange,
  ),
  LearningSet(
    id: 'user_set_food',
    title: '我最愛的日本食物 (使用者分享)',
    description: '使用者A分享的關於日本美食的單字集。',
    author: '使用者A',
    itemCount: 25,
    category: '使用者分享',
    color: Colors.grey,
  ),
];

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

  @override
  void initState() {
    super.initState();
    _performGroupingAndFiltering();
    _searchController.addListener(_performGroupingAndFiltering);
  }

  void _performGroupingAndFiltering() {
    final query = _searchController.text.toLowerCase();
    List<LearningSet> setsToProcess;

    if (query.isEmpty) {
      setsToProcess = _allLearningSets;
    } else {
      setsToProcess =
          _allLearningSets.where((set) {
            return set.title.toLowerCase().contains(query) ||
                set.description.toLowerCase().contains(query) ||
                set.category.toLowerCase().contains(query) ||
                set.author.toLowerCase().contains(query);
          }).toList();
    }

    final Map<String, List<LearningSet>> tempGrouped = {};
    for (var set in setsToProcess) {
      (tempGrouped[set.category] ??= []).add(set);
    }

    // 確保分類順序一致 (可選)
    final sortedKeys =
        tempGrouped.keys.toList()..sort((a, b) {
          // 您可以定義自己的排序邏輯，例如將 "JLPT" 放在前面
          if (a == 'JLPT') return -1;
          if (b == 'JLPT') return 1;
          return a.compareTo(b);
        });

    final Map<String, List<LearningSet>> finalGrouped = {
      for (var key in sortedKeys) key: tempGrouped[key]!,
    };

    setState(() {
      _groupedAndFilteredSets = finalGrouped;
    });
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
    // 計算 GridView 高度，假設每個卡片高度約 150-180，顯示兩行
    // (卡片高度 + 垂直間距) * 行數 + 上下 padding
    // 例如：(160 + 10) * 2 = 340.  您可以根據 LearningSetGridItem 的實際渲染高度調整。
    // 這裡的 childAspectRatio 也會影響卡片寬度，進而影響一行能放多少卡片。
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
                _groupedAndFilteredSets.isEmpty
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
                          return const SizedBox.shrink(); // 如果某分類下沒有內容則不顯示
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
                              height:
                                  horizontalGridViewHeight, // 給 GridView 一個固定的高度
                              child: GridView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                itemCount: setsInCategory.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          crossAxisCount, // 垂直方向顯示的行數
                                      mainAxisSpacing: 10.0, // 主軸 (水平) 間距
                                      crossAxisSpacing:
                                          gridViewVerticalSpacing, // 交叉軸 (垂直) 間距
                                      childAspectRatio:
                                          0.85, // 寬高比 (寬度/高度)，調整此值以獲得合適的卡片形狀
                                      // 例如，如果卡片高 160，寬度會是 160 * 0.85 = 136
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
                            if (index <
                                _groupedAndFilteredSets.keys.length -
                                    1) // 最後一個分類後不加分隔線
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
