import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      // 1. 初始化 GoogleSignIn
      // 您可以指定 scopes，例如 GoogleSignIn(scopes: ['email'])，但 'email' 通常是預設的。
      final GoogleSignIn googleSignIn = GoogleSignIn();
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

      // 2. 直接從 googleUser 取得 Email
      final String? userEmailFromGoogle = googleUser.email;
      print('Google User Email: $userEmailFromGoogle');

      // 3. 取得 Google Auth 憑證 (包含 idToken 和 accessToken)
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // idToken 是一個 JWT，其中包含 email 等資訊。
      // print('Google ID Token: ${googleAuth.idToken}');

      // 4. 建立 Firebase 憑證
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 5. 使用 Firebase 憑證登入
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      // 6. 從 Firebase User 物件取得 Email
      final String? userEmailFromFirebase = userCredential.user?.email;
      print('Firebase User Email: $userEmailFromFirebase');

      // 登入成功後，main.dart 中的 StreamBuilder 會自動處理導航到 HomeScreen
      // 您可以在此處顯示成功訊息
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
