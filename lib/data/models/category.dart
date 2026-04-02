import 'package:hive/hive.dart';
import 'category_type.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class Category {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String emoji; // 🔥 NEW

  @HiveField(3)
  final CategoryType type; // 🔥 NEW

  Category({
    required this.id,
    required this.name,
    required this.emoji,
    required this.type,
  });
}