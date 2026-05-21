import 'package:hive/hive.dart';

part 'subcategory.g.dart';

@HiveType(typeId: 3)
class SubCategory {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String parentId;

  @HiveField(3)
  final String? nameMn; 

  SubCategory({
    required this.id,
    required this.name,
    required this.parentId,
    this.nameMn,
  });
  
   String localizedName(String lang) {
    if (lang == 'mn' && nameMn != null && nameMn!.isNotEmpty) {
      return nameMn!;
    }
    return name;
  }
}