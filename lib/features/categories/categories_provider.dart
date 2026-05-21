import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/category.dart';
import '../../data/models/category_type.dart';
import '../../data/services/firestore_service.dart';
import '../transactions/transactions_provider.dart';

final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, List<Category>>((ref) {
  return CategoriesNotifier(ref.read(firestoreServiceProvider));
});

class CategoriesNotifier extends StateNotifier<List<Category>> {
  CategoriesNotifier(this._service) : super([]) {
    _listen();
  }

  final FirestoreService _service;

  void _listen() {
    _service.categoriesStream().listen((cats) async {
      if (cats.isEmpty) {
        await _seedDefaultCategories();
      } else {
        state = cats;
      }
    });
  }

  Future<void> _seedDefaultCategories() async {
    final defaults = [
      Category(id: '1',  name: 'Food',          nameMn: 'Хоол',              type: CategoryType.expense, emoji: '🍔'),
      Category(id: '2',  name: 'Transport',     nameMn: 'Тээвэр',            type: CategoryType.expense, emoji: '🚗'),
      Category(id: '3',  name: 'Shopping',      nameMn: 'Дэлгүүр',           type: CategoryType.expense, emoji: '🛍️'),
      Category(id: '4',  name: 'Rent',          nameMn: 'Түрээс',            type: CategoryType.expense, emoji: '🏠'),
      Category(id: '5',  name: 'Health',        nameMn: 'Эрүүл мэнд',        type: CategoryType.expense, emoji: '💊'),
      Category(id: '6',  name: 'Entertainment', nameMn: 'Цэнгэл',            type: CategoryType.expense, emoji: '🎮'),
      Category(id: '7',  name: 'Clothing',      nameMn: 'Хувцас',            type: CategoryType.expense, emoji: '👗'),
      Category(id: '8',  name: 'Education',     nameMn: 'Боловсрол',         type: CategoryType.expense, emoji: '📚'),
      Category(id: '9',  name: 'Beauty',        nameMn: 'Гоо сайхан',        type: CategoryType.expense, emoji: '💅'),
      Category(id: '10', name: 'Pet',           nameMn: 'Тэжээвэр амьтан',   type: CategoryType.expense, emoji: '🐾'),
      Category(id: '11', name: 'Salary',        nameMn: 'Цалин',             type: CategoryType.income,  emoji: '💰'),
      Category(id: '12', name: 'Investment',    nameMn: 'Хөрөнгө оруулалт',  type: CategoryType.income,  emoji: '📈'),
      Category(id: '13', name: 'Gift',          nameMn: 'Бэлэг',             type: CategoryType.income,  emoji: '🎁'),
      Category(id: '14', name: 'Freelance',     nameMn: 'Фриланс',           type: CategoryType.income,  emoji: '💻'),
      Category(id: '15', name: 'Rental Income', nameMn: 'Түрээсийн орлого',  type: CategoryType.income,  emoji: '🏠'),
    ];
    for (final c in defaults) {
      await _service.addCategory(
        id: c.id,
        name: c.name,
        nameMn: c.nameMn,
        emoji: c.emoji,
        type: c.type,
      );
    }
  }

  Future<void> addCategory({
    required String name,
    String? nameMn,
    required CategoryType type,
    required String emoji,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _service.addCategory(id: id, name: name, nameMn: nameMn, emoji: emoji, type: type);
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    String? nameMn,
    required CategoryType type,
    required String emoji,
  }) async {
    await _service.updateCategory(id: id, name: name, nameMn: nameMn, emoji: emoji, type: type);
  }

  Future<void> deleteCategory(String id) async {
    await _service.deleteCategory(id);
  }
}