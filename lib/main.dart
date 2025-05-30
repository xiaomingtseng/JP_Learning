import 'package:flutter/material.dart';
import 'package:jp_learning/screens/home_screen.dart'; // 或者您的載入畫面
import 'package:jp_learning/theme_notifier.dart'; // 匯入主題設定檔
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // 匯入 Firebase Core
import 'firebase_options.dart'; // 新增 firebase_options.dart 的匯入
import 'package:firebase_auth/firebase_auth.dart'; // 匯入 Firebase Auth
import 'package:jp_learning/screens/login_screen.dart'; // 假設您有一個登入畫面

void main() async {
  // 將 main 函數改為 async
  WidgetsFlutterBinding.ensureInitialized(); // 確保 Flutter 綁定已初始化
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform, // 使用 firebase_options.dart 中的設定
  );
  runApp(
    ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'JP Learning App',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeNotifier.themeMode,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // 或者您的載入畫面
          }
          if (snapshot.hasData) {
            return const HomeScreen(); // 使用者已登入
          }
          return const LoginScreen(); // 使用者未登入，顯示登入畫面
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
