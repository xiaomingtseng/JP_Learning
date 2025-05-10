class Notebook {
  String id;
  String name;
  // DateTime createdAt; // 可選：筆記本創建時間
  // List<Note> notes; // 未來可以擴展，讓筆記本包含筆記

  Notebook({
    required this.id,
    required this.name,
    // required this.createdAt,
  });

  // 新增：將 Notebook 物件轉換為 Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      // 'createdAt': createdAt.toIso8601String(), // 如果使用 createdAt
    };
  }

  // 新增：從 Map (JSON) 創建 Notebook 物件
  factory Notebook.fromJson(Map<String, dynamic> json) {
    return Notebook(
      id: json['id'] as String,
      name: json['name'] as String,
      // createdAt: DateTime.parse(json['createdAt'] as String), // 如果使用 createdAt
    );
  }
}

class Group {
  String id;
  String name;
  List<Notebook> notebooks;
  String userId; // 新增：用於綁定使用者
  // DateTime createdAt; // 可選：群組創建時間

  Group({
    required this.id,
    required this.name,
    required this.userId, // 新增
    this.notebooks = const [],
    // required this.createdAt,
  });

  // 新增：將 Group 物件轉換為 Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId, // 新增
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
      notebooks: notebooks,
      // createdAt: DateTime.parse(json['createdAt'] as String), // 如果使用 createdAt
    );
  }
}
