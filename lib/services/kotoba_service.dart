import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/kotoba.dart'; // 導入 Kotoba 模型

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
