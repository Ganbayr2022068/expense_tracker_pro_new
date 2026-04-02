import 'package:expense_tracker_pro_new/data/models/category_type.dart';
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
      emoji: '🍔',
      type: CategoryType.expense,
    ),
    Category(
      id: '2',
      name: 'Transport',
      emoji: '🚌 ',
      type: CategoryType.expense,
    ),
    Category(
      id: '3',
      name: 'Shopping',
      emoji: '🛍️ ',
      type: CategoryType.expense,
    ),
    Category(
      id: '4',
      name: 'Salary',
      emoji: '💸',
      type: CategoryType.income,
    ),
  ];

  for (final c in defaults) {
    await box.put(c.id, c);
  }
}
class HiveBoxes {
  static const String transactions = 'transactions_box';
  static const String categories = 'categories_box';
}

