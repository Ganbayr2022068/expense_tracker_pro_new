import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final budgetProvider =
    StateNotifierProvider<BudgetNotifier, Map<String, double>>(
  (ref) => BudgetNotifier(),
);

class BudgetNotifier extends StateNotifier<Map<String, double>> {
  BudgetNotifier() : super({}) {
    _listen();
  }

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get _budgets => FirebaseFirestore.instance
      .collection('users')
      .doc(_uid)
      .collection('budgets');

  void _listen() {
    _budgets.snapshots().listen((snapshot) {
      final map = <String, double>{};
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        map[data['categoryId']] = (data['amount'] as num).toDouble();
      }
      state = map;
    });
  }

  Future<void> setBudget(String categoryId, double amount) async {
    await _budgets.doc(categoryId).set({
      'categoryId': categoryId,
      'amount': amount,
    });
  }

  Future<void> deleteBudget(String categoryId) async {
    await _budgets.doc(categoryId).delete();
  }
}