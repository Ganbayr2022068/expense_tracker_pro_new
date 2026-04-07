import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../categories/categories_provider.dart';
import 'transactions_provider.dart';
import '../../data/models/category_type.dart';
import '../../data/models/category.dart';

class MonthlyReportScreen extends ConsumerStatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  ConsumerState<MonthlyReportScreen> createState() =>
      _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends ConsumerState<MonthlyReportScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  void _prevMonth() {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    if (_selectedMonth.year == now.year && _selectedMonth.month == now.month) return;
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _fmt(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF7F8FA);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? Colors.white38 : Colors.grey;


    final monthTxns = transactions.where((t) =>
        t.date.year == _selectedMonth.year &&
        t.date.month == _selectedMonth.month).toList();

    double income = 0;
    double expense = 0;
    for (final t in monthTxns) {
      if (t.type == 'income') income += t.amount;
      else expense += t.amount;
    }
    final balance = income - expense;


    final Map<String, double> expenseMap = {};
    for (final t in monthTxns) {
      if (t.type == 'expense') {
        expenseMap[t.categoryId] = (expenseMap[t.categoryId] ?? 0) + t.amount;
      }
    }


    final Map<int, double> dailyExpense = {};
    final Map<int, double> dailyIncome = {};
    for (final t in monthTxns) {
      final day = t.date.day;
      if (t.type == 'expense') {
        dailyExpense[day] = (dailyExpense[day] ?? 0) + t.amount;
      } else {
        dailyIncome[day] = (dailyIncome[day] ?? 0) + t.amount;
      }
    }

    final expenseColors = [
      const Color(0xFF6C63FF), const Color(0xFFFF6584),
      const Color(0xFFFFBD59), const Color(0xFF43C6AC),
      const Color(0xFFFF6B6B), const Color(0xFF4ECDC4),
    ];

    final now = DateTime.now();
    final isCurrentMonth =
        _selectedMonth.year == now.year && _selectedMonth.month == now.month;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text('Monthly Report',
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            )),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _prevMonth,
                  ),
                  Text(
                    '${_monthName(_selectedMonth.month)} ${_selectedMonth.year}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right,
                        color: isCurrentMonth ? Colors.grey.withOpacity(0.3) : null),
                    onPressed: isCurrentMonth ? null : _nextMonth,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),


            Row(
              children: [
                Expanded(child: _statCard('Income', income, Colors.green,
                    Icons.arrow_upward, cardColor, textColor)),
                const SizedBox(width: 12),
                Expanded(child: _statCard('Expense', expense, Colors.red,
                    Icons.arrow_downward, cardColor, textColor)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: balance >= 0
                    ? const Color(0xFF6C63FF)
                    : Colors.red.shade700,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Net Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Text(
                    '${balance >= 0 ? '+' : ''}₮${_fmt(balance)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),


            Text('Daily Overview',
                style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: monthTxns.isEmpty
                  ? Center(child: Text('No data', style: TextStyle(color: subColor)))
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: [...dailyExpense.values, ...dailyIncome.values, 1]
                            .reduce((a, b) => a > b ? a : b) * 1.2,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                      fontSize: 9, color: subColor),
                                );
                              },
                            ),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(
                          DateTime(_selectedMonth.year,
                                  _selectedMonth.month + 1, 0)
                              .day,
                          (i) {
                            final day = i + 1;
                            return BarChartGroupData(
                              x: day,
                              barRods: [
                                BarChartRodData(
                                  toY: dailyExpense[day] ?? 0,
                                  color: const Color(0xFFFF6584),
                                  width: 4,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                BarChartRodData(
                                  toY: dailyIncome[day] ?? 0,
                                  color: const Color(0xFF43E97B),
                                  width: 4,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legend('Expense', const Color(0xFFFF6584)),
                const SizedBox(width: 16),
                _legend('Income', const Color(0xFF43E97B)),
              ],
            ),

            const SizedBox(height: 24),


            if (expenseMap.isNotEmpty) ...[
              Text('Expense by Category',
                  style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: expenseMap.entries.toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final e = entry.value;
                    final category = categories.firstWhere(
                      (c) => c.id == e.key,
                      orElse: () => Category(
                          id: '0', name: 'Unknown', emoji: '📦',
                          type: CategoryType.expense),
                    );
                    final percent = expense == 0 ? 0.0 : (e.value / expense * 100);
                    final color = expenseColors[index % expenseColors.length];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(category.emoji,
                                  style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(category.name,
                                    style: TextStyle(
                                        color: textColor, fontSize: 14)),
                              ),
                              Text('₮${_fmt(e.value)}',
                                  style: TextStyle(
                                      color: subColor, fontSize: 12)),
                              const SizedBox(width: 8),
                              Text('${percent.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                      color: color,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 6),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percent / 100,
                              backgroundColor:
                                  color.withOpacity(0.1),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(color),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, double amount, Color color,
      IconData icon, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(title,
                  style: TextStyle(color: color, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text('₮${_fmt(amount)}',
              style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _legend(String label, Color color) {
    return Row(
      children: [
        Container(
            width: 10, height: 10,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}