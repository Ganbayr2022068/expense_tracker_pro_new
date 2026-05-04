import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/transaction.dart';
import '../models/category.dart';
import '../models/subcategory.dart';
import '../models/category_type.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // ═══════════════════════════
  // 📁 Collections
  // ═══════════════════════════
  CollectionReference get _transactions =>
      _db.collection('users').doc(_uid).collection('transactions');

  CollectionReference get _categories =>
      _db.collection('users').doc(_uid).collection('categories');

  CollectionReference get _subcategories =>
      _db.collection('users').doc(_uid).collection('subcategories');

  // ═══════════════════════════
  // 💸 TRANSACTIONS
  // ═══════════════════════════

  Stream<List<Txn>> transactionsStream() {
    return _transactions.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Txn(
          id: data['id'],
          type: data['type'],
          amount: (data['amount'] as num).toDouble(),
          categoryId: data['categoryId'],
          date: (data['date'] as Timestamp).toDate(),
          note: data['note'],
          subCategoryId: data['subCategoryId'],
        );
      }).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  Future<void> addTransaction({
    required String id,
    required String type,
    required double amount,
    required String categoryId,
    required DateTime date,
    String? note,
    String? subCategoryId,
  }) async {
    await _transactions.doc(id).set({
      'id': id,
      'type': type,
      'amount': amount,
      'categoryId': categoryId,
      'date': Timestamp.fromDate(date),
      'note': note,
      'subCategoryId': subCategoryId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTransaction({
    required String id,
    required String type,
    required double amount,
    required String categoryId,
    required DateTime date,
    String? note,
    String? subCategoryId,
  }) async {
    await _transactions.doc(id).update({
      'type': type,
      'amount': amount,
      'categoryId': categoryId,
      'date': Timestamp.fromDate(date),
      'note': note,
      'subCategoryId': subCategoryId,
    });
  }

  Future<void> deleteTransaction(String id) async {
    await _transactions.doc(id).delete();
  }

  // ═══════════════════════════
  // 🏷️ CATEGORIES
  // ═══════════════════════════

  Stream<List<Category>> categoriesStream() {
    return _categories.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Category(
          id: data['id'],
          name: data['name'],
          emoji: data['emoji'],
          type: data['type'] == 'income'
              ? CategoryType.income
              : CategoryType.expense,
        );
      }).toList();
    });
  }

  Future<void> addCategory({
    required String id,
    required String name,
    required String emoji,
    required CategoryType type,
  }) async {
    await _categories.doc(id).set({
      'id': id,
      'name': name,
      'emoji': emoji,
      'type': type == CategoryType.income ? 'income' : 'expense',
    });
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    required String emoji,
    required CategoryType type,
  }) async {
    await _categories.doc(id).update({
      'name': name,
      'emoji': emoji,
      'type': type == CategoryType.income ? 'income' : 'expense',
    });
  }

  Future<void> deleteCategory(String id) async {
    await _categories.doc(id).delete();
  }

  // ═══════════════════════════
  // 📂 SUBCATEGORIES
  // ═══════════════════════════

  Stream<List<SubCategory>> subcategoriesStream() {
    return _subcategories.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return SubCategory(
          id: data['id'],
          name: data['name'],
          parentId: data['parentId'],
        );
      }).toList();
    });
  }

  Future<void> addSubCategory({
    required String id,
    required String name,
    required String parentId,
  }) async {
    await _subcategories.doc(id).set({
      'id': id,
      'name': name,
      'parentId': parentId,
    });
  }

  // ═══════════════════════════
  // 🗑️ CLEAR ALL DATA
  // ═══════════════════════════

  Future<void> clearAllData() async {
    final txns = await _transactions.get();
    for (final doc in txns.docs) await doc.reference.delete();

    final cats = await _categories.get();
    for (final doc in cats.docs) await doc.reference.delete();

    final subs = await _subcategories.get();
    for (final doc in subs.docs) await doc.reference.delete();
  }
}