import 'package:expense_tracker_pro_new/data/models/category_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/models/category.dart';
import '../../data/local/hive_boxes.dart';

final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, List<Category>>((ref) {
  return CategoriesNotifier();
});

class CategoriesNotifier extends StateNotifier<List<Category>> {
  CategoriesNotifier() : super([]) {
    _init();
  }

  final _box = Hive.box<Category>(HiveBoxes.categories);

  Future<void> _init() async {
    await _box.clear();
      await _seedDefaultCategories();
    _load();
  }


  void _load() {
    state = _box.values.toList();
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
    await _box.put(c.id, c);
  }
}


  Future<void> addCategory({
  required String name,
  required CategoryType type,
  required String emoji,
}) async {
  final id = DateTime.now().millisecondsSinceEpoch.toString();

  final newCategory = Category(
    id: id,
    name: name,
    type: type,
    emoji: emoji,
  );

  await _box.put(id, newCategory);
  _load();
}

Future<void> deleteCategory(String id) async {
  await _box.delete(id);
  _load();
}


Future<void> updateCategory({
  required String id,
  required String name,
  required CategoryType type,
  required String emoji,
}) async {
  final updated = Category(id: id, name: name, type: type, emoji: emoji);
  await _box.put(id, updated);
  _load();
}


}