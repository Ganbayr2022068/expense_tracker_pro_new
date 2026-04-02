import 'package:hive/hive.dart';

part 'subcategory.g.dart'; // 🔥 заавал

@HiveType(typeId: 3)
class SubCategory {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String parentId;

  SubCategory({
    required this.id,
    required this.name,
    required this.parentId,
  });
}