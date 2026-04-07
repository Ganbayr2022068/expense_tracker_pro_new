import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/transaction.dart';

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<Txn>>(
  (ref) => TransactionsNotifier(),
);

class TransactionsNotifier extends StateNotifier<List<Txn>> {
  TransactionsNotifier() : super([]) {
    _listen();
  }

  final _uuid = const Uuid();

  CollectionReference get _col {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions');
  }

  void _listen() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      state = snapshot.docs.map((doc) {
        final data = doc.data();
        return Txn(
          id: data['id'],
          type: data['type'],
          amount: (data['amount'] as num).toDouble(),
          categoryId: data['categoryId'],
          date: (data['date'] as Timestamp).toDate(),
          note: data['note'],
          subCategoryId: data['subCategoryId'],
        );
      }).toList();
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
    final id = _uuid.v4();
    await _col.doc(id).set({
      'id': id,
      'type': type,
      'amount': amount,
      'categoryId': categoryId,
      'date': Timestamp.fromDate(date),
      'note': note,
      'subCategoryId': subCategoryId,
      'createdAt': FieldValue.serverTimestamp(),
    });
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
    await _col.doc(id).update({
      'type': type,
      'amount': amount,
      'categoryId': categoryId,
      'date': Timestamp.fromDate(date),
      'note': note,
      'subCategoryId': subCategoryId,
    });
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
}