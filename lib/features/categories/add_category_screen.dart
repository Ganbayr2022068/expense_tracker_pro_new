import 'package:expense_tracker_pro_new/data/models/category_type.dart';
import 'categories_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category.dart';

class AddCategoryScreen extends ConsumerStatefulWidget {
  final Category? existingCategory;
  const AddCategoryScreen({super.key, this.existingCategory});

  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {
  final _controller = TextEditingController();
  CategoryType _selectedType = CategoryType.expense;
  String _selectedEmoji = '📦';


  final List<String> _emojis = [
    '🍔','🚗','🛍️','🏠','💊','🎮','👗','📚','💅','🐾',
    '💰','📈','🎁','💻','🍕','✈️','🎵','🏋️','🎓','🛒',
    '💡','🔧','🎂','🏥','🎯','🎪','🌿','🐶','🐱','🚀',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.existingCategory != null) {
      _controller.text = widget.existingCategory!.name;
      _selectedType = widget.existingCategory!.type;
      _selectedEmoji = widget.existingCategory!.emoji;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingCategory != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Category' : 'Add Category'),
        actions: [

          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete Category'),
                    content: const Text('Are you sure?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref
                      .read(categoriesProvider.notifier)
                      .deleteCategory(widget.existingCategory!.id);
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Category name'),
            ),
            const SizedBox(height: 20),


            Row(
              children: [
                const Text('Type:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('Expense'),
                  selected: _selectedType == CategoryType.expense,
                  selectedColor: Colors.red.withOpacity(0.2),
                  onSelected: (_) => setState(() => _selectedType = CategoryType.expense),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Income'),
                  selected: _selectedType == CategoryType.income,
                  selectedColor: Colors.green.withOpacity(0.2),
                  onSelected: (_) => setState(() => _selectedType = CategoryType.income),
                ),
              ],
            ),
            const SizedBox(height: 20),


            Text(
              'Select Emoji:  $_selectedEmoji',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emojis.map((emoji) {
                final isSelected = emoji == _selectedEmoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = emoji),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.purple.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Colors.purple : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),


            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_controller.text.isEmpty) return;

                  if (isEditing) {
                    await ref.read(categoriesProvider.notifier).updateCategory(
                          id: widget.existingCategory!.id,
                          name: _controller.text,
                          type: _selectedType,
                          emoji: _selectedEmoji,
                        );
                  } else {
                    await ref.read(categoriesProvider.notifier).addCategory(
                          name: _controller.text,
                          type: _selectedType,
                          emoji: _selectedEmoji,
                        );
                  }

                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(isEditing ? 'Update' : 'Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}