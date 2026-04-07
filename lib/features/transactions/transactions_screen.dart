import 'package:expense_tracker_pro_new/data/models/category_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/currency_provider.dart';
import '../categories/categories_provider.dart';
import '../categories/subcategory_provider.dart';
import 'transactions_provider.dart';
import 'add_transaction_screen.dart';
import '../../data/models/category.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterType = 'all'; // all, income, expense

  Category getCategory(List<Category> categories, String id) {
    return categories.firstWhere(
      (c) => c.id == id,
      orElse: () => Category(
        id: '0', name: 'Unknown', emoji: '📦', type: CategoryType.expense,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider);
    final subcategories = ref.watch(subcategoryProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF7F8FA);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final currency = ref.watch(currencyProvider); 

    // 🔍 Filter хийх
    final filtered = transactions.where((t) {
      final category = getCategory(categories, t.categoryId);

      // Type filter
      if (_filterType == 'income' && t.type != 'income') return false;
      if (_filterType == 'expense' && t.type != 'expense') return false;

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final categoryMatch = category.name.toLowerCase().contains(query);
        final amountMatch = t.amount.toString().contains(query);
        final noteMatch = t.note?.toLowerCase().contains(query) ?? false;
        if (!categoryMatch && !amountMatch && !noteMatch) return false;
      }

      return true;
    }).toList();

    // 📊 Summary
    double totalIncome = 0;
    double totalExpense = 0;
    for (final t in filtered) {
      if (t.type == 'income') {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
      }
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          'Transactions',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [

                // 🔍 Search bar
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search transactions...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : Colors.grey,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              }),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // 🔘 Filter chips
                Row(
                  children: [
                    _filterChip('All', 'all', Colors.purple),
                    const SizedBox(width: 8),
                    _filterChip('Income', 'income', Colors.green),
                    const SizedBox(width: 8),
                    _filterChip('Expense', 'expense', Colors.red),
                    const Spacer(),
                    Text(
                      '${filtered.length} items',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Colors.grey,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // 📊 Summary row
                if (filtered.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _summaryItem('↑ Income',
                            '$currency${_fmt(totalIncome)}', Colors.green),
                        Container(
                            width: 1, height: 30,
                            color: isDark ? Colors.white12 : Colors.grey.shade200),
                        _summaryItem('↓ Expense',
                            '$currency${_fmt(totalExpense)}', Colors.red),
                        Container(
                            width: 1, height: 30,
                            color: isDark ? Colors.white12 : Colors.grey.shade200),
                        _summaryItem(
                          'Balance',
                          '$currency${_fmt(totalIncome - totalExpense)}',
                          (totalIncome - totalExpense) >= 0
                              ? Colors.blue
                              : Colors.orange,
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 10),
              ],
            ),
          ),

          // 📋 Transaction list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 48,
                            color: isDark ? Colors.white24 : Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No results for "$_searchQuery"'
                              : 'No transactions yet',
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final t = filtered[index];
                      final category = getCategory(categories, t.categoryId);
                      final isIncome = category.type == CategoryType.income;
                      final sub = t.subCategoryId != null
                          ? subcategories
                              .where((s) => s.id == t.subCategoryId)
                              .firstOrNull
                          : null;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddTransactionScreen(existingTxn: t),
                              ),
                            );
                          },
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isIncome
                                  ? Colors.green.withOpacity(0.12)
                                  : Colors.red.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                category.emoji,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                          title: Text(
                            sub != null
                                ? '${category.name} › ${sub.name}'
                                : category.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                            ),
                          ),
                          subtitle: Text(
                            '${t.date.year}/${t.date.month.toString().padLeft(2, '0')}/${t.date.day.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white38 : Colors.grey,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${isIncome ? '+' : '-'}$currency${_fmt(t.amount)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isIncome ? Colors.green : Colors.red,
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: Icon(Icons.delete_outline,
                                    color: isDark
                                        ? Colors.white24
                                        : Colors.grey.shade400,
                                    size: 20),
                                onPressed: () async {
                                  await ref
                                      .read(transactionsProvider.notifier)
                                      .delete(t.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
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

  // 🔘 Filter chip
  Widget _filterChip(String label, String value, Color color) {
    final isSelected = _filterType == value;
    return GestureDetector(
      onTap: () => setState(() => _filterType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? color : Colors.grey,
          ),
        ),
      ),
    );
  }

  // 📊 Summary item
  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }

  // 🔢 Format
  String _fmt(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }
}