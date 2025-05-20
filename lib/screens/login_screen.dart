import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // 確保每次登入都能選擇帳戶
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Google 登入已取消')));
        }
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final User? firebaseUser = userCredential.user; // 獲取 Firebase User 物件

      if (firebaseUser != null) {
        // 更新 Firestore 中的登入資料，傳遞 firebaseUser
        await _updateLoginData(firebaseUser);
      }

      // 在此處加入 print 陳述式以進行偵錯
      print('嘗試顯示成功 SnackBar。context.mounted: ${context.mounted}');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Google 登入成功: ${firebaseUser?.email ?? firebaseUser?.uid ?? 'N/A'}',
            ),
          ),
        );
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Google 登入失敗: ${e.toString()}')));
      }
    }
  }

  Future<void> _updateLoginData(User firebaseUser) async {
    // 接收 Firebase User 物件
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    // 使用 firebaseUser.email 作為文件 ID，以利 Account Screen 查找
    // 注意：Google 登入通常會提供 email，此處假設 firebaseUser.email 不為 null
    if (firebaseUser.email == null) {
      print('錯誤：使用者 email 為 null，無法更新 Firestore 文件 ID。');
      // 考慮拋出錯誤或採取其他處理方式
      return;
    }
    final DocumentReference userDoc = firestore
        .collection('users')
        .doc(firebaseUser.email!); // 使用 email 作為 ID

    final DateTime today = DateTime.now();
    final String todayString = today.toIso8601String().split('T').first;

    // 準備要儲存/更新的使用者個人資料
    Map<String, dynamic> userProfileData = {
      'uid': firebaseUser.uid, // 在文件中也儲存 uid 欄位，方便查詢
      'email': firebaseUser.email,
      'displayName': firebaseUser.displayName,
      'photoURL': firebaseUser.photoURL,
    };

    try {
      final DocumentSnapshot docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        // 文件已存在，更新資料
        final data = docSnapshot.data() as Map<String, dynamic>;
        final String? lastLoginDate = data['lastLoginDate'];
        int consecutiveLoginDays = data['consecutiveLoginDays'] ?? 0;

        Map<String, dynamic> updateData = {
          ...userProfileData, // 每次登入都更新個人資料
          'lastLoginDate': todayString,
          'lastModified': FieldValue.serverTimestamp(), // 記錄最後修改時間
        };

        if (lastLoginDate != null) {
          final DateTime lastLogin = DateTime.parse(lastLoginDate);
          final int differenceInDays = today.difference(lastLogin).inDays;

          if (differenceInDays == 1) {
            // 連續登入
            updateData['consecutiveLoginDays'] = consecutiveLoginDays + 1;
          } else if (differenceInDays > 1) {
            // 連續登入中斷
            updateData['consecutiveLoginDays'] = 1;
          } else if (differenceInDays == 0) {
            // 當天重複登入，保持之前的連續登入天數
            // 如果 consecutiveLoginDays 因故為 0，則設為 1
            updateData['consecutiveLoginDays'] =
                consecutiveLoginDays > 0 ? consecutiveLoginDays : 1;
          } else {
            // 此情況不應發生 (上次登入日期在未來)，預設為 1
            updateData['consecutiveLoginDays'] = 1;
          }
        } else {
          // 文件存在但沒有 lastLoginDate，視為首次記錄登入天數
          updateData['consecutiveLoginDays'] = 1;
        }
        await userDoc.update(updateData);
      } else {
        // 文件不存在，創建新文件
        await userDoc.set({
          ...userProfileData,
          'lastLoginDate': todayString,
          'consecutiveLoginDays': 1,
          'createdAt': FieldValue.serverTimestamp(), // 記錄使用者創建時間
        });
      }
    } catch (e) {
      print('更新登入資料失敗: $e');
      // 您可以在此處選擇重新拋出錯誤或進行其他錯誤處理
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登入')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '歡迎來到 JP Learning!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: Image.asset(
                'assets/images/google.png',
                width: 24,
                height: 24,
              ),
              label: const Text('使用 Google 登入'),
              onPressed: () {
                _signInWithGoogle(context); // 直接呼叫登入方法
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            // 您可以在此處加入其他登入方式的按鈕
          ],
        ),
      ),
    );
  }
}
