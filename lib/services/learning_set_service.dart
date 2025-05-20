import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/learning_set.dart';
import '../models/kotoba.dart'; // Assuming Kotoba model is needed for KotobaService
import './kotoba_service.dart'; // Assuming KotobaService is in the same directory or path is correct

class LearningSetService {
  final KotobaService _kotobaService = KotobaService();

  Future<List<LearningSet>> fetchJLPTLearningSetsFromAssets() async {
    final List<Map<String, dynamic>> jlptLevels = [
      {
        'id': 'jlpt_n1_vocab',
        'title': 'JLPT N1 單字集',
        'color': Colors.blue,
        'assetPath': 'assets/kotoba/n1.json',
      },
      {
        'id': 'jlpt_n2_vocab',
        'title': 'JLPT N2 單字集',
        'color': Colors.green,
        'assetPath': 'assets/kotoba/n2.json',
      },
      {
        'id': 'jlpt_n3_vocab',
        'title': 'JLPT N3 單字集',
        'color': Colors.orange,
        'assetPath': 'assets/kotoba/n3.json',
      },
      {
        'id': 'jlpt_n4_vocab',
        'title': 'JLPT N4 單字集',
        'color': Colors.red,
        'assetPath': 'assets/kotoba/n4.json',
      },
      {
        'id': 'jlpt_n5_vocab',
        'title': 'JLPT N5 單字集',
        'color': Colors.purple,
        'assetPath': 'assets/kotoba/n5.json',
      },
    ];

    List<LearningSet> learningSets = [];

    for (var levelData in jlptLevels) {
      try {
        List<Kotoba> kotobaList = await _kotobaService.fetchKotobaFromAssets(
          levelData['assetPath'],
        );
        learningSets.add(
          LearningSet(
            id: levelData['id'],
            title: levelData['title'],
            category: 'JLPT',
            color: levelData['color'],
            itemCount: kotobaList.length,
            // description and author can be added if available or set to default
          ),
        );
      } catch (e) {
        // Handle error, e.g., if a JSON file is missing or malformed
        print('Error loading JLPT set ${levelData['id']}: $e');
        // Optionally add a LearningSet with itemCount 0 or skip
        learningSets.add(
          LearningSet(
            id: levelData['id'],
            title: levelData['title'],
            category: 'JLPT',
            color: levelData['color'],
            itemCount: 0,
            description: '資料載入失敗',
          ),
        );
      }
    }
    return learningSets;
  }

  Future<List<LearningSet>> fetchFirebaseLearningSets() async {
    // TODO: Implement fetching data from Firebase Firestore
    // This will involve:
    // 1. Initializing Firebase (if not already done).
    // 2. Getting a reference to your 'learning_sets' collection.
    // 3. Fetching the documents.
    // 4. Mapping each document to a LearningSet object.
    // Remember to handle potential errors.
    print('Fetching from Firebase is not yet implemented.');
    return []; // Return an empty list for now
  }

  Future<List<LearningSet>> fetchAllLearningSets() async {
    List<LearningSet> jlptSets = await fetchJLPTLearningSetsFromAssets();
    List<LearningSet> firebaseSets = await fetchFirebaseLearningSets();

    // Combine the lists. You might want to add logic to prevent duplicates
    // if a JLPT set could somehow also be in Firebase, though unlikely with current setup.
    List<LearningSet> allSets = [];
    allSets.addAll(jlptSets);
    allSets.addAll(firebaseSets);

    return allSets;
  }
}
