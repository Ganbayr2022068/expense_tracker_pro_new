import 'package:expense_tracker_pro_new/features/transactions/monthly_report_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/currency_provider.dart';
import '../transactions/transactions_provider.dart';
import '../categories/categories_provider.dart';
import '../../data/models/category_type.dart';
import '../../data/models/category.dart';
import '../../core/language_provider.dart';
import '../../core/app_strings.dart';
import '../budget/budget_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currency = ref.watch(currencyProvider);
    final lang = ref.watch(languageProvider);
    final budgets = ref.watch(budgetProvider);

    double income = 0;
    double expense = 0;
    for (final t in transactions) {
      if (t.type == 'income') income += t.amount;
      else expense += t.amount;
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
      const Color(0xFF6C63FF), const Color(0xFFFF6584),
      const Color(0xFFFFBD59), const Color(0xFF43C6AC),
      const Color(0xFFFF6B6B), const Color(0xFF4ECDC4),
    ];
    final incomeColors = [
      const Color(0xFF43E97B), const Color(0xFF38F9D7),
      const Color(0xFF96FBC4), const Color(0xFF43C6AC),
      const Color(0xFF84FAB0), const Color(0xFF00CDAC),
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
          AppStrings.get('dashboard', lang),
          style: TextStyle(
            color: textColor, fontSize: 24,
            fontWeight: FontWeight.w700, letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MonthlyReportScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.4),
                    blurRadius: 20, offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.get('total_balance', lang),
                      style: const TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  Text('$currency${_formatAmount(balance)}',
                      style: const TextStyle(
                        color: Colors.white, fontSize: 32,
                        fontWeight: FontWeight.w800, letterSpacing: -1,
                      )),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _miniStat('↑ ${AppStrings.get('income', lang)}', income, const Color(0xFF43E97B), currency),
                      const SizedBox(width: 24),
                      _miniStat('↓ ${AppStrings.get('expense', lang)}', expense, const Color(0xFFFF6584), currency),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Text(AppStrings.get('analytics', lang),
                style: TextStyle(
                  color: textColor, fontSize: 18,
                  fontWeight: FontWeight.w700, letterSpacing: -0.3,
                )),
            const SizedBox(height: 12),

            SizedBox(
              height: 420,
              child: PageView(
                children: [
                  _chartCard(
                    title: AppStrings.get('expenses', lang),
                    emoji: '🔴',
                    isEmpty: expenseMap.isEmpty,
                    emptyMsg: AppStrings.get('no_expense', lang),
                    cardColor: cardColor,
                    textColor: textColor,
                    subColor: subColor,
                    isExpense: true,
                    child: _buildPieChart(
                      dataMap: expenseMap, total: totalExpense,
                      colors: expenseColors, categories: categories,
                      currency: currency, lang: lang,
                    ),
                  ),
                  _chartCard(
                    title: AppStrings.get('income', lang),
                    emoji: '🟢',
                    isEmpty: incomeMap.isEmpty,
                    emptyMsg: AppStrings.get('no_income', lang),
                    cardColor: cardColor,
                    textColor: textColor,
                    subColor: subColor,
                    isExpense: false,
                    child: _buildPieChart(
                      dataMap: incomeMap, total: totalIncome,
                      colors: incomeColors, categories: categories,
                      currency: currency, lang: lang,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),
            Center(
              child: Text(AppStrings.get('swipe_income', lang),
                  style: TextStyle(fontSize: 11, color: subColor)),
            ),

            const SizedBox(height: 32),
            if (budgets.isNotEmpty) ...[
  Text(
    AppStrings.get('monthly_budget', lang),
    style: TextStyle(
      color: textColor, fontSize: 18,
      fontWeight: FontWeight.w700, letterSpacing: -0.3,
    ),
  ),
  const SizedBox(height: 12),
  ...budgets.entries.map((entry) {
    final category = categories.firstWhere(
      (c) => c.id == entry.key,
      orElse: () => Category(
        id: '0', name: 'Unknown', emoji: '📦',
        type: CategoryType.expense,
      ),
    );
    final budgetAmount = entry.value;
    final spent = expenseMap[entry.key] ?? 0;
    final percent = budgetAmount == 0 ? 0.0 : (spent / budgetAmount);
    final isOver = percent >= 1.0;
    final progressColor = isOver
        ? Colors.red
        : percent > 0.8
            ? Colors.orange
            : const Color(0xFF6C63FF);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isOver
            ? Border.all(color: Colors.red.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.localizedName(lang),
                  style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
              ),
              if (isOver)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppStrings.get('over_budget', lang),
                    style: const TextStyle(
                        color: Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              backgroundColor: progressColor.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currency${_formatAmount(spent)} ${AppStrings.get('budget_used', lang)}',
                style: TextStyle(
                    color: progressColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
              Text(
                '$currency${_formatAmount(budgetAmount)}',
                style: TextStyle(color: subColor, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }),
  const SizedBox(height: 20),
],
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, double amount, Color color, String currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 2),
        Text('$currency${_formatAmount(amount)}',
            style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w700)),
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
    required bool isExpense,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isExpense
                  ? const Color(0xFF6C63FF).withOpacity(0.12)
                  : const Color(0xFF43E97B).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 5),
                Text(title,
                    style: TextStyle(
                      color: isExpense
                          ? const Color(0xFF6C63FF)
                          : const Color(0xFF1D9E75),
                      fontSize: 13, fontWeight: FontWeight.w700,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: isEmpty
                ? Center(child: Text(emptyMsg,
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
    required String lang,
  }) {
    final entries = dataMap.entries.toList();

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        centerSpaceRadius: 38,
                        sectionsSpace: 4,
                        sections: entries.asMap().entries.map((entry) {
                          final index = entry.key;
                          final e = entry.value;
                          return PieChartSectionData(
                            value: e.value,
                            color: colors[index % colors.length],
                            title: '',
                            radius: 30,
                          );
                        }).toList(),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(AppStrings.get('total', lang),
                            style: const TextStyle(
                              fontSize: 9, color: Colors.grey, letterSpacing: 0.5,
                            )),
                        Text('$currency${_formatAmount(total)}',
                            style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: -0.5,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Legend + progress bars
        ...entries.asMap().entries.map((entry) {
          final index = entry.key;
          final e = entry.value;
          final category = categories.firstWhere(
            (c) => c.id == e.key,
            orElse: () => Category(
              id: '0', name: 'Unknown', emoji: '📦',
              type: CategoryType.expense,
            ),
          );
          final percent = total == 0 ? 0.0 : (e.value / total * 100);
          final color = colors[index % colors.length];

          return Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                Container(
                  width: 7, height: 7,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${category.emoji} ${category.localizedName(lang)}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 60, height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: percent / 100,
                      backgroundColor: color.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 28,
                  child: Text(
                    '${percent.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w600, color: color,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }
}