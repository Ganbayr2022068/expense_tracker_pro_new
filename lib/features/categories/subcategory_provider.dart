import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/models/subcategory.dart';

final subcategoryProvider =
    StateNotifierProvider<SubCategoryNotifier, List<SubCategory>>(
  (ref) => SubCategoryNotifier(),
);

class SubCategoryNotifier extends StateNotifier<List<SubCategory>> {
  SubCategoryNotifier() : super([]) {
    _init();
  }

  final _box = Hive.box<SubCategory>('subcategories');

  Future<void> _init() async {
    if (_box.isEmpty) {
      await _seedDefaultSubcategories();
    }
    _load();
  }

  void _load() {
    state = _box.values.toList();
  }

  Future<void> _seedDefaultSubcategories() async {
    final defaults = [
      SubCategory(id: '1', name: 'Restaurant', parentId: '1'),
      SubCategory(id: '2', name: 'Fast Food', parentId: '1'),
      SubCategory(id: '3', name: 'Coffee', parentId: '1'),

      SubCategory(id: '4', name: 'Taxi', parentId: '2'),
      SubCategory(id: '5', name: 'Bus', parentId: '2'),
      SubCategory(id: '6', name: 'Metro', parentId: '2'),
    ];

    for (final s in defaults) {
      await _box.put(s.id, s);
    }
  }

  Future<void> addSubCategory({
    required String name,
    required String parentId,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final sub = SubCategory(
      id: id,
      name: name,
      parentId: parentId,
    );

    await _box.put(id, sub);
    _load();
  }
}