import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app.dart';
import 'data/models/transaction.dart';
import 'data/models/category.dart';
import 'data/local/hive_boxes.dart';
import 'data/models/subcategory.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // ✅ Adapter register
  Hive.registerAdapter(TxnAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(SubCategoryAdapter());

  // ✅ Box open
  await Hive.openBox<Txn>(HiveBoxes.transactions);
  await Hive.openBox<Category>(HiveBoxes.categories);
  await seedCategories();
  await Hive.openBox<SubCategory>('subcategories');
  // ✅ ЗӨВ: ProviderScope дотор runApp
  runApp(
    const ProviderScope(
      child: ExpenseTrackerApp(),
    ),
  );
}