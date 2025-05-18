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
    final userEmail = _auth.currentUser?.email; // 獲取使用者 email

    if (userId == null || userEmail == null) {
      print('使用者未登入或 Email 為空，無法建立群組');
      return null; // 或者拋出錯誤
    }

    final newGroupId = _uuid.v4();
    final newGroup = Group(
      id: newGroupId,
      name: name,
      userId: userId, // 設定 userId
      owner: userEmail, // 設定 owner 為使用者 email
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

  // 根據 Notebook ID 獲取 Notebook 詳細資訊 (包含單字)
  Future<Notebook?> getNotebookById(String groupId, String notebookId) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      print('使用者未登入');
      return null;
    }
    try {
      final group = await findGroupById(
        groupId,
      ); // findGroupById 已經做了 userId 檢查
      if (group == null) {
        print('找不到群組 $groupId 或無權限');
        return null;
      }
      // 從群組的筆記本列表中尋找特定的筆記本
      final notebook = group.notebooks.firstWhere(
        (nb) => nb.id == notebookId,
        orElse: () {
          // 當找不到筆記本時，印出訊息並返回一個標記用的 Notebook 或 null
          // 這裡我們返回 null，讓呼叫者知道沒找到
          print('在群組 $groupId 中找不到筆記本 $notebookId');
          return Notebook(
            id: '',
            name: '',
          ); // 返回一個無效的 Notebook 以符合 firstWhere 的回傳型別要求，但下方會轉為 null
        },
      );
      // 如果 orElse 被觸發，notebook.id 會是 ''
      if (notebook.id == '') {
        return null;
      }
      return notebook;
    } catch (e) {
      print('獲取筆記本 $notebookId (群組 $groupId) 時發生錯誤: $e');
      return null;
    }
  }

  // 更新指定的筆記本 (例如新增單字後)
  Future<void> updateNotebook(String groupId, Notebook updatedNotebook) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      print('使用者未登入，無法更新筆記本');
      return; // 或者拋出錯誤
    }

    final groupDocRef = _firestore.collection(_groupsCollection).doc(groupId);

    try {
      final groupSnapshot = await groupDocRef.get();
      if (!groupSnapshot.exists) {
        print('錯誤：找不到 ID 為 $groupId 的群組。');
        return;
      }
      final group = Group.fromJson(groupSnapshot.data()!);
      if (group.userId != userId) {
        print('權限錯誤：使用者 $userId 無權修改群組 $groupId 中的筆記本');
        return;
      }

      // 更新 notebooks 列表
      final updatedNotebooks =
          group.notebooks.map((nb) {
            return nb.id == updatedNotebook.id ? updatedNotebook : nb;
          }).toList();

      await groupDocRef.update({
        'notebooks': updatedNotebooks.map((nb) => nb.toJson()).toList(),
      });
      print('筆記本 ${updatedNotebook.id} (群組 $groupId) 更新成功');
    } catch (e) {
      print('更新筆記本 ${updatedNotebook.id} (群組 $groupId) 時發生錯誤: $e');
    }
  }

  // ... 其他方法 (例如刪除、更新) 也需要考慮 userId ...
}
