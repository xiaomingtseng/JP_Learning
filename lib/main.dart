import 'package:flutter/material.dart';
import 'package:jp_learning/screens/home_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(), // 將 home 指向 LoadingScreen
    );
  }
}
