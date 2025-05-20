import 'package:flutter/material.dart';
import '../models/learning_set.dart';
import '../services/kotoba_service.dart';
import '../models/kotoba.dart';

class LearningSetDetailScreen extends StatelessWidget {
  final LearningSet learningSet;

  const LearningSetDetailScreen({super.key, required this.learningSet});

  // 根據學習集 id 決定要讀取的 JSON 檔案路徑
  String _getAssetPath() {
    if (learningSet.id == 'jlpt_n5_vocab') {
      return 'assets/kotoba/n5.json';
    }
    if (learningSet.id == 'jlpt_n4_vocab') {
      return 'assets/kotoba/n4.json';
    }
    if (learningSet.id == 'jlpt_n3_vocab') {
      return 'assets/kotoba/n3.json';
    }
    if (learningSet.id == 'jlpt_n2_vocab') {
      return 'assets/kotoba/n2.json';
    }
    if (learningSet.id == 'jlpt_n1_vocab') {
      return 'assets/kotoba/n1.json';
    }
    return 'assets/kotoba/default.json';
  }

  @override
  Widget build(BuildContext context) {
    final kotobaService = KotobaService();

    return Scaffold(
      appBar: AppBar(
        title: Text(learningSet.title),
        backgroundColor: learningSet.color,
      ),
      body: FutureBuilder<List<Kotoba>>(
        future: kotobaService.fetchKotobaFromAssets(_getAssetPath()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('發生錯誤: ${snapshot.error}'));
          } else {
            final List<Kotoba> kotobaList = snapshot.data!;
            return Column(
              // 將 FutureBuilder 的內容包裝在 Column 中
              children: [
                Expanded(
                  // 使用 Expanded 包裹 ListView.builder
                  child: ListView.builder(
                    itemCount: kotobaList.length,
                    itemBuilder: (context, index) {
                      final kotoba = kotobaList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: ListTile(
                          title: Text(kotoba.word),
                          subtitle: Text('${kotoba.phonetic}\n${kotoba.mean}'),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  // 使用 Padding 元件增加按鈕區域的內邊距
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    // 將標題和按鈕垂直排列
                    children: [
                      const Text(
                        // 新增標題
                        '練習',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0), // 增加標題和按鈕之間的間距
                      Row(
                        // 使用 Row 元件排列按鈕
                        mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly, // 按鈕平均分配空間
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // TODO: 實現配對學習模式的邏輯
                            },
                            child: const Text('配對'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // TODO: 實現選擇學習模式的邏輯
                            },
                            child: const Text('選擇'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
