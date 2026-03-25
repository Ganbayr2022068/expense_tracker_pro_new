import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../categories/categories_provider.dart';
import 'transactions_provider.dart';
import 'add_transaction_screen.dart';
import '../../data/models/category.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  // ✅ Category lookup function
  Category getCategory(List<Category> categories, String id) {
    return categories.firstWhere(
      (c) => c.id == id,
      orElse: () => Category(
        id: '0',
        name: 'Unknown',
        iconCodePoint: Icons.help.codePoint,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider); // ✅ ADD

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: transactions.isEmpty
          ? const Center(
              child: Text('No transactions yet'),
            )
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final t = transactions[index];

                final isIncome = t.type == 'income';

                // ✅ MOVE HERE (correct place)
                final category = getCategory(categories, t.categoryId);

                return ListTile(
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddTransactionScreen(existingTxn: t),
                     ),
                   );
                 },
                 leading: Icon(
                 IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
                 size: 28,
                  ),
                  title: Text(
                    '₮${t.amount}',
                     style: TextStyle(
                     fontSize: 18,
                     fontWeight: FontWeight.bold,
                     color: isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                  // ✅ CATEGORY NAME
                  subtitle: Text(
                     category.name,
                  style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await ref
                          .read(transactionsProvider.notifier)
                          .delete(t.id);
                    },
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}