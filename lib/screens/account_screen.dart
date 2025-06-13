import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 匯入 Firebase Auth
import '../services/user_service.dart';

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
  late UserProfile _userProfile;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _userProfile = UserProfile(
      name: '使用者名稱',
      email: 'user@example.com',
      avatarUrl: 'https://via.placeholder.com/150',
      likedArticlesCount: 0,
      likedNewsCount: 0,
      learnedWordsCount: 0,
      learnedKanjiCount: 0,
      consecutiveLoginDays: 0,
    ); // 預設值
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _initializeUserProfile(currentUser);
    }
  }

  Future<void> _initializeUserProfile(User currentUser) async {
    try {
      final userId = currentUser.email ?? currentUser.uid;
      final userExists = await _userService.checkUserExists(userId);

      if (!userExists) {
        // 創建使用者資料
        await _userService.createUserProfile(
          userId: userId,
          name: currentUser.displayName ?? '使用者名稱',
          email: currentUser.email ?? 'user@example.com',
          avatarUrl: currentUser.photoURL ?? 'https://via.placeholder.com/150',
        );
      }

      // 讀取使用者資料
      final userData = await _userService.getUserProfile(userId);
      if (userData != null) {
        setState(() {
          _userProfile = UserProfile(
            name: userData['name'] ?? '使用者名稱',
            email: userData['email'] ?? 'user@example.com',
            avatarUrl:
                userData['avatarUrl'] ?? 'https://via.placeholder.com/150',
            likedArticlesCount: userData['likedArticlesCount'] ?? 0,
            likedNewsCount: userData['likedNewsCount'] ?? 0,
            learnedWordsCount: userData['learnedWordsCount'] ?? 0,
            learnedKanjiCount: userData['learnedKanjiCount'] ?? 0,
            consecutiveLoginDays: userData['consecutiveLoginDays'] ?? 0,
          );
        });
      }
    } catch (e) {
      print('初始化使用者資料失敗: $e');
    }
  }

  Future<void> _saveProfile() async {
    try {
      await _userService.updateUserProfile(
        userId: _userProfile.email, // or use another unique identifier
        updatedData: {
          'name': _userProfile.name,
          'likedArticlesCount': _userProfile.likedArticlesCount,
          'likedNewsCount': _userProfile.likedNewsCount,
          'learnedWordsCount': _userProfile.learnedWordsCount,
          'learnedKanjiCount': _userProfile.learnedKanjiCount,
          'consecutiveLoginDays': _userProfile.consecutiveLoginDays,
        },
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('個人資料已更新')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('更新失敗: $e')));
    }
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
        padding: const EdgeInsets.all(12.0), // 修改這裡的 padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 30.0),
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

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已成功登出')));
      }
    } catch (e) {
      print('Error signing out: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('登出失敗: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('使用者帳戶')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // 使用者資訊區塊
              Center(
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 50.0,
                      backgroundImage: NetworkImage(_userProfile.avatarUrl),
                      onBackgroundImageError: (_, __) {}, // 處理圖片載入錯誤
                      child:
                          _userProfile.avatarUrl.isEmpty ||
                                  _userProfile.avatarUrl ==
                                      'https://via.placeholder.com/150' // 檢查是否為預設圖片
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
                            _userProfile = _userProfile.copyWith(
                              name: newValue,
                            );
                          });
                          _saveProfile();
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
                    // 修改 Email 顯示部分，使其不可編輯
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        _userProfile.email, // 直接顯示 Email
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[700], // 可以調整顏色以示區別
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
              // 移除 Expanded 並直接使用 GridView
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 1.2, // 調整卡片的寬高比
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
                ],
              ),
              const SizedBox(height: 24.0),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('登出'),
                onPressed: _signOut, // 直接呼叫 _signOut 方法
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
