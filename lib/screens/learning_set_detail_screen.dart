import 'package:flutter/material.dart';
import '../models/learning_set.dart';
import '../services/kotoba_service.dart';

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
            return ListView.builder(
              itemCount: kotobaList.length,
              itemBuilder: (context, index) {
                final kotoba = kotobaList[index];
                return ListTile(
                  title: Text(kotoba.word),
                  subtitle: Text('${kotoba.phonetic}\n${kotoba.mean}'),
                  isThreeLine: true,
                );
              },
            );
          }
        },
      ),
    );
  }
}
