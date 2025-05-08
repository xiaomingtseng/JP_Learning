class DictionaryEntry {
  final String id;
  final String term; // 日文單字，例如："日本語"
  final String reading; // 讀音，例如："にほんご"
  final List<MeaningEntry> meanings; // 多個詞義和詞性
  final String? jlptLevel; // 例如："N5", "N4"
  final List<ExampleSentence>? examples; // 例句
  final List<String>? tags; // 標籤，例如："常用", "書面語"
  final bool isFavorited; // 是否已收藏 (用於我的單字本)

  DictionaryEntry({
    required this.id,
    required this.term,
    required this.reading,
    required this.meanings,
    this.jlptLevel,
    this.examples,
    this.tags,
    this.isFavorited = false,
  });

  // 輔助方法，用於更新收藏狀態
  DictionaryEntrycopyWith({
    String? id,
    String? term,
    String? reading,
    List<MeaningEntry>? meanings,
    String? jlptLevel,
    List<ExampleSentence>? examples,
    List<String>? tags,
    bool? isFavorited,
  }) {
    return DictionaryEntry(
      id: id ?? this.id,
      term: term ?? this.term,
      reading: reading ?? this.reading,
      meanings: meanings ?? this.meanings,
      jlptLevel: jlptLevel ?? this.jlptLevel,
      examples: examples ?? this.examples,
      tags: tags ?? this.tags,
      isFavorited: isFavorited ?? this.isFavorited,
    );
  }
}

class MeaningEntry {
  final String partOfSpeech; // 詞性，例如："名詞", "動詞（一段）"
  final List<String> definitions; // 該詞性下的多個中文解釋

  MeaningEntry({required this.partOfSpeech, required this.definitions});
}

class ExampleSentence {
  final String japanese;
  final String? reading; // 例句的假名讀音 (可選)
  final String translation; // 例句的中文翻譯

  ExampleSentence({
    required this.japanese,
    this.reading,
    required this.translation,
  });
}
