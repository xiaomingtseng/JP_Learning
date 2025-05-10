import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 匯入 Firebase Auth
import 'package:uuid/uuid.dart';
import '../models/note_models.dart';

class NoteService {
  final _uuid = Uuid();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth 實例
  static const String _groupsCollection = 'groups';

  // 輔助方法：獲取目前使用者 ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // 獲取目前使用者的所有群組
  Future<List<Group>> getAllGroups() async {
    final userId = getCurrentUserId();
    if (userId == null) {
      print('使用者未登入，無法獲取群組');
      return []; // 或者拋出錯誤
    }
    try {
      final snapshot =
          await _firestore
              .collection(_groupsCollection)
              .where('userId', isEqualTo: userId) // 根據 userId 篩選
              .get();
      return snapshot.docs.map((doc) => Group.fromJson(doc.data())).toList();
    } catch (e) {
      print('獲取使用者 $userId 的所有群組時發生錯誤: $e');
      return [];
    }
  }

  // 創建一個新的群組，並綁定到目前使用者
  Future<Group?> createGroup(String name) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      print('使用者未登入，無法建立群組');
      return null; // 或者拋出錯誤
    }

    final newGroupId = _uuid.v4();
    final newGroup = Group(
      id: newGroupId,
      name: name,
      userId: userId, // 設定 userId
      notebooks: [],
      // createdAt: DateTime.now(),
    );
    try {
      await _firestore
          .collection(_groupsCollection)
          .doc(newGroupId)
          .set(newGroup.toJson());
      return newGroup;
    } catch (e) {
      print('為使用者 $userId 創建群組 "$name" 時發生錯誤: $e');
      return null;
    }
  }

  // 根據 ID 尋找群組 (仍可保留，但要注意權限)
  // 如果需要嚴格限制只能存取自己的群組，此方法可能需要調整或僅供內部使用
  Future<Group?> findGroupById(String groupId) async {
    // 注意：此方法未直接檢查 userId，可能需要根據業務邏輯調整
    // 如果是從 getAllGroups 點擊進來的，通常是安全的
    // 但如果直接呼叫，需要確保 groupId 屬於目前使用者
    final userId = getCurrentUserId();
    if (userId == null) {
      print('使用者未登入');
      return null;
    }
    try {
      final doc =
          await _firestore.collection(_groupsCollection).doc(groupId).get();
      if (doc.exists) {
        final group = Group.fromJson(doc.data()!);
        // 額外檢查：確保這個群組屬於目前使用者
        if (group.userId == userId) {
          return group;
        } else {
          print('權限錯誤：使用者 $userId 無權存取群組 $groupId');
          return null;
        }
      }
      return null;
    } catch (e) {
      print('根據 ID 尋找群組時發生錯誤: $e');
      return null;
    }
  }

  // 在指定的群組中新增一個筆記本
  // (假設 group 物件已經是屬於目前使用者的)
  Future<Notebook?> addNotebookToGroup(
    String groupId,
    String notebookName,
  ) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      print('使用者未登入');
      return null;
    }

    final groupDocRef = _firestore.collection(_groupsCollection).doc(groupId);

    try {
      // 在更新前，可以再次驗證群組是否屬於目前使用者 (可選，取決於 findGroupById 的嚴謹程度)
      final groupSnapshot = await groupDocRef.get();
      if (!groupSnapshot.exists) {
        print('錯誤：找不到 ID 為 $groupId 的群組。');
        return null;
      }
      final groupData = Group.fromJson(groupSnapshot.data()!);
      if (groupData.userId != userId) {
        print('權限錯誤：使用者 $userId 無權修改群組 $groupId');
        return null;
      }

      final newNotebook = Notebook(
        id: _uuid.v4(),
        name: notebookName,
        // createdAt: DateTime.now(),
      );

      // 使用 FieldValue.arrayUnion 更安全地更新陣列
      await groupDocRef.update({
        'notebooks': FieldValue.arrayUnion([newNotebook.toJson()]),
      });
      // 注意：如果需要返回完整的 Notebook 物件，這裡可能需要重新讀取 group 或直接返回 newNotebook
      // 為了簡化，我們先返回 newNotebook。但 Firestore 的 arrayUnion 不會返回更新後的物件。
      // 最好的做法是重新讀取 group.notebooks 或直接在客戶端更新。
      // 這裡我們假設客戶端會重新載入群組資料。
      return newNotebook;
    } catch (e) {
      print('在群組 $groupId 中新增筆記本 "$notebookName" 時發生錯誤: $e');
      return null;
    }
  }

  // ... 其他方法 (例如刪除、更新) 也需要考慮 userId ...
}
