import 'dart:async'; // Import for TimeoutException
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart'; // Import the translator package

class RealtimeTranslateScreen extends StatefulWidget {
  const RealtimeTranslateScreen({super.key});

  @override
  State<RealtimeTranslateScreen> createState() =>
      _RealtimeTranslateScreenState();
}

class _RealtimeTranslateScreenState extends State<RealtimeTranslateScreen> {
  final SpeechToText _speechToText = SpeechToText();
  bool _isSpeechAvailable = false;
  bool _isListening = false;
  String _sourceLanguage = '中文';
  String _targetLanguage = '日文';
  String _recognizedText = '';
  String _translatedText = ''; // Add state for translated text
  String _currentLocaleId = 'zh_CN'; // Default to Chinese
  final GoogleTranslator _translator =
      GoogleTranslator(); // Initialize translator
  List<LocaleName> _localeNames = [];

  @override
  void initState() {
    super.initState();
    _initSpeechToText();
  }

  Future<void> _initSpeechToText() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      _isSpeechAvailable = await _speechToText.initialize(
        onError: _onSttError,
        onStatus: _onSttStatus,
      );
      if (_isSpeechAvailable) {
        _localeNames = await _speechToText.locales();
        // Ensure mounted check before calling setState indirectly via _updateCurrentLocaleId
        if (mounted) {
          _updateCurrentLocaleId();
        }
      }
    } else {
      // Handle permission denied
      print("Microphone permission denied");
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _updateCurrentLocaleId() {
    _currentLocaleId = _getLocaleIdForLanguage(_sourceLanguage);
    print("Current locale ID set to: $_currentLocaleId");
    // If listening, stop and restart with the new locale
    if (_isListening) {
      _stopListening().then((_) {
        if (mounted) {
          // Check mounted before starting listening again
          _startListening();
        }
      });
    }
  }

  String _getLocaleIdForLanguage(String language) {
    if (language == '中文') {
      return _localeNames
          .firstWhere(
            (locale) => locale.localeId.startsWith('zh_CN'),
            orElse: () => _localeNames.first,
          )
          .localeId;
    } else if (language == '日文') {
      return _localeNames
          .firstWhere(
            (locale) => locale.localeId.startsWith('ja_JP'),
            orElse: () => _localeNames.first,
          )
          .localeId;
    }
    return _localeNames.isNotEmpty
        ? _localeNames.first.localeId
        : 'en_US'; // Default fallback
  }

  void _startListening() {
    if (!_isSpeechAvailable || _speechToText.isListening) return;
    if (mounted) {
      setState(() {
        _recognizedText = ''; // Clear previous recognized text
        _translatedText = ''; // Clear previous translated text
      });
    }
    _speechToText.listen(
      // The result object is of type SpeechRecognitionResult from the speech_to_text package
      onResult: (result) {
        if (mounted) {
          // Pass both recognizedWords and finalResult from the result object
          _onSpeechResult(result.recognizedWords, result.finalResult);
        }
      },
      localeId: _currentLocaleId,
      // partialResults: true, // Default is true, onResult is called for partial results
      // listenMode: ListenMode.confirmation, // Consider if confirmation mode is desired
    );
    if (mounted) {
      setState(() {
        _isListening = true;
      });
    }
  }

  Future<void> _stopListening() async {
    if (!_speechToText.isListening) return;
    await _speechToText.stop();
    if (mounted) {
      // Check mounted before this setState
      setState(() {
        _isListening = false;
      });
    }
  }

  // Modified to accept finalResult
  void _onSpeechResult(String text, bool finalResult) {
    print("[SPEECH_RESULT] Recognized: \"$text\", Final: $finalResult");
    if (mounted) {
      setState(() {
        _recognizedText = text; // Update recognized text for display
      });
    }

    // Translate only on final result and if text is not empty
    if (finalResult && text.isNotEmpty) {
      print("[SPEECH_RESULT] Final result received, calling translateText.");
      _translateText(text);
    }
  }

  void _onSttStatus(String status) {
    print(
      "[STT_STATUS] Status: $status, current _isListening: $_isListening, speechToText.isListening: ${_speechToText.isListening}",
    );
    if (mounted) {
      bool newListeningState;
      if (status == 'listening') {
        newListeningState = true;
      } else {
        newListeningState = false;
      }

      // Only call setState if the listening state actually changes
      if (_isListening != newListeningState) {
        setState(() {
          _isListening = newListeningState;
          print(
            "[STT_STATUS] setState: _isListening set to $newListeningState due to status '$status'",
          );
        });
      } else {
        print(
          "[STT_STATUS] No change in listening state needed for status '$status', _isListening is already $newListeningState",
        );
      }
    }
    // Removed translation call from here, it's now handled by _onSpeechResult
  }

  void _onSttError(error) {
    print("[STT_ERROR] Error: $error");
    String errorMessage = "語音辨識時發生未知的錯誤，請稍後再試。";
    String errorString = error.toString().toLowerCase();

    if (errorString.contains("network")) {
      errorMessage = "網路連線錯誤，請檢查您的網路設定後再試。";
    } else if (errorString.contains("speech_timeout") ||
        errorString.contains("speech timeout")) {
      errorMessage = "沒有偵測到語音輸入，請大聲一點或靠近麥克風再試一次。";
    } else if (errorString.contains("no_match") ||
        errorString.contains("no match")) {
      errorMessage = "無法辨識您的語音，請嘗試用更清晰的發音再說一次。";
    } else if (errorString.contains("audio")) {
      errorMessage = "麥克風發生問題，請檢查麥克風權限或裝置。";
    } else if (errorString.contains("server")) {
      errorMessage = "語音辨識伺服器忙碌中或發生問題，請稍後再試。";
    } else if (errorString.contains("client")) {
      errorMessage = "應用程式內部錯誤，導致語音辨識失敗。";
    } else if (errorString.contains("permission")) {
      errorMessage = "麥克風權限未授予，請允許應用程式使用麥克風。";
    }

    // 發生錯誤時，停止聆聽並更新UI
    if (mounted) {
      setState(() {
        _isListening = false; // 確保停止聆聽狀態
        _recognizedText = errorMessage;
        _translatedText = ""; // 清空翻譯結果
      });
    }
    // 確保實際停止 speech_to_text 的聆聽
    if (_speechToText.isListening) {
      _speechToText.stop().then((_) {
        print("[STT_ERROR] Speech_to_text explicitly stopped due to error.");
      });
    }
  }

  Future<void> _translateText(String text) async {
    if (!mounted) {
      print(
        "[TRANSLATE_TEXT] Attempted to translate but widget is not mounted.",
      );
      return;
    }

    if (text.isEmpty) {
      if (mounted) {
        setState(() {
          _translatedText = '';
        });
      }
      print("[TRANSLATE_TEXT] Input text is empty, clearing translation.");
      return;
    }

    print(
      "[TRANSLATE_TEXT] Starting translation for: \"$text\"",
    ); // Corrected line
    if (mounted) {
      setState(() {
        _translatedText = '翻譯中...'; // Indicate loading
      });
    }

    try {
      final sourceLang = _sourceLanguage == '中文' ? 'zh-cn' : 'ja';
      final targetLang = _targetLanguage == '中文' ? 'zh-cn' : 'ja';
      print(
        "[TRANSLATE_TEXT] Source Lang: $sourceLang, Target Lang: $targetLang",
      );

      if (sourceLang == targetLang) {
        if (mounted) {
          setState(() {
            _translatedText = text;
          });
        }
        print(
          "[TRANSLATE_TEXT] Source and target languages are the same. No translation needed.",
        );
        return;
      }

      print("[TRANSLATE_TEXT] Calling _translator.translate API...");
      var translation = await _translator
          .translate(text, from: sourceLang, to: targetLang)
          .timeout(const Duration(seconds: 15)); // Added timeout

      print("[TRANSLATE_TEXT] Translation API returned: ${translation.text}");
      if (mounted) {
        setState(() {
          _translatedText = translation.text;
        });
        print("[TRANSLATE_TEXT] Translation successful, UI updated.");
      }
    } on TimeoutException catch (e, s) {
      // Catch TimeoutException
      print("[TRANSLATE_TEXT] Translation Timeout: $e");
      print("[TRANSLATE_TEXT] Stack trace: $s");
      if (mounted) {
        setState(() {
          _translatedText = '翻譯超時，請檢查網路或稍後再試。';
        });
      }
    } catch (e, s) {
      print("[TRANSLATE_TEXT] Translation error: $e");
      print("[TRANSLATE_TEXT] Stack trace: $s");
      if (mounted) {
        // 嘗試從錯誤中提取更友善的訊息
        String friendlyError = "翻譯時發生未預期的錯誤，請稍後再試。";
        if (e.toString().toLowerCase().contains("socketexception") ||
            e.toString().toLowerCase().contains("httpexception")) {
          friendlyError = "網路連線問題導致翻譯失敗，請檢查您的網路。";
        } else if (e.toString().contains("translator_error")) {
          // 假設 translator 套件可能有特定的錯誤標識
          friendlyError = "翻譯服務暫時不可用，請稍後再試。";
        }
        setState(() {
          _translatedText = friendlyError;
        });
      }
    }
  }

  void _toggleRecording() {
    if (!_isSpeechAvailable) return;
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;
      _updateCurrentLocaleId();
      // 交換語言時，清除先前的辨識文字和翻譯結果
      _recognizedText = '';
      _translatedText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('即時翻譯')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                DropdownButton<String>(
                  value: _sourceLanguage,
                  items:
                      <String>['中文', '日文'].map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _sourceLanguage = newValue;
                        _updateCurrentLocaleId();
                        // 切換來源語言時，清除先前的辨識文字和翻譯結果
                        _recognizedText = '';
                        _translatedText = '';
                      });
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: _swapLanguages,
                ),
                DropdownButton<String>(
                  value: _targetLanguage,
                  items:
                      <String>['中文', '日文'].map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _targetLanguage = newValue;
                        // 切換目標語言時，清除先前的辨識文字和翻譯結果
                        // 或者，如果希望保留辨識文字並重新翻譯，則調用 _translateText(_recognizedText);
                        // 目前根據要求，是清除掉
                        _recognizedText = '';
                        _translatedText = '';
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _isListening
                  ? '正在聆聽...'
                  : (_speechToText.isNotListening && _recognizedText.isEmpty
                      ? '按下方按鈕開始錄音'
                      : '辨識結果：'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              _recognizedText,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              _translatedText.isEmpty
                  ? ''
                  : '翻譯結果：', // Show label only if there's translated text
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              _translatedText,
              style: const TextStyle(fontSize: 16, color: Colors.blue),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: FloatingActionButton(
                onPressed: _toggleRecording,
                child: Icon(_isListening ? Icons.mic_off : Icons.mic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
