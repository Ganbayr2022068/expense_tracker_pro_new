import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Txn {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String categoryId;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String? note;

  Txn({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.note,
  });
}