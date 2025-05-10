import 'package:flutter/material.dart';
import 'package:jp_learning/screens/home_screen.dart'; // 或者您的載入畫面
import 'package:jp_learning/theme_notifier.dart';
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

    // 定義您的亮色和暗色主題
    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue, // 您可以自訂主色調
      // ... 其他亮色主題設定
    );

    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Colors.blue.shade300, // 例如：深色模式下使用較淺的藍色作為主色
        secondary: Colors.tealAccent.shade200, // 例如：深色模式下的強調色
        surface: Colors.grey[850]!, // 您目前的 cardColor
        // background: Colors.black87, // 您目前的 scaffoldBackgroundColor
        error: Colors.redAccent.shade100,
        onPrimary: Colors.black, // 在主色背景上的文字/圖示顏色 (例如，如果按鈕背景是淺藍色)
        onSecondary: Colors.black, // 在強調色背景上的文字/圖示顏色
        onSurface: Colors.white, // 在 surface (如卡片、對話框) 背景上的文字/圖示顏色
        // onBackground: Colors.white, // 在 background (如 Scaffold) 背景上的文字/圖示顏色
        onError: Colors.black, // 在錯誤顏色背景上的文字/圖示顏色
      ),
      scaffoldBackgroundColor: Colors.black87, // 可以由 colorScheme.background 控制
      cardColor: Colors.grey[850], // 可以由 colorScheme.surface 控制
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white), // 您已設定
        bodyMedium: TextStyle(color: Colors.white70), // 您已設定
        // 其他文字樣式會嘗試從 ColorScheme (例如 onSurface) 或 ThemeData 的預設值繼承
        // 如果特定文字仍然是黑色，您可能需要在此處明確定義更多文字樣式，例如：
        // titleMedium: TextStyle(color: Colors.white),
        // labelSmall: TextStyle(color: Colors.white70),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black87, // 或者使用 colorScheme.surface
        iconTheme: IconThemeData(color: Colors.white), // 您的設定很好
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.normal /* 您可以調整樣式 */,
        ), // 您的設定很好
      ),
      iconTheme: const IconThemeData(
        color: Colors.white, // 全域圖示顏色，您的設定很好
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
        ), // 確保文字按鈕的文字為白色
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              Colors.blue.shade300, // 按鈕背景 (與 colorScheme.primary 匹配)
          foregroundColor:
              Colors.black, // 按鈕上的文字/圖示 (與 colorScheme.onPrimary 匹配)
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.blue.shade300),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.grey[850], // 深色背景
        selectedItemColor: Colors.white, // 選中項目的圖示和文字顏色
        unselectedItemColor: Colors.grey[600], // 未選中項目的圖示和文字顏色 (可以調亮一點的灰)
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed, // 確保與您在 HomeScreen 中使用的 type 一致
      ),
      // ... 其他暗色主題設定
    );

    return MaterialApp(
      title: 'JP Learning App',
      theme: lightTheme, // 亮色主題
      darkTheme: darkTheme, // 暗色主題
      themeMode: themeNotifier.themeMode, // 根據 ThemeNotifier 設定模式
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
