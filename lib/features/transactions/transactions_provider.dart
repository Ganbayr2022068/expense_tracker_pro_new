import 'package:firebase_auth/firebase_auth.dart'; // ← нэмэх
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/transaction.dart';
import '../../data/services/firestore_service.dart';

final firestoreServiceProvider = Provider((ref) => FirestoreService());

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<Txn>>(
  (ref) {
    ref.watch(authStateProvider); // ← user өөрчлөгдөхөд дахин үүснэ
    return TransactionsNotifier(ref.read(firestoreServiceProvider));
  },
);

class TransactionsNotifier extends StateNotifier<List<Txn>> {
  TransactionsNotifier(this._service) : super([]) {
    _listen();
  }

  final FirestoreService _service;
  final _uuid = const Uuid();

  void _listen() {
    _service.transactionsStream().listen((txns) {
      if (mounted) state = txns;
    });
  }

  Future<void> add({
    required String type,
    required double amount,
    required String categoryId,
    required DateTime date,
    String? note,
    String? subCategoryId,
  }) async {
    await _service.addTransaction(
      id: _uuid.v4(),
      type: type,
      amount: amount,
      categoryId: categoryId,
      date: date,
      note: note,
      subCategoryId: subCategoryId,
    );
  }

  Future<void> update({
    required String id,
    required String type,
    required double amount,
    required String categoryId,
    required DateTime date,
    String? note,
    String? subCategoryId,
  }) async {
    await _service.updateTransaction(
      id: id,
      type: type,
      amount: amount,
      categoryId: categoryId,
      date: date,
      note: note,
      subCategoryId: subCategoryId,
    );
  }

  Future<void> delete(String id) async {
    await _service.deleteTransaction(id);
  }
}