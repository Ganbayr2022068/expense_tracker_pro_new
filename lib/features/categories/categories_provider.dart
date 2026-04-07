import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/category.dart';
import '../../data/models/category_type.dart';

final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, List<Category>>((ref) {
  return CategoriesNotifier();
});

class CategoriesNotifier extends StateNotifier<List<Category>> {
  CategoriesNotifier() : super([]) {
    _listen();
  }

  CollectionReference get _col {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('categories');
  }

void _listen() {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;
  
  FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('categories')
      .snapshots()
      .listen((snapshot) async {

    final validDocs = snapshot.docs.where((doc) => doc.exists).toList();
    
    if (validDocs.isEmpty) {
      await _seedDefaultCategories();
    } else {
      state = validDocs.map((doc) {
        final data = doc.data();
        return Category(
          id: data['id'],
          name: data['name'],
          emoji: data['emoji'],
          type: data['type'] == 'income'
              ? CategoryType.income
              : CategoryType.expense,
        );
      }).toList();
    }
  });
}

  Future<void> _seedDefaultCategories() async {
    final defaults = [
      Category(id: '1',  name: 'Food',          type: CategoryType.expense, emoji: '🍔'),
      Category(id: '2',  name: 'Transport',      type: CategoryType.expense, emoji: '🚗'),
      Category(id: '3',  name: 'Shopping',       type: CategoryType.expense, emoji: '🛍️'),
      Category(id: '4',  name: 'Rent',           type: CategoryType.expense, emoji: '🏠'),
      Category(id: '5',  name: 'Health',         type: CategoryType.expense, emoji: '💊'),
      Category(id: '6',  name: 'Entertainment',  type: CategoryType.expense, emoji: '🎮'),
      Category(id: '7',  name: 'Clothing',       type: CategoryType.expense, emoji: '👗'),
      Category(id: '8',  name: 'Education',      type: CategoryType.expense, emoji: '📚'),
      Category(id: '9',  name: 'Beauty',         type: CategoryType.expense, emoji: '💅'),
      Category(id: '10', name: 'Pet',            type: CategoryType.expense, emoji: '🐾'),
      Category(id: '11', name: 'Salary',         type: CategoryType.income,  emoji: '💰'),
      Category(id: '12', name: 'Investment',     type: CategoryType.income,  emoji: '📈'),
      Category(id: '13', name: 'Gift',           type: CategoryType.income,  emoji: '🎁'),
      Category(id: '14', name: 'Freelance',      type: CategoryType.income,  emoji: '💻'),
      Category(id: '15', name: 'Rental Income',  type: CategoryType.income,  emoji: '🏠'),
    ];
    for (final c in defaults) {
      await _col.doc(c.id).set({
        'id': c.id,
        'name': c.name,
        'emoji': c.emoji,
        'type': c.type == CategoryType.income ? 'income' : 'expense',
      });
    }
  }

  Future<void> addCategory({
    required String name,
    required CategoryType type,
    required String emoji,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _col.doc(id).set({
      'id': id,
      'name': name,
      'emoji': emoji,
      'type': type == CategoryType.income ? 'income' : 'expense',
    });
  }

  Future<void> deleteCategory(String id) async {
    await _col.doc(id).delete();
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    required CategoryType type,
    required String emoji,
  }) async {
    await _col.doc(id).update({
      'name': name,
      'emoji': emoji,
      'type': type == CategoryType.income ? 'income' : 'expense',
    });
  }
}