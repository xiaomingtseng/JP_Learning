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
        _updateCurrentLocaleId(); // Initialize with default or selected language
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
      _stopListening().then((_) => _startListening());
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
    _recognizedText = ''; // Clear previous recognized text
    _translatedText = ''; // Clear previous translated text
    _speechToText.listen(
      onResult: (result) => _onSpeechResult(result.recognizedWords),
      localeId: _currentLocaleId,
    );
    setState(() {
      _isListening = true;
    });
  }

  Future<void> _stopListening() async {
    if (!_speechToText.isListening) return;
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _onSpeechResult(String text) {
    print("Recognized words: $text");
    setState(() {
      _recognizedText = text;
    });
    if (!_isListening) {
      // Translate only when listening has stopped (final result)
      _translateText(text);
    }
  }

  void _onSttStatus(String status) {
    print("STT Status: $status");
    if (mounted) {
      setState(() {
        _isListening = _speechToText.isListening;
      });
    }
    // If status is 'notListening' and there's recognized text, trigger translation
    if (status == SpeechToText.notListeningStatus &&
        _recognizedText.isNotEmpty) {
      _translateText(_recognizedText);
    }
  }

  void _onSttError(error) {
    // Parameter type changed to dynamic or a specific error type if available
    print("STT Error: $error");
    if (mounted) {
      setState(() {
        _isListening = false;
        _recognizedText = "語音辨識錯誤";
        _translatedText = "";
      });
    }
  }

  Future<void> _translateText(String text) async {
    if (text.isEmpty) {
      setState(() {
        _translatedText = '';
      });
      return;
    }
    try {
      final sourceLang = _sourceLanguage == '中文' ? 'zh-cn' : 'ja';
      final targetLang = _targetLanguage == '中文' ? 'zh-cn' : 'ja';

      if (sourceLang == targetLang) {
        setState(() {
          _translatedText =
              text; // No translation needed if languages are the same
        });
        return;
      }

      var translation = await _translator.translate(
        text,
        from: sourceLang,
        to: targetLang,
      );
      setState(() {
        _translatedText = translation.text;
      });
    } catch (e) {
      setState(() {
        _translatedText = '翻譯錯誤: $e';
      });
      print("Translation Error: $e");
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
      // Retranslate the text if there is any recognized text
      if (_recognizedText.isNotEmpty) {
        _translateText(_recognizedText);
      } else {
        _translatedText = ''; // Clear translated text if no recognized text
      }
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
                        if (_recognizedText.isNotEmpty) {
                          // Retranslate if text exists
                          _translateText(_recognizedText);
                        } else {
                          _translatedText = '';
                        }
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
                        if (_recognizedText.isNotEmpty) {
                          // Retranslate if text exists
                          _translateText(_recognizedText);
                        } else {
                          _translatedText = '';
                        }
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
