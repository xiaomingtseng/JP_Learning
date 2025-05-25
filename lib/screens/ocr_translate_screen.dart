import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:translator/translator.dart';

class OcrTranslateScreen extends StatefulWidget {
  const OcrTranslateScreen({super.key});

  @override
  State<OcrTranslateScreen> createState() => _OcrTranslateScreenState();
}

class _OcrTranslateScreenState extends State<OcrTranslateScreen> {
  String? _imagePath;
  String? _detectedText;
  String? _translatedText;
  bool _isLoading = false;

  Future<void> _pickAndProcessImage() async {
    setState(() {
      _isLoading = true;
      _imagePath = null;
      _detectedText = null;
      _translatedText = null;
    });

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    ); // 或 ImageSource.camera

    if (image == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('沒有選擇圖片')));
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _imagePath = image.path;
    });

    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer(
      script: TextRecognitionScript.japanese,
    );

    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      await textRecognizer.close();
      String detected = recognizedText.text;
      setState(() {
        _detectedText = detected.isEmpty ? '在圖片中沒有偵測到文字' : detected;
      });

      if (detected.isNotEmpty) {
        final translator = GoogleTranslator();
        var translation = await translator.translate(
          detected,
          from: 'ja',
          to: 'zh-tw',
        );
        setState(() {
          _translatedText = translation.text;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _detectedText = '文字辨識失敗: $e';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('OCR 或翻譯時發生錯誤: $e')));
      print("OCR/Translation error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('圖片日文翻譯 (OCR)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_imagePath != null && !_isLoading)
              Column(
                children: [
                  const Text(
                    '選擇的圖片:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Image.file(File(_imagePath!), height: 200),
                  const SizedBox(height: 16),
                ],
              ),
            ElevatedButton.icon(
              icon: const Icon(Icons.image_search),
              label: const Text('選擇圖片並辨識翻譯'),
              onPressed: _isLoading ? null : _pickAndProcessImage,
            ),
            const SizedBox(height: 20),
            if (_detectedText != null && !_isLoading)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '偵測到的日文:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 5),
                      SelectableText(
                        _detectedText!,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 10),
            if (_translatedText != null && !_isLoading)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '翻譯結果 (繁中):',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 5),
                      SelectableText(
                        _translatedText!,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
