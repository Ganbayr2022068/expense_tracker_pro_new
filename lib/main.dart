import 'package:expense_tracker_pro_new/data/models/category_type.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app.dart';
import 'data/models/transaction.dart';
import 'data/models/category.dart';
import 'data/local/hive_boxes.dart';
import 'data/models/subcategory.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // ← нэмэх

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // ← нэмэх
  );

  Hive.registerAdapter(TxnAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(CategoryTypeAdapter());
  Hive.registerAdapter(SubCategoryAdapter());

  await Hive.openBox<Txn>(HiveBoxes.transactions);
  await Hive.openBox<Category>(HiveBoxes.categories);
  await seedCategories();
  await Hive.openBox<SubCategory>('subcategories');
  await Hive.openBox('settings');

  runApp(
    const ProviderScope(
      child: ExpenseTrackerApp(),
    ),
  );
}