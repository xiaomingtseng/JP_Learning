import 'package:flutter/material.dart';

// 假設的使用者資料模型
class UserProfile {
  final String name;
  final String email;
  final String avatarUrl;
  final int likedArticlesCount;
  final int likedNewsCount;
  final int learnedWordsCount;
  final int learnedKanjiCount;
  final int consecutiveLoginDays; // 新增：連續上線天數

  UserProfile({
    required this.name,
    required this.email,
    this.avatarUrl = 'https://via.placeholder.com/150',
    this.likedArticlesCount = 0,
    this.likedNewsCount = 0,
    this.learnedWordsCount = 0,
    this.learnedKanjiCount = 0,
    this.consecutiveLoginDays = 0, // 新增
  });

  // 輔助方法，用於創建帶有更新值的新 UserProfile 實例 (保持不可變性)
  UserProfile copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    int? likedArticlesCount,
    int? likedNewsCount,
    int? learnedWordsCount,
    int? learnedKanjiCount,
    int? consecutiveLoginDays,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      likedArticlesCount: likedArticlesCount ?? this.likedArticlesCount,
      likedNewsCount: likedNewsCount ?? this.likedNewsCount,
      learnedWordsCount: learnedWordsCount ?? this.learnedWordsCount,
      learnedKanjiCount: learnedKanjiCount ?? this.learnedKanjiCount,
      consecutiveLoginDays: consecutiveLoginDays ?? this.consecutiveLoginDays,
    );
  }
}

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // 將使用者資料移至 State 中，使其可變
  late UserProfile _userProfile;

  @override
  void initState() {
    super.initState();
    // 模擬的使用者資料 (實際應用中會從登入狀態或 API 獲取)
    _userProfile = UserProfile(
      name: '山田 太郎',
      email: 'yamada.taro@example.com',
      likedArticlesCount: 15,
      likedNewsCount: 5,
      learnedWordsCount: 120,
      learnedKanjiCount: 85,
      consecutiveLoginDays: 7, // 新增範例資料
    );
  }

  Widget _buildStatisticCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 30.0, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8.0),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  // 顯示編輯對話框的輔助方法
  Future<void> _showEditDialog(
    BuildContext context,
    String title,
    String initialValue,
    Function(String) onSave,
  ) async {
    final TextEditingController controller = TextEditingController(
      text: initialValue,
    );
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('修改$title'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: '請輸入新的$title'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('儲存'),
              onPressed: () {
                onSave(controller.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('使用者帳戶')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // 使用者資訊區塊
          Center(
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 50.0,
                  backgroundImage: NetworkImage(_userProfile.avatarUrl),
                  onBackgroundImageError: (_, __) {},
                  child:
                      _userProfile.avatarUrl.isEmpty
                          ? const Icon(Icons.person, size: 50)
                          : null,
                ),
                const SizedBox(height: 16.0),
                InkWell(
                  // 使名稱可點擊
                  onTap: () {
                    _showEditDialog(context, '名稱', _userProfile.name, (
                      newValue,
                    ) {
                      setState(() {
                        _userProfile = _userProfile.copyWith(name: newValue);
                      });
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _userProfile.name,
                          style: const TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.edit, size: 18, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4.0),
                InkWell(
                  // 使電子郵件可點擊
                  onTap: () {
                    _showEditDialog(context, '電子郵件', _userProfile.email, (
                      newValue,
                    ) {
                      setState(() {
                        _userProfile = _userProfile.copyWith(email: newValue);
                      });
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _userProfile.email,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.edit, size: 16, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24.0),
          const Divider(),
          const SizedBox(height: 16.0),
          Text(
            '學習紀錄',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          const SizedBox(height: 16.0),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 1.2, // 調整卡片的寬高比，如果內容變多可能需要調整
            children: <Widget>[
              _buildStatisticCard(
                context,
                Icons.calendar_today_outlined, // 連續上線圖示
                '連續上線天數',
                _userProfile.consecutiveLoginDays.toString(),
              ),
              _buildStatisticCard(
                context,
                Icons.article_outlined,
                '文章按讚',
                _userProfile.likedArticlesCount.toString(),
              ),
              _buildStatisticCard(
                context,
                Icons.newspaper_outlined,
                '新聞按讚',
                _userProfile.likedNewsCount.toString(),
              ),
              _buildStatisticCard(
                context,
                Icons.translate_outlined,
                '學習單字數',
                _userProfile.learnedWordsCount.toString(),
              ),
              _buildStatisticCard(
                context,
                Icons.font_download_outlined,
                '學習漢字數',
                _userProfile.learnedKanjiCount.toString(),
              ),
              // 可以再增加一個空的 Card 來填滿 GridView，如果項目是奇數個
            ],
          ),
          const SizedBox(height: 24.0),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('登出'),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('登出按鈕已按下')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
