import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 用於複製到剪貼簿

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  String _translatedText = "";
  bool _isLoading = false;

  // 模擬的翻譯函式
  Future<String> _mockTranslate(String text) async {
    if (text.isEmpty) {
      return "";
    }
    // 模擬網路延遲
    await Future.delayed(const Duration(seconds: 1));
    // 簡單的模擬翻譯：將文本倒序並加上標記
    return "${text.split('').reversed.join('')} (模擬翻譯)";
  }

  void _performTranslation() async {
    if (_inputController.text.trim().isEmpty) {
      setState(() {
        _translatedText = "請輸入要翻譯的內容";
        _outputController.text = _translatedText;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _translatedText = "翻譯中...";
      _outputController.text = _translatedText;
    });

    try {
      final result = await _mockTranslate(_inputController.text.trim());
      setState(() {
        _translatedText = result;
        _outputController.text = _translatedText;
      });
    } catch (e) {
      setState(() {
        _translatedText = "翻譯失敗: $e";
        _outputController.text = _translatedText;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard(String text) {
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已複製到剪貼簿')));
    }
  }

  void _clearInput() {
    _inputController.clear();
    setState(() {
      _translatedText = "";
      _outputController.text = "";
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 如果這個頁面是 BottomNavigationBar 的一部分，通常不需要自己的 AppBar
      // appBar: AppBar(
      //   title: const Text('文本翻譯'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 輸入區域
            TextField(
              controller: _inputController,
              decoration: InputDecoration(
                labelText: '輸入要翻譯的文本',
                hintText: '例如：こんにちは',
                border: const OutlineInputBorder(),
                suffixIcon:
                    _inputController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _clearInput,
                        )
                        : null,
              ),
              minLines: 3,
              maxLines: 5,
              onChanged: (text) {
                // 當輸入文字變更時，也更新狀態以顯示/隱藏清除按鈕
                setState(() {});
              },
            ),
            const SizedBox(height: 16.0),

            // 翻譯按鈕
            ElevatedButton.icon(
              icon:
                  _isLoading
                      ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                      : const Icon(Icons.translate),
              label: const Text('翻譯'),
              onPressed: _isLoading ? null : _performTranslation,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                textStyle: const TextStyle(fontSize: 16.0),
              ),
            ),
            const SizedBox(height: 24.0),

            // 輸出區域標題
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '翻譯結果:',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                if (_outputController.text.isNotEmpty &&
                    _outputController.text != "翻譯中..." &&
                    _outputController.text != "請輸入要翻譯的內容" &&
                    !_outputController.text.startsWith("翻譯失敗"))
                  IconButton(
                    icon: const Icon(Icons.copy_all_outlined),
                    tooltip: '複製結果',
                    onPressed: () => _copyToClipboard(_outputController.text),
                  ),
              ],
            ),
            const SizedBox(height: 8.0),
            // 輸出區域 (使用 TextField 使其可選中和複製)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(4.0),
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800] // 暗黑模式下的背景色
                          : Colors.grey[100], // 亮色模式下的背景色
                ),
                child: SingleChildScrollView(
                  // 如果內容過長，允許滾動
                  child: SelectableText(
                    // 使用 SelectableText 方便複製
                    _outputController.text.isEmpty
                        ? '翻譯結果將顯示於此'
                        : _outputController.text,
                    style: TextStyle(
                      fontSize: 16.0,
                      color:
                          _outputController.text.isEmpty ||
                                  _outputController.text == "翻譯中..." ||
                                  _outputController.text == "請輸入要翻譯的內容"
                              ? Colors.grey
                              : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
