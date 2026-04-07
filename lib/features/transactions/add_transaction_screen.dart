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
  final _formatter = NumberFormat('#,###', 'en_US');

  String _type = 'expense';
  String? selectedCategoryId;
  String? selectedSubCategoryId;

  @override
  void initState() {
    super.initState();
    if (widget.existingTxn != null) {
      final t = widget.existingTxn!;
      _amountController.text = _formatter.format(t.amount.toInt()); // ← форматтай
      _type = t.type;
      selectedCategoryId = t.categoryId;
      selectedSubCategoryId = t.subCategoryId;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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

    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'expense', child: Text('Expense')),
                  DropdownMenuItem(value: 'income', child: Text('Income')),
                ],
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                    selectedCategoryId = null;
                    selectedSubCategoryId = null;
                  });
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  suffixText: '₮',
                  suffixStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onChanged: (value) {
                  final clean = value.replaceAll(',', '');
                  final number = int.tryParse(clean);
                  if (number != null) {
                    final formatted = _formatter.format(number);
                    if (formatted != value) {
                      _amountController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
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

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedCategoryId,
                hint: const Text('Select Category'),
                items: filteredCategories.map((c) {
                  return DropdownMenuItem<String>(
                    value: c.id,
                    child: Text(c.name),
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

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedSubCategoryId,
                hint: const Text('Select Subcategory'),
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

              const SizedBox(height: 8),

              TextButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
                  );
                },
                child: const Text('+ Add Category'),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
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
                      date: DateTime.now(),
                    );
                  } else {
                    await notifier.update(
                      id: widget.existingTxn!.id,
                      type: _type,
                      amount: amount,
                      categoryId: selectedCategoryId!,
                      subCategoryId: selectedSubCategoryId,
                      date: widget.existingTxn!.date,
                    );
                  }

                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}