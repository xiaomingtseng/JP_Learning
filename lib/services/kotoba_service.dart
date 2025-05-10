import 'dart:convert';
import 'package:flutter/services.dart';

class Kotoba {
  final String word;
  final String phonetic;
  final String mean;

  Kotoba({required this.word, required this.phonetic, required this.mean});

  factory Kotoba.fromJson(Map<String, dynamic> json) {
    return Kotoba(
      word: json['word'] as String,
      // 若 phonetic 為 null（原本替換 NaN 得到 null），則給空字串
      phonetic: json['phonetic']?.toString() ?? '',
      mean: json['mean'] as String,
    );
  }
}

class KotobaService {
  // 從 assets 取得 JSON，並先處理 NaN 使其符合 JSON 格式
  Future<List<Kotoba>> fetchKotobaFromAssets(String assetPath) async {
    String jsonString = await rootBundle.loadString(assetPath);
    // 將 NaN 替換成 null，注意用正則表達式以避免誤替
    jsonString = jsonString.replaceAll(RegExp(r'\bNaN\b'), 'null');

    final dynamic decoded = json.decode(jsonString);
    if (decoded is List) {
      return decoded.map((item) => Kotoba.fromJson(item)).toList();
    }
    throw Exception("JSON 格式不正確，請確認檔案內容符合 List 形式！");
  }
}
