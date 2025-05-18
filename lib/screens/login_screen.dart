import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      // 初始化 GoogleSignIn
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // 強制登出之前的帳戶，確保每次登入都能選擇帳戶
      await googleSignIn.signOut();

      // 開始 Google 登入流程
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // 使用者取消登入
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Google 登入已取消')));
        }
        return;
      }

      // 取得 Google Auth 憑證
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 建立 Firebase 憑證
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 使用 Firebase 憑證登入
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      // 登入成功後顯示訊息
      final String? userEmailFromFirebase = userCredential.user?.email;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google 登入成功: ${userEmailFromFirebase ?? 'N/A'}'),
          ),
        );
      }
    } catch (e) {
      // 處理登入錯誤
      print('Google Sign-In Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Google 登入失敗: ${e.toString()}')));
      }
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
                // 下面這行已不再需要，因為 _signInWithGoogle 方法會處理回饋
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(content: Text('Google 登入功能待實作')),
                // );
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
