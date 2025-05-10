import 'package:flutter/material.dart';

class LearningSet {
  final String id;
  final String title;
  final String description;
  final String author; // 例如 "JLPT N5", "大家的日本語 第1課", "使用者A"
  final int itemCount; // 例如單字數量
  final String category; // 例如 "JLPT", "教科書", "生活", "科技"
  final Color color; // 使用色彩代表每個學習集

  LearningSet({
    required this.id,
    required this.title,
    required this.category,
    this.description = '',
    this.author = '',
    this.itemCount = 0,
    required this.color,
  });
}
