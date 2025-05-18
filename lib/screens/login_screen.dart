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

      final String? userId =
          userCredential.user?.email ?? userCredential.user?.uid;

      if (userId != null) {
        // 更新 Firestore 中的登入資料
        await _updateLoginData(userId);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google 登入成功: ${userId ?? 'N/A'}')),
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

  Future<void> _updateLoginData(String userId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference userDoc = firestore.collection('users').doc(userId);

    final DateTime today = DateTime.now();
    final String todayString =
        today.toIso8601String().split('T').first; // 只取日期部分

    try {
      final DocumentSnapshot docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final String? lastLoginDate = data['lastLoginDate'];
        final int consecutiveLoginDays = data['consecutiveLoginDays'] ?? 0;

        if (lastLoginDate != null) {
          final DateTime lastLogin = DateTime.parse(lastLoginDate);

          // 判斷是否為連續登入
          if (today.difference(lastLogin).inDays == 1) {
            // 連續登入
            await userDoc.update({
              'lastLoginDate': todayString,
              'consecutiveLoginDays': consecutiveLoginDays + 1,
            });
          } else if (today.difference(lastLogin).inDays > 1) {
            // 中斷連續登入
            await userDoc.update({
              'lastLoginDate': todayString,
              'consecutiveLoginDays': 1,
            });
          }
        } else {
          // 第一次登入
          await userDoc.update({
            'lastLoginDate': todayString,
            'consecutiveLoginDays': 1,
          });
        }
      } else {
        // 如果文件不存在，創建新文件
        await userDoc.set({
          'lastLoginDate': todayString,
          'consecutiveLoginDays': 1,
        });
      }
    } catch (e) {
      print('更新登入資料失敗: $e');
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
