import 'package:flutter/material.dart';
import 'package:jp_learning/screens/home_screen.dart'; // 或者您的載入畫面
import 'package:jp_learning/theme_notifier.dart';
import 'package:provider/provider.dart';
// import 'package:jp_learning/screens/loading_screen.dart'; // 如果您有載入畫面

void main() {
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
      primarySwatch: Colors.blue, // 暗色模式下的主色調也可以自訂
      // scaffoldBackgroundColor: Colors.black87, // 例如，設定暗色背景
      // cardColor: Colors.grey[850], // 例如，設定卡片顏色
      // ... 其他暗色主題設定
    );

    return MaterialApp(
      title: 'JP Learning App',
      theme: lightTheme, // 亮色主題
      darkTheme: darkTheme, // 暗色主題
      themeMode: themeNotifier.themeMode, // 根據 ThemeNotifier 設定模式
      home: const HomeScreen(), // 或者 LoadingScreen()
      debugShowCheckedModeBanner: false,
    );
  }
}
