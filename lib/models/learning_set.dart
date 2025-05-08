// (如果 'models' 資料夾不存在，請建立它)
// (或者，您可以暫時將這個類別直接放在 learning_screen.dart 頂部，之後再移動)

class LearningSet {
  final String id;
  final String title;
  final String description;
  final String author; // 例如 "JLPT N5", "大家的日本語 第1課", "使用者A"
  final int itemCount; // 例如單字數量
  final String category; // 例如 "JLPT", "教科書", "生活", "科技"
  final String? imageUrl; // 可選的封面圖片

  LearningSet({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.itemCount,
    required this.category,
    this.imageUrl,
  });
}
