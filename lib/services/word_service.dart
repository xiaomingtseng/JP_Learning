import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

class Word {
  final String word;
  final String phonetic;
  final String mean;

  Word({required this.word, required this.phonetic, required this.mean});

  Map<String, dynamic> toJson() {
    return {'word': word, 'phonetic': phonetic, 'mean': mean};
  }

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      word: json['word'],
      phonetic: json['phonetic'],
      mean: json['mean'],
    );
  }
}

class WordService {
  Future<List<Word>> loadWords(String assetPath) async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((jsonItem) => Word.fromJson(jsonItem)).toList();
    } catch (e) {
      print('Error loading words from $assetPath: $e');
      return [];
    }
  }

  Future<void> addWord(String assetPath, Word newWord) async {
    try {
      List<Word> words = await loadWords(assetPath);

      // Check if the word already exists to avoid conflicts
      bool wordExists = words.any((word) => word.word == newWord.word);
      if (wordExists) {
        print(
          'Word "${newWord.word}" already exists in $assetPath. Skipping addition.',
        );
        return;
      }

      words.add(newWord);
      await _saveWords(assetPath, words);
      print('Word "${newWord.word}" added to $assetPath successfully.');
    } catch (e) {
      print('Error adding word to $assetPath: $e');
    }
  }

  Future<void> _saveWords(String assetPath, List<Word> words) async {
    try {
      // Note: Writing directly to assets at runtime is not straightforward in Flutter.
      // This implementation assumes you have a mechanism to write back to the asset file,
      // which is typically not possible for bundled assets after the app is built.
      // For development or specific scenarios, you might write to a file in the app's documents directory instead.
      // For this example, we'll simulate the behavior by printing.
      // In a real application, you would need a different approach for persistent storage,
      // such as a database or writing to a file in a writable directory.

      // If you are running this in a Dart script outside of Flutter (e.g., a CLI tool for managing assets),
      // then writing to the file system directly would work.
      final String jsonString = json.encode(
        words.map((word) => word.toJson()).toList(),
      );

      // This part is problematic for bundled assets in a running Flutter app.
      // final File file = File(assetPath); // This path will be read-only.
      // await file.writeAsString(jsonString);

      print('Simulating save for $assetPath:');
      print(jsonString);
      // In a real app, you'd use path_provider to get a writable directory:
      // final directory = await getApplicationDocumentsDirectory();
      // final file = File('${directory.path}/${assetPath.split('/').last}');
      // await file.writeAsString(jsonString);
      // print('Words saved to ${file.path}');
    } catch (e) {
      print('Error saving words to $assetPath: $e');
    }
  }
}
