import 'package:flutter/material.dart';
import '../models/category.dart';
import 'package:hive/hive.dart';

Future<void> seedCategories() async {
  final box = Hive.box<Category>(HiveBoxes.categories);

  // Хэрвээ аль хэдийн category байгаа бол дахиж үүсгэхгүй
  if (box.isNotEmpty) return;

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
    Category(id: '5', name: 'KFC', iconCodePoint: Icons.attach_money.codePoint,)
  ];

  for (final c in defaults) {
    await box.put(c.id, c);
  }
}
class HiveBoxes {
  static const String transactions = 'transactions_box';
  static const String categories = 'categories_box';
}

