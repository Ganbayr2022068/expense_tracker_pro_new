import 'package:expense_tracker_pro_new/data/models/category_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../categories/subcategory_provider.dart';
import 'transactions_provider.dart';
import '../categories/categories_provider.dart';
import '../categories/add_category_screen.dart';
import '../../data/models/transaction.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final Txn? existingTxn;
  const AddTransactionScreen({super.key, this.existingTxn});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _formatter = NumberFormat('#,###', 'en_US');
  final _dateFormatter = DateFormat('yyyy/MM/dd');

  String _type = 'expense';
  String? selectedCategoryId;
  String? selectedSubCategoryId;
  DateTime _selectedDate = DateTime.now(); // ← огноо

  @override
  void initState() {
    super.initState();
    if (widget.existingTxn != null) {
      final t = widget.existingTxn!;
      _amountController.text = _formatter.format(t.amount.toInt());
      _noteController.text = t.note ?? '';
      _type = t.type;
      selectedCategoryId = t.categoryId;
      selectedSubCategoryId = t.subCategoryId;
      _selectedDate = t.date; // ← хуучин огноо
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // 📅 Огноо сонгох
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6C63FF),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final filteredCategories = categories.where((c) {
      return (_type == 'expense' && c.type == CategoryType.expense) ||
          (_type == 'income' && c.type == CategoryType.income);
    }).toList();

    final subcategories = ref.watch(subcategoryProvider);
    final filteredSub = subcategories
        .where((s) => s.parentId == selectedCategoryId)
        .toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF7F8FA);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? Colors.white38 : Colors.grey;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          widget.existingTxn == null ? 'Add Transaction' : 'Edit Transaction',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 🔄 Type selector
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _type = 'expense';
                          selectedCategoryId = null;
                          selectedSubCategoryId = null;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _type == 'expense'
                                ? Colors.red.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: _type == 'expense'
                                ? Border.all(color: Colors.red.withOpacity(0.5))
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '↓ Expense',
                              style: TextStyle(
                                color: _type == 'expense'
                                    ? Colors.red
                                    : subColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _type = 'income';
                          selectedCategoryId = null;
                          selectedSubCategoryId = null;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _type == 'income'
                                ? Colors.green.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: _type == 'income'
                                ? Border.all(color: Colors.green.withOpacity(0.5))
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '↑ Income',
                              style: TextStyle(
                                color: _type == 'income'
                                    ? Colors.green
                                    : subColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 💰 Amount
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: TextStyle(color: subColor),
                    suffixText: '₮',
                    suffixStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6C63FF),
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    final clean = value.replaceAll(',', '');
                    final number = int.tryParse(clean);
                    if (number != null) {
                      final formatted = _formatter.format(number);
                      if (formatted != value) {
                        _amountController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(
                              offset: formatted.length),
                        );
                      }
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter amount';
                    final clean = value.replaceAll(',', '');
                    final number = double.tryParse(clean);
                    if (number == null || number <= 0) return 'Invalid amount';
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 12),

              // 📅 Огноо сонгогч
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 18, color: Color(0xFF6C63FF)),
                      const SizedBox(width: 12),
                      Text(
                        _dateFormatter.format(_selectedDate),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right, color: subColor, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 🏷️ Category
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  dropdownColor: cardColor,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(color: subColor),
                    border: InputBorder.none,
                  ),
                  hint: Text('Select Category',
                      style: TextStyle(color: subColor)),
                  items: filteredCategories.map((c) {
                    return DropdownMenuItem<String>(
                      value: c.id,
                      child: Text('${c.emoji} ${c.name}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = value;
                      selectedSubCategoryId = null;
                    });
                  },
                  validator: (value) {
                    if (value == null) return 'Select category';
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 12),

              // 🏷️ Subcategory
              if (filteredSub.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedSubCategoryId,
                    dropdownColor: cardColor,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Subcategory',
                      labelStyle: TextStyle(color: subColor),
                      border: InputBorder.none,
                    ),
                    hint: Text('Select Subcategory',
                        style: TextStyle(color: subColor)),
                    items: filteredSub.map((s) {
                      return DropdownMenuItem<String>(
                        value: s.id,
                        child: Text(s.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedSubCategoryId = value);
                    },
                  ),
                ),

              const SizedBox(height: 12),

              // 📝 Note
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _noteController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Note (optional)',
                    labelStyle: TextStyle(color: subColor),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.note_outlined, color: subColor),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ➕ Add Category
              TextButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const AddCategoryScreen()),
                  );
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Category'),
              ),

              const SizedBox(height: 24),

              // 💾 Save
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    if (!mounted) return;

                    final notifier = ref.read(transactionsProvider.notifier);
                    final amount = double.parse(
                        _amountController.text.replaceAll(',', ''));

                    if (widget.existingTxn == null) {
                      await notifier.add(
                        type: _type,
                        amount: amount,
                        categoryId: selectedCategoryId!,
                        subCategoryId: selectedSubCategoryId,
                        date: _selectedDate, // ← сонгосон огноо
                        note: _noteController.text.isEmpty
                            ? null
                            : _noteController.text,
                      );
                    } else {
                      await notifier.update(
                        id: widget.existingTxn!.id,
                        type: _type,
                        amount: amount,
                        categoryId: selectedCategoryId!,
                        subCategoryId: selectedSubCategoryId,
                        date: _selectedDate, // ← сонгосон огноо
                        note: _noteController.text.isEmpty
                            ? null
                            : _noteController.text,
                      );
                    }

                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(
                    widget.existingTxn == null ? 'Save' : 'Update',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}