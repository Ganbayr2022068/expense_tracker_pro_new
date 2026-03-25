import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/transaction.dart';
import '../../data/local/hive_boxes.dart';

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<Txn>>(
  (ref) => TransactionsNotifier(),
);

class TransactionsNotifier extends StateNotifier<List<Txn>> {
  TransactionsNotifier() : super([]) {
    _load();
  }

  Box<Txn> get _box => Hive.box<Txn>(HiveBoxes.transactions);
  final _uuid = const Uuid();

  void _load() {
    final items = _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    state = items;
  }

  // ✅ ADD
  Future<void> add({
    required String type,
    required double amount,
    required String categoryId,
    required DateTime date,
    String? note,
  }) async {
    final txn = Txn(
      id: _uuid.v4(),
      type: type,
      amount: amount,
      categoryId: categoryId,
      date: date,
      note: note,
    );

    await _box.put(txn.id, txn);
    _load();
  }

  // ✅ DELETE
  Future<void> delete(String id) async {
    await _box.delete(id);
    _load();
  }

  // ✅ UPDATE
  Future<void> update({
    required String id,
    required String type,
    required double amount,
    required String categoryId,
    required DateTime date,
    String? note,
  }) async {
    final updated = Txn(
      id: id,
      type: type,
      amount: amount,
      categoryId: categoryId,
      date: date,
      note: note,
    );

    await _box.put(id, updated);
    _load();
  }
}