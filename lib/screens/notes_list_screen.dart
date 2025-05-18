import 'package:flutter/material.dart';
import '../models/note_models.dart';
import '../services/note_service.dart';
import '../services/word_service.dart'; // 匯入 WordService
// import 'word_selection_screen.dart'; // 您需要建立這個畫面

class NotesListScreen extends StatefulWidget {
  final String groupId; // 新增 groupId
  final String notebookId;
  final String notebookName;
  final NoteService noteService; // 傳入 NoteService
  final WordService wordService; // 傳入 WordService

  const NotesListScreen({
    Key? key,
    required this.groupId, // 新增 groupId
    required this.notebookId,
    required this.notebookName,
    required this.noteService,
    required this.wordService, // 初始化 WordService
  }) : super(key: key);

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  Notebook? _currentNotebook;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotebookDetails();
  }

  Future<void> _loadNotebookDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // 修改：getNotebookById 需要 groupId
      final notebook = await widget.noteService.getNotebookById(
        widget.groupId, // 使用 widget.groupId
        widget.notebookId,
      );
      if (notebook != null) {
        setState(() {
          _currentNotebook = notebook;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = '找不到筆記本資料';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '載入筆記本內容失敗: $e';
        _isLoading = false;
      });
      print('載入筆記本內容時發生錯誤: $e');
    }
  }

  Future<void> _addWordsToNotebook() async {
    final TextEditingController wordController = TextEditingController();
    final TextEditingController phoneticController = TextEditingController();
    final TextEditingController meanController = TextEditingController();

    final Word? newWord = await showDialog<Word>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('新增單字'),
          content: SingleChildScrollView(
            // Added SingleChildScrollView for smaller screens
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: wordController,
                  decoration: const InputDecoration(hintText: '單字 (例如: 新しい)'),
                  autofocus: true,
                ),
                TextField(
                  controller: phoneticController,
                  decoration: const InputDecoration(hintText: '讀音 (例如: あたらしい)'),
                ),
                TextField(
                  controller: meanController,
                  decoration: const InputDecoration(hintText: '意思 (例如: New)'),
                ),
              ],
            ),
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
                if (wordController.text.isNotEmpty &&
                    phoneticController.text.isNotEmpty &&
                    meanController.text.isNotEmpty) {
                  Navigator.of(context).pop(
                    Word(
                      word: wordController.text,
                      phonetic: phoneticController.text,
                      mean: meanController.text,
                    ),
                  );
                } else {
                  // Optionally, show a snackbar or some validation message
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('請填寫所有欄位')));
                }
              },
            ),
          ],
        );
      },
    );

    if (newWord != null) {
      if (_currentNotebook == null) return; // 確保 _currentNotebook 不是 null
      setState(() => _isLoading = true);
      try {
        final List<Word> updatedWords = List.from(_currentNotebook!.words)
          ..add(newWord); // Add the single new word
        final updatedNotebook = _currentNotebook!.copyWith(
          words: updatedWords,
        ); // 需要 Notebook 有 copyWith

        await widget.noteService.updateNotebook(
          widget.groupId, // 使用 widget.groupId
          updatedNotebook,
        );
        await _loadNotebookDetails(); // 重新載入筆記本內容以顯示新增的單字
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('新增單字到筆記本失敗: $e')));
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.notebookName)),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addWordsToNotebook,
        tooltip: '新增單字到筆記本',
        child: const Icon(Icons.add_comment_outlined),
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
            ElevatedButton(
              onPressed: _loadNotebookDetails,
              child: const Text('重試'),
            ),
          ],
        ),
      );
    }
    if (_currentNotebook == null || _currentNotebook!.words.isEmpty) {
      return const Center(
        child: Text('這個筆記本還沒有單字。\n點擊右下角按鈕新增一些吧！', textAlign: TextAlign.center),
      );
    }
    return ListView.builder(
      itemCount: _currentNotebook!.words.length,
      itemBuilder: (context, index) {
        final word = _currentNotebook!.words[index];
        return ListTile(
          title: Text(word.word),
          subtitle: Text('${word.phonetic} - ${word.mean}'),
          leading: const Icon(Icons.translate_outlined),
        );
      },
    );
  }
}
