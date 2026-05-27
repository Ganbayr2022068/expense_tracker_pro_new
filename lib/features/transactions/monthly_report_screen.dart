import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../categories/categories_provider.dart';
import 'transactions_provider.dart';
import '../../data/models/category_type.dart';
import '../../data/models/category.dart';
import '../../core/language_provider.dart';
import '../../core/app_strings.dart';
import '../../core/currency_provider.dart';

class MonthlyReportScreen extends ConsumerStatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  ConsumerState<MonthlyReportScreen> createState() =>
      _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends ConsumerState<MonthlyReportScreen> {
  DateTime _selectedMonth =
      DateTime(DateTime.now().year, DateTime.now().month);

  void _prevMonth() {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    if (_selectedMonth.year == now.year &&
        _selectedMonth.month == now.month) return;
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  String _monthName(int month, String lang) {
    const monthsEn = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const monthsMn = [
      '1-р сар', '2-р сар', '3-р сар', '4-р сар', '5-р сар', '6-р сар',
      '7-р сар', '8-р сар', '9-р сар', '10-р сар', '11-р сар', '12-р сар'
    ];
    return lang == 'mn' ? monthsMn[month - 1] : monthsEn[month - 1];
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
    final bgColor =
        isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF7F8FA);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? Colors.white38 : Colors.grey;
    final lang = ref.watch(languageProvider);
    final currency = ref.watch(currencyProvider);

    final monthTxns = transactions
        .where((t) =>
            t.date.year == _selectedMonth.year &&
            t.date.month == _selectedMonth.month)
        .toList();

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
        expenseMap[t.categoryId] =
            (expenseMap[t.categoryId] ?? 0) + t.amount;
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
    final isCurrentMonth = _selectedMonth.year == now.year &&
        _selectedMonth.month == now.month;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.get('monthly_report', lang),
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Month selector ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: textColor),
                    onPressed: _prevMonth,
                  ),
                  Text(
                    '${_monthName(_selectedMonth.month, lang)} ${_selectedMonth.year}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: isCurrentMonth
                          ? Colors.grey.withOpacity(0.2)
                          : textColor,
                    ),
                    onPressed: isCurrentMonth ? null : _nextMonth,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Stats row ──
            Row(
              children: [
                Expanded(
                  child: _modernStatCard(
                    label: AppStrings.get('income', lang),
                    amount: income,
                    color: const Color(0xFF43E97B),
                    bgColor: const Color(0xFF43E97B).withOpacity(0.1),
                    icon: Icons.arrow_upward_rounded,
                    currency: currency,
                    textColor: textColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _modernStatCard(
                    label: AppStrings.get('expense', lang),
                    amount: expense,
                    color: const Color(0xFFFF6584),
                    bgColor: const Color(0xFFFF6584).withOpacity(0.1),
                    icon: Icons.arrow_downward_rounded,
                    currency: currency,
                    textColor: textColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Balance card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: balance >= 0
                      ? [const Color(0xFF6C63FF), const Color(0xFF9B8FFF)]
                      : [Colors.red.shade700, Colors.red.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (balance >= 0
                            ? const Color(0xFF6C63FF)
                            : Colors.red)
                        .withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.get('net_balance', lang),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
  balance >= 0
      ? (lang == 'mn' ? '▲ Хэмнэлт' : '▲ Savings')
      : (lang == 'mn' ? '▼ Алдагдал' : '▼ Loss'),
  style: const TextStyle(color: Colors.white54, fontSize: 11),
),
                    ],
                  ),
                  Text(
                    '${balance >= 0 ? '+' : ''}$currency${_fmt(balance)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Daily Overview ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.get('daily_overview', lang),
                  style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                Row(
                  children: [
                    _legend(AppStrings.get('expense', lang),
                        const Color(0xFFFF6584)),
                    const SizedBox(width: 12),
                    _legend(AppStrings.get('income', lang),
                        const Color(0xFF43E97B)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              height: 200,
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: monthTxns.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bar_chart_outlined,
                              size: 36,
                              color: subColor.withOpacity(0.4)),
                          const SizedBox(height: 8),
                          Text(AppStrings.get('no_data', lang),
                              style:
                                  TextStyle(color: subColor, fontSize: 13)),
                        ],
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: [
                          ...dailyExpense.values,
                          ...dailyIncome.values,
                          1
                        ].reduce((a, b) => a > b ? a : b) *
                            1.3,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipRoundedRadius: 8,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '$currency${_fmt(rod.toY)}',
                                const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              );
                            },
                          ),
                        ),
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
                                final day = value.toInt();
                                if (day % 5 != 0 && day != 1) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    day.toString(),
                                    style: TextStyle(
                                        fontSize: 9, color: subColor),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: [
                            ...dailyExpense.values,
                            ...dailyIncome.values,
                            1
                          ].reduce((a, b) => a > b ? a : b) / 3,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey.withOpacity(0.08),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(
                          DateTime(_selectedMonth.year,
                                  _selectedMonth.month + 1, 0)
                              .day,
                          (i) {
                            final day = i + 1;
                            final hasData = (dailyExpense[day] ?? 0) > 0 ||
                                (dailyIncome[day] ?? 0) > 0;
                            return BarChartGroupData(
                              x: day,
                              barRods: [
                                BarChartRodData(
                                  toY: dailyExpense[day] ?? 0,
                                  color: hasData
                                      ? const Color(0xFFFF6584)
                                      : Colors.transparent,
                                  width: 4,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(3)),
                                ),
                                BarChartRodData(
                                  toY: dailyIncome[day] ?? 0,
                                  color: hasData
                                      ? const Color(0xFF43E97B)
                                      : Colors.transparent,
                                  width: 4,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(3)),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 28),

            // ── Expense by Category ──
            if (expenseMap.isNotEmpty) ...[
              Text(
                AppStrings.get('expense_by_category', lang),
                style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ...expenseMap.entries.toList().asMap().entries.map((entry) {
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
                final percent =
                    expense == 0 ? 0.0 : (e.value / expense * 100);
                final color = expenseColors[index % expenseColors.length];

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(category.emoji,
                                  style: const TextStyle(fontSize: 20)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              category.localizedName(lang),
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            '$currency${_fmt(e.value)}',
                            style: TextStyle(
                                color: subColor, fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${percent.toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: percent / 100),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) =>
                              LinearProgressIndicator(
                            value: value,
                            backgroundColor: color.withOpacity(0.1),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(color),
                            minHeight: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            // ── Empty state ──
            if (monthTxns.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 56,
                          color: subColor.withOpacity(0.3)),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.get('no_transactions', lang),
                        style: TextStyle(color: subColor, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _modernStatCard({
    required String label,
    required double amount,
    required Color color,
    required Color bgColor,
    required IconData icon,
    required String currency,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 14),
              ),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$currency${_fmt(amount)}',
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}