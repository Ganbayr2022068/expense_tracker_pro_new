import 'package:expense_tracker_pro_new/features/transactions/monthly_report_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/currency_provider.dart';
import '../transactions/transactions_provider.dart';
import '../categories/categories_provider.dart';
import '../../data/models/category_type.dart';
import '../../data/models/category.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currency = ref.watch(currencyProvider);

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

    final Map<String, double> expenseMap = {};
    for (final t in transactions) {
      if (t.type == 'expense') {
        expenseMap[t.categoryId] = (expenseMap[t.categoryId] ?? 0) + t.amount;
      }
    }

    final Map<String, double> incomeMap = {};
    for (final t in transactions) {
      if (t.type == 'income') {
        incomeMap[t.categoryId] = (incomeMap[t.categoryId] ?? 0) + t.amount;
      }
    }

    final totalExpense = expenseMap.values.fold(0.0, (a, b) => a + b);
    final totalIncome = incomeMap.values.fold(0.0, (a, b) => a + b);

    final expenseColors = [
      const Color(0xFF6C63FF),
      const Color(0xFFFF6584),
      const Color(0xFFFFBD59),
      const Color(0xFF43C6AC),
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
    ];
    final incomeColors = [
      const Color(0xFF43E97B),
      const Color(0xFF38F9D7),
      const Color(0xFF96FBC4),
      const Color(0xFF43C6AC),
      const Color(0xFF84FAB0),
      const Color(0xFF00CDAC),
    ];

    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF7F8FA);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? Colors.white38 : const Color(0xFF8E8E93);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
       actions: [
    IconButton(
      icon: const Icon(Icons.bar_chart),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const MonthlyReportScreen(),
        ),
      ),
    ),
  ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$currency${_formatAmount(balance)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _miniStat('↑ Income', income, const Color(0xFF43E97B),currency),
                      const SizedBox(width: 24),
                      _miniStat('↓ Expense', expense, const Color(0xFFFF6584), currency),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),


            Text(
              'Analytics',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 320,
              child: PageView(
                children: [
                  _chartCard(
                    title: 'Expenses',
                    emoji: '🔴',
                    isEmpty: expenseMap.isEmpty,
                    emptyMsg: 'No expense data yet',
                    cardColor: cardColor,
                    textColor: textColor,
                    subColor: subColor,
                    child: _buildPieChart(
                      dataMap: expenseMap,
                      total: totalExpense,
                      colors: expenseColors,
                      categories: categories,
                      currency: currency,
                    ),
                  ),
                  _chartCard(
                    title: 'Income',
                    emoji: '🟢',
                    isEmpty: incomeMap.isEmpty,
                    emptyMsg: 'No income data yet',
                    cardColor: cardColor,
                    textColor: textColor,
                    subColor: subColor,
                    child: _buildPieChart(
                      dataMap: incomeMap,
                      total: totalIncome,
                      colors: incomeColors,
                      categories: categories,
                      currency: currency,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),
            Center(
              child: Text(
                'Swipe for Income →',
                style: TextStyle(fontSize: 11, color: subColor),
              ),
            ),

            const SizedBox(height: 28),


            if (expenseMap.isNotEmpty) ...[
              Text(
                'Expense Breakdown',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _buildLegend(
                    expenseMap, totalExpense, expenseColors, categories,
                    textColor: textColor, subColor: subColor, currency: currency,),
              ),
            ],

            if (incomeMap.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Income Breakdown',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _buildLegend(
                    incomeMap, totalIncome, incomeColors, categories,
                    textColor: textColor, subColor: subColor, currency: currency,),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }


  Widget _miniStat(String label, double amount, Color color, String currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          '$currency${_formatAmount(amount)}',
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }


  Widget _chartCard({
    required String title,
    required String emoji,
    required bool isEmpty,
    required String emptyMsg,
    required Color cardColor,
    required Color textColor,
    required Color subColor,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: isEmpty
                ? Center(
                    child: Text(emptyMsg,
                        style: TextStyle(color: subColor, fontSize: 13)))
                : child,
          ),
        ],
      ),
    );
  }


  Widget _buildPieChart({
  required Map<String, double> dataMap,
  required double total,
  required List<Color> colors,
  required List<Category> categories,
  required String currency,
}) {
  return Stack(
    alignment: Alignment.center,
    children: [
      PieChart(
        PieChartData(
          centerSpaceRadius: 55,
          sectionsSpace: 2,
          sections: dataMap.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final e = entry.value;
            final category = categories.firstWhere(
              (c) => c.id == e.key,
              orElse: () => Category(
                  id: '0',
                  name: 'Unknown',
                  emoji: '📦',
                  type: CategoryType.expense),
            );
            final percent = total == 0 ? 0.0 : (e.value / total * 100);
            return PieChartSectionData(
              value: e.value,
              color: colors[index % colors.length],
              title: '${category.emoji}\n${percent.toStringAsFixed(0)}%',
              radius: 65,
              titleStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),


      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Total',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$currency${_formatAmount(total)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    ],
  );
}

  Widget _buildLegend(
    Map<String, double> dataMap,
    double total,
    List<Color> colors,
    List<Category> categories, {
    required Color textColor,
    required Color subColor,
    required String currency,
  }) {
    final entries = dataMap.entries.toList();
    return Column(
      children: entries.asMap().entries.map((entry) {
        final index = entry.key;
        final e = entry.value;
        final category = categories.firstWhere(
          (c) => c.id == e.key,
          orElse: () => Category(
              id: '0',
              name: 'Unknown',
              emoji: '📦',
              type: CategoryType.expense),
        );
        final percent = total == 0 ? 0.0 : (e.value / total * 100);
        final color = colors[index % colors.length];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${category.emoji} ${category.name}',
                style: TextStyle(color: textColor, fontSize: 14),
              ),
              const Spacer(),
              Text(
                '$currency${_formatAmount(e.value)}',
                style: TextStyle(color: subColor, fontSize: 12),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${percent.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }


  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}