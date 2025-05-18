import '../services/word_service.dart'; // 匯入 Word 模型

class Notebook {
  String id;
  String name;
  List<Word> words; // 新增：用於儲存單字列表
  // DateTime createdAt; // 可選：筆記本創建時間

  Notebook({
    required this.id,
    required this.name,
    this.words = const [], // 初始化為空列表
    // required this.createdAt,
  });

  // 新增：將 Notebook 物件轉換為 Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'words': words.map((word) => word.toJson()).toList(), // 序列化 Word 列表
      // 'createdAt': createdAt.toIso8601String(), // 如果使用 createdAt
    };
  }

  // 新增：從 Map (JSON) 創建 Notebook 物件
  factory Notebook.fromJson(Map<String, dynamic> json) {
    var wordsList = json['words'] as List<dynamic>?;
    List<Word> parsedWords =
        wordsList != null
            ? wordsList
                .map(
                  (wordJson) => Word.fromJson(wordJson as Map<String, dynamic>),
                )
                .toList()
            : [];
    return Notebook(
      id: json['id'] as String,
      name: json['name'] as String,
      words: parsedWords, // 解析 Word 列表
      // createdAt: DateTime.parse(json['createdAt'] as String), // 如果使用 createdAt
    );
  }
}

// 新增 copyWith extension
extension NotebookCopyWith on Notebook {
  Notebook copyWith({String? id, String? name, List<Word>? words}) {
    return Notebook(
      id: id ?? this.id,
      name: name ?? this.name,
      words: words ?? this.words,
    );
  }
}

class Group {
  String id;
  String name;
  List<Notebook> notebooks;
  String userId; // 新增：用於綁定使用者
  String owner; // 新增：用於儲存群組擁有者的唯一識別 (例如 email)
  // DateTime createdAt; // 可選：群組創建時間

  Group({
    required this.id,
    required this.name,
    required this.userId, // 新增
    required this.owner, // 新增
    this.notebooks = const [],
    // required this.createdAt,
  });

  // 新增：將 Group 物件轉換為 Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId, // 新增
      'owner': owner, // 新增
      'notebooks': notebooks.map((notebook) => notebook.toJson()).toList(),
      // 'createdAt': createdAt.toIso8601String(), // 如果使用 createdAt
    };
  }

  // 新增：從 Map (JSON) 創建 Group 物件
  factory Group.fromJson(Map<String, dynamic> json) {
    var notebooksList = json['notebooks'] as List<dynamic>?;
    List<Notebook> notebooks =
        notebooksList != null
            ? notebooksList
                .map((i) => Notebook.fromJson(i as Map<String, dynamic>))
                .toList()
            : [];
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      userId: json['userId'] as String, // 新增
      owner: json['owner'] as String? ?? '', // 新增，並提供預設值以防舊資料沒有此欄位
      notebooks: notebooks,
      // createdAt: DateTime.parse(json['createdAt'] as String), // 如果使用 createdAt
    );
  }
}
