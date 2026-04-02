import 'package:expense_tracker_pro_new/data/models/category_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../categories/categories_provider.dart';
import '../categories/subcategory_provider.dart'; // ← нэмэх
import 'transactions_provider.dart';
import 'add_transaction_screen.dart';
import '../../data/models/category.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  Category getCategory(List<Category> categories, String id) {
    return categories.firstWhere(
      (c) => c.id == id,
      orElse: () => Category(
        id: '0',
        name: 'Unknown',
        emoji: '📦',
        type: CategoryType.expense,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider);
    final subcategories = ref.watch(subcategoryProvider); // ← нэмэх

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: transactions.isEmpty
          ? const Center(child: Text('No transactions yet'))
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final t = transactions[index];
                final category = getCategory(categories, t.categoryId);
                final isIncome = category.type == CategoryType.income;

                // ← subcategory олох
                final sub = t.subCategoryId != null
                    ? subcategories.where((s) => s.id == t.subCategoryId).firstOrNull
                    : null;

                return ListTile(
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddTransactionScreen(existingTxn: t),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: isIncome
                        ? Colors.green.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15),
                    child: Text(
                      category.emoji, // emoji
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  title: Text(
                    '${isIncome ? '+' : '-'}₮${t.amount}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                  subtitle: Text(
                    sub != null
                        ? '${category.name}  ›  ${sub.name}' // ← Category › Subcategory
                        : category.name,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () async {
                      await ref.read(transactionsProvider.notifier).delete(t.id);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}