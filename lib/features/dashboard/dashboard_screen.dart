import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../transactions/transactions_provider.dart';
import '../categories/categories_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider);

    double income = 0;
    double expense = 0;

    for (final t in transactions) {
      if (t.type == 'income') {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    final balance = income - expense;

    final Map<String, double> dataMap = {};

    for (final t in transactions) {
      if (t.type == 'expense') {
        dataMap[t.categoryId] = (dataMap[t.categoryId] ?? 0) + t.amount;
      }
    }

    final totalExpense = dataMap.values.fold(0.0, (a, b) => a + b);

    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _card('Balance', balance, Colors.blue),
              const SizedBox(height: 12),
              _card('Income', income, Colors.green),
              const SizedBox(height: 12),
              _card('Expense', expense, Colors.red),
              const SizedBox(height: 20),

              const Text(
                'Expenses by Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // 🔥 PIE CHART
              SizedBox(
                height: 250,
                child: dataMap.isEmpty
                    ? const Center(child: Text('No expense data'))
                    : PieChart(
                        PieChartData(
                          centerSpaceRadius: 40,
                          sections: dataMap.entries
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final e = entry.value;

                            final category = categories.firstWhere(
                              (c) => c.id == e.key,
                              orElse: () => categories.first,
                            );

                            final percent = totalExpense == 0
                                ? 0.0
                                : (e.value / totalExpense * 100);

                            return PieChartSectionData(
                              value: e.value,
                              color: colors[index % colors.length],
                              title: '${category.emoji}\n${percent.toStringAsFixed(0)}%', // ✅ ЗАСАВ
                              radius: 70,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              // 🔥 LEGEND
              Column(
                children: dataMap.entries
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final e = entry.value;

                  final category = categories.firstWhere(
                    (c) => c.id == e.key,
                    orElse: () => categories.first,
                  );

                  final percent = totalExpense == 0
                      ? 0.0
                      : (e.value / totalExpense * 100);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              color: colors[index % colors.length],
                            ),
                            const SizedBox(width: 8),
                            Text('${category.emoji} ${category.name}'), // ✅ ЗАСАВ
                          ],
                        ),
                        Text('${percent.toStringAsFixed(0)}%'),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(String title, double amount, Color color) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          '₮${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}