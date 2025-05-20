class Kotoba {
  final String word;
  final String phonetic;
  final String mean;
  // 可以根據您的 JSON 結構添加其他欄位，例如 id, lesson, type 等

  Kotoba({required this.word, required this.phonetic, required this.mean});

  factory Kotoba.fromJson(Map<String, dynamic> json) {
    return Kotoba(
      word: json['word'] as String? ?? '', // Handle potential null
      phonetic: json['phonetic'] as String? ?? '', // Handle potential null
      mean: json['mean'] as String? ?? '', // Handle potential null
    );
  }
}
