import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 檢查使用者是否存在
  Future<bool> checkUserExists(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists;
    } catch (e) {
      print('檢查使用者是否存在時發生錯誤: $e');
      return false;
    }
  }

  // 創建使用者資料
  Future<void> createUserProfile({
    required String userId,
    required String name,
    required String email,
    required String avatarUrl,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'likedArticlesCount': 0,
        'likedNewsCount': 0,
        'learnedWordsCount': 0,
        'learnedKanjiCount': 0,
        'consecutiveLoginDays': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('創建使用者資料時發生錯誤: $e');
      rethrow;
    }
  }

  // 更新使用者資料
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updatedData,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        ...updatedData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('更新使用者資料時發生錯誤: $e');
      rethrow;
    }
  }

  // 讀取使用者資料
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('讀取使用者資料時發生錯誤: $e');
      rethrow;
    }
  }
}
