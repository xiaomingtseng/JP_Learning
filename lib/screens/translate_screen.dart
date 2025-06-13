import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 用於複製到剪貼簿
import 'package:translator/translator.dart'; // 匯入 translator 套件
import 'package:flutter_tts/flutter_tts.dart'; // 匯入 flutter_tts 套件

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

enum TtsState { playing, stopped, paused, continued }

class _TranslateScreenState extends State<TranslateScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  bool _isLoading = false;
  final GoogleTranslator _translator = GoogleTranslator();

  String _sourceLanguageCode = 'auto';
  String _targetLanguageCode = 'ja';

  // TTS 相關變數
  late FlutterTts _flutterTts;
  TtsState _ttsState = TtsState.stopped;
  String? _ttsLanguage; // 用於設定 TTS 引擎的語言

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();

    // 監聽 TTS 狀態變化
    _flutterTts.setStartHandler(() {
      if (mounted) {
        setState(() {
          print("TTS Playing");
          _ttsState = TtsState.playing;
        });
      }
    });

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          print("TTS Complete");
          _ttsState = TtsState.stopped;
        });
      }
    });

    _flutterTts.setErrorHandler((msg) {
      if (mounted) {
        setState(() {
          print("TTS Error: $msg");
          _ttsState = TtsState.stopped;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('朗讀錯誤: $msg')));
        });
      }
    });

    // 嘗試設定預設語言，例如目標語言
    await _setTtsLanguage(_targetLanguageCode);
  }

  Future<void> _setTtsLanguage(String langCode) async {
    // 將 translator 的語言代碼映射到 TTS 引擎支援的代碼
    // 這部分可能需要根據 flutter_tts 的文檔和支援情況進行調整
    String ttsLang = langCode;
    if (langCode == 'ja') {
      ttsLang = 'ja-JP';
    } else if (langCode == 'zh-cn') {
      ttsLang = 'zh-CN';
    } else if (langCode == 'zh-tw') {
      ttsLang = 'zh-TW';
    } else if (langCode == 'en') {
      ttsLang = 'en-US';
    } else if (langCode == 'ko') {
      ttsLang = 'ko-KR';
    }
    // ... 其他語言映射

    try {
      // 檢查語言是否可用
      var languages = await _flutterTts.getLanguages;
      // print("Available TTS languages: $languages");
      if (languages is List && languages.contains(ttsLang)) {
        await _flutterTts.setLanguage(ttsLang);
        _ttsLanguage = ttsLang;
        print("TTS language set to: $ttsLang");
      } else {
        // 如果特定地區的語言不可用，嘗試只用語言代碼
        String baseLang = langCode.split('-')[0];
        if (languages is List && languages.contains(baseLang)) {
          await _flutterTts.setLanguage(baseLang);
          _ttsLanguage = baseLang;
          print("TTS language set to (base): $baseLang");
        } else {
          print("TTS language $ttsLang or $baseLang not available.");
          // 可以考慮設定一個預設的可用語言，或者提示使用者
          // await _flutterTts.setLanguage('en-US'); // 預設回退
          // _ttsLanguage = 'en-US';
        }
      }
    } catch (e) {
      print("Error setting TTS language: $e");
    }
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty && _ttsState == TtsState.stopped) {
      // 在朗讀前，確保 TTS 引擎的語言與翻譯結果的語言一致
      await _setTtsLanguage(_targetLanguageCode); // 朗讀目標語言的文本
      await _flutterTts.setPitch(1.0); // 預設音高
      await _flutterTts.setSpeechRate(0.5); // 預設語速
      var result = await _flutterTts.speak(text);
      if (result == 1) {
        if (mounted) setState(() => _ttsState = TtsState.playing);
      }
    }
  }

  Future<void> _stop() async {
    var result = await _flutterTts.stop();
    if (result == 1) {
      if (mounted) setState(() => _ttsState = TtsState.stopped);
    }
  }

  void _performTranslation() async {
    final inputText = _inputController.text.trim();
    if (inputText.isEmpty) {
      if (mounted) {
        setState(() {
          _outputController.text = "請輸入要翻譯的內容";
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _outputController.text = "翻譯中...";
        _ttsState = TtsState.stopped; // 重置朗讀狀態
      });
      await _stop(); // 如果之前在朗讀，先停止
    }

    try {
      final translation = await _translator.translate(
        inputText,
        from: _sourceLanguageCode,
        to: _targetLanguageCode,
      );
      if (mounted) {
        setState(() {
          _outputController.text = translation.text;
          // 翻譯完成後，更新 TTS 語言以匹配目標語言
          // _setTtsLanguage(_targetLanguageCode); // 這一步可以在 _speak 之前做
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _outputController.text = "翻譯失敗: $e";
        });
      }
      print("翻譯錯誤: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _swapLanguages() {
    if (mounted) {
      setState(() {
        final tempLangCode = _sourceLanguageCode;
        _sourceLanguageCode =
            _targetLanguageCode == 'auto' ? 'ja' : _targetLanguageCode;
        _targetLanguageCode = tempLangCode == 'auto' ? 'zh-cn' : tempLangCode;

        if (_sourceLanguageCode == 'auto' && _targetLanguageCode == 'auto') {
          _sourceLanguageCode = 'zh-cn';
          _targetLanguageCode = 'ja';
        }
        if (_sourceLanguageCode == _targetLanguageCode &&
            _sourceLanguageCode != 'auto') {
          _targetLanguageCode = (_sourceLanguageCode == 'ja') ? 'zh-cn' : 'ja';
        }

        // 交換語言後，也更新 TTS 引擎的預設語言
        // _setTtsLanguage(_targetLanguageCode); // 這一步可以在 _speak 之前做

        final tempText = _inputController.text;
        _inputController.text =
            _outputController.text.startsWith("翻譯失敗") ||
                    _outputController.text == "翻譯中..." ||
                    _outputController.text == "請輸入要翻譯的內容" ||
                    _outputController.text == "翻譯結果將顯示於此"
                ? ""
                : _outputController.text;
        _outputController.text = tempText;

        if (_inputController.text.isNotEmpty) {
          _performTranslation();
        } else {
          _ttsState = TtsState.stopped; // 如果清空了輸入，也重置朗讀狀態
          _stop();
        }
      });
    }
  }

  void _copyToClipboard(String text) {
    if (text.isNotEmpty &&
        text != "翻譯中..." &&
        text != "請輸入要翻譯的內容" &&
        !text.startsWith("翻譯失敗") &&
        text != "翻譯結果將顯示於此") {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已複製到剪貼簿')));
    }
  }

  void _clearInput() {
    _inputController.clear();
    if (mounted) {
      setState(() {
        _outputController.text = "";
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    _flutterTts.stop(); // 停止 TTS
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black54;
    final dropdownTextColor = Theme.of(context).textTheme.titleMedium?.color;

    // 根據來源語言動態設定 hintText
    String inputHintText = '輸入要翻譯的文本'; // 預設提示
    if (_sourceLanguageCode == 'ja') {
      inputHintText = '例如：こんにちは';
    } else if (_sourceLanguageCode == 'en') {
      inputHintText = 'For example: Hello';
    } else if (_sourceLanguageCode == 'zh-cn' ||
        _sourceLanguageCode == 'zh-tw') {
      inputHintText = '例如：你好';
    } else if (_sourceLanguageCode == 'ko') {
      inputHintText = '예: 안녕하세요';
    }
    // 如果是 'auto' 或其他未指定的語言，可以使用通用提示或不加範例

    return Scaffold(
      body: SafeArea(
        // Wrap with SafeArea
        child: SingleChildScrollView(
          // <--- 加入 SingleChildScrollView
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    _buildLanguageDropdown(
                      _sourceLanguageCode,
                      true,
                      iconColor,
                      dropdownTextColor,
                    ),
                    IconButton(
                      icon: Icon(Icons.swap_horiz, color: iconColor),
                      tooltip: '交換語言',
                      onPressed: _swapLanguages,
                    ),
                    _buildLanguageDropdown(
                      _targetLanguageCode,
                      false,
                      iconColor,
                      dropdownTextColor,
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                TextField(
                  controller: _inputController,
                  decoration: InputDecoration(
                    labelText: '輸入要翻譯的文本', // labelText 可以保持不變
                    hintText: inputHintText, // 使用動態生成的 hintText
                    border: const OutlineInputBorder(),
                    suffixIcon:
                        _inputController.text.isNotEmpty
                            ? IconButton(
                              icon: Icon(Icons.clear, color: iconColor),
                              onPressed: _clearInput,
                            )
                            : null,
                  ),
                  minLines: 3,
                  maxLines: 5,
                  onChanged: (text) {
                    if (mounted) setState(() {});
                  },
                ),
                const SizedBox(height: 16.0),

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
                const SizedBox(height: 16.0), // Reduced height

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '翻譯結果:',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        if (_outputController.text.isNotEmpty &&
                            _outputController.text != "翻譯中..." &&
                            _outputController.text != "請輸入要翻譯的內容" &&
                            !_outputController.text.startsWith("翻譯失敗"))
                          IconButton(
                            icon: Icon(
                              Icons.copy_all_outlined,
                              color: iconColor,
                            ),
                            tooltip: '複製結果',
                            onPressed:
                                () => _copyToClipboard(_outputController.text),
                          ),
                        if (_outputController.text.isNotEmpty &&
                            _outputController.text != "翻譯中..." &&
                            _outputController.text != "請輸入要翻譯的內容" &&
                            !_outputController.text.startsWith("翻譯失敗"))
                          IconButton(
                            icon: Icon(
                              _ttsState == TtsState.playing
                                  ? Icons.stop_circle_outlined
                                  : Icons.volume_up_outlined,
                              color: iconColor,
                            ),
                            tooltip:
                                _ttsState == TtsState.playing ? '停止朗讀' : '朗讀結果',
                            onPressed: () {
                              if (_ttsState == TtsState.playing) {
                                _stop();
                              } else {
                                _speak(_outputController.text);
                              }
                            },
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(4.0),
                    color: Theme.of(context).cardColor.withOpacity(0.5),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _outputController.text.isEmpty
                          ? '翻譯結果將顯示於此'
                          : _outputController.text,
                      style: TextStyle(
                        fontSize: 16.0,
                        color:
                            _outputController.text.isEmpty ||
                                    _outputController.text == "翻譯中..." ||
                                    _outputController.text == "請輸入要翻譯的內容" ||
                                    _outputController.text.startsWith("翻譯失敗:")
                                ? Colors.grey
                                : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown(
    String currentLanguageCode,
    bool isSource,
    Color? iconColor,
    Color? textColor,
  ) {
    final Map<String, String> languages = {
      'auto': '自動偵測',
      'en': '英文',
      'zh-cn': '簡體中文',
      'zh-tw': '繁體中文',
      'ja': '日文',
      'ko': '韓文',
    };

    List<DropdownMenuItem<String>> items = [];
    if (isSource) {
      items =
          languages.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value, style: TextStyle(color: textColor)),
            );
          }).toList();
    } else {
      items =
          languages.entries.where((entry) => entry.key != 'auto').map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value, style: TextStyle(color: textColor)),
            );
          }).toList();
    }

    return DropdownButton<String>(
      value: currentLanguageCode,
      icon: Icon(Icons.arrow_drop_down, color: iconColor),
      dropdownColor: Theme.of(context).cardColor,
      onChanged: (String? newValue) {
        if (newValue != null) {
          if (mounted) {
            setState(() {
              if (isSource) {
                _sourceLanguageCode = newValue;
                if (_sourceLanguageCode == _targetLanguageCode &&
                    _sourceLanguageCode != 'auto') {
                  _targetLanguageCode =
                      (_sourceLanguageCode == 'ja') ? 'zh-cn' : 'ja';
                }
              } else {
                _targetLanguageCode = newValue;
                if (_sourceLanguageCode == _targetLanguageCode &&
                    _targetLanguageCode != 'auto') {
                  _sourceLanguageCode =
                      (_targetLanguageCode == 'ja') ? 'zh-cn' : 'ja';
                }
              }
              // 當語言改變時，也嘗試更新 TTS 引擎的語言
              // 如果是目標語言改變了，就更新 TTS 語言
              if (!isSource) {
                // _setTtsLanguage(_targetLanguageCode); // 這一步可以在 _speak 之前做
              }
            });
          }
        }
      },
      items: items,
    );
  }
}
