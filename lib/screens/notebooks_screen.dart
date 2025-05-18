import 'package:flutter/material.dart';
import '../models/note_models.dart';
import '../services/note_service.dart'; // 確保路徑正確
import 'notes_list_screen.dart'; // 匯入 NotesListScreen
import '../services/word_service.dart'; // 匯入 WordService

class NotebooksScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final NoteService noteService; // 傳入 NoteService 實例

  const NotebooksScreen({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.noteService,
  }) : super(key: key);

  @override
  State<NotebooksScreen> createState() => _NotebooksScreenState();
}

class _NotebooksScreenState extends State<NotebooksScreen> {
  List<Notebook> _notebooks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotebooks();
  }

  Future<void> _loadNotebooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final group = await widget.noteService.findGroupById(widget.groupId);
      if (group != null) {
        setState(() {
          _notebooks = group.notebooks;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = '找不到群組資料';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '載入筆記本失敗: $e';
        _isLoading = false;
      });
      print('載入筆記本時發生錯誤: $e');
    }
  }

  Future<void> _addNotebook() async {
    final TextEditingController nameController = TextEditingController();
    final notebookName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('新增筆記本'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(hintText: '筆記本名稱'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('新增'),
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop(nameController.text.trim());
                }
              },
            ),
          ],
        );
      },
    );

    if (notebookName != null && notebookName.isNotEmpty) {
      setState(() {
        _isLoading = true; // 顯示載入指示器
      });
      try {
        final newNotebook = await widget.noteService.addNotebookToGroup(
          widget.groupId,
          notebookName,
        );
        if (newNotebook != null) {
          // 重新載入筆記本列表以顯示新增的筆記本
          await _loadNotebooks();
        } else {
          // 處理新增失敗的情況
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('新增筆記本失敗')));
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('新增筆記本時發生錯誤: $e')));
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('群組: ${widget.groupName}')),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNotebook,
        tooltip: '新增筆記本',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            ElevatedButton(onPressed: _loadNotebooks, child: const Text('重試')),
          ],
        ),
      );
    }
    if (_notebooks.isEmpty) {
      return const Center(
        child: Text('這個群組還沒有筆記本。\n點擊右下角按鈕新增一個吧！', textAlign: TextAlign.center),
      );
    }
    return ListView.builder(
      itemCount: _notebooks.length,
      itemBuilder: (context, index) {
        final notebook = _notebooks[index];
        return ListTile(
          title: Text(notebook.name),
          leading: const Icon(Icons.book_outlined), // 筆記本圖示
          onTap: () {
            print('點擊了筆記本: ${notebook.name} (ID: ${notebook.id})');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => NotesListScreen(
                      groupId: widget.groupId, // 新增傳遞 groupId
                      notebookId: notebook.id,
                      notebookName: notebook.name,
                      noteService: widget.noteService,
                      wordService: WordService(), // 建立 WordService 實例
                    ),
              ),
            );
          },
          // 可以加入長按刪除或編輯的功能
        );
      },
    );
  }
}
