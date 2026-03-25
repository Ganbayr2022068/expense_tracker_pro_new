import 'categories_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class AddCategoryScreen extends ConsumerStatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  ConsumerState<AddCategoryScreen> createState() =>
      _AddCategoryScreenState();
}

class _AddCategoryScreenState
    extends ConsumerState<AddCategoryScreen> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Category')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Category name',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_controller.text.isEmpty) return;

                await ref.read(categoriesProvider.notifier).addCategory(
                      name: _controller.text,
                      iconCodePoint: Icons.category.codePoint,
                    );

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }
}