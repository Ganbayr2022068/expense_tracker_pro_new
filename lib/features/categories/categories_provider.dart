import 'package:flutter/material.dart';
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

  // 🔥 INIT
  Future<void> _init() async {
    if (_box.isEmpty) {
      await _seedDefaultCategories();
    }
    _load();
  }

  // 🔥 LOAD
  void _load() {
    state = _box.values.toList();
  }

  // 🔥 DEFAULT CATEGORY
  Future<void> _seedDefaultCategories() async {
    final defaults = [
      Category(
        id: '1',
        name: 'Food',
        iconCodePoint: Icons.fastfood.codePoint,
      ),
      Category(
        id: '2',
        name: 'Transport',
        iconCodePoint: Icons.directions_car.codePoint,
      ),
      Category(
        id: '3',
        name: 'Shopping',
        iconCodePoint: Icons.shopping_bag.codePoint,
      ),
      Category(
        id: '4',
        name: 'Salary',
        iconCodePoint: Icons.attach_money.codePoint,
      ),
    ];

    for (final c in defaults) {
      await _box.put(c.id, c);
    }
  }

  // ➕ ADD CATEGORY
  Future<void> addCategory({
    required String name,
    required int iconCodePoint,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final newCategory = Category(
      id: id,
      name: name,
      iconCodePoint: iconCodePoint,
    );

    await _box.put(id, newCategory);
    _load();
  }
}