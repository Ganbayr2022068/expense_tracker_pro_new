import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/subcategory.dart';
import '../../data/services/firestore_service.dart';
import '../transactions/transactions_provider.dart';

final subcategoryProvider =
    StateNotifierProvider<SubCategoryNotifier, List<SubCategory>>(
  (ref) => SubCategoryNotifier(ref.read(firestoreServiceProvider)),
);

class SubCategoryNotifier extends StateNotifier<List<SubCategory>> {
  SubCategoryNotifier(this._service) : super([]) {
    _listen();
  }

  final FirestoreService _service;

  void _listen() {
    _service.subcategoriesStream().listen((subs) async {
      if (subs.isEmpty) {
        await _seedDefaultSubcategories();
      } else {
        state = subs;
      }
    });
  }

  Future<void> _seedDefaultSubcategories() async {
    final defaults = [
      SubCategory(id: 's1',  name: 'Restaurant',    parentId: '1'),
      SubCategory(id: 's2',  name: 'Fast Food',      parentId: '1'),
      SubCategory(id: 's3',  name: 'Coffee',         parentId: '1'),
      SubCategory(id: 's4',  name: 'Grocery',        parentId: '1'),
      SubCategory(id: 's5',  name: 'Street Food',    parentId: '1'),
      SubCategory(id: 's6',  name: 'Taxi',           parentId: '2'),
      SubCategory(id: 's7',  name: 'Bus',            parentId: '2'),
      SubCategory(id: 's8',  name: 'Metro',          parentId: '2'),
      SubCategory(id: 's9',  name: 'Fuel',           parentId: '2'),
      SubCategory(id: 's10', name: 'Car Repair',     parentId: '2'),
      SubCategory(id: 's11', name: 'Clothing',       parentId: '3'),
      SubCategory(id: 's12', name: 'Electronics',    parentId: '3'),
      SubCategory(id: 's13', name: 'Home Supplies',  parentId: '3'),
      SubCategory(id: 's14', name: 'Apartment',      parentId: '4'),
      SubCategory(id: 's15', name: 'Utilities',      parentId: '4'),
      SubCategory(id: 's16', name: 'Internet',       parentId: '4'),
      SubCategory(id: 's17', name: 'Pharmacy',       parentId: '5'),
      SubCategory(id: 's18', name: 'Doctor Visit',   parentId: '5'),
      SubCategory(id: 's19', name: 'Cinema',         parentId: '6'),
      SubCategory(id: 's20', name: 'Gaming',         parentId: '6'),
      SubCategory(id: 's21', name: 'Base Salary',    parentId: '11'),
      SubCategory(id: 's22', name: 'Bonus',          parentId: '11'),
      SubCategory(id: 's23', name: 'Stocks',         parentId: '12'),
      SubCategory(id: 's24', name: 'Crypto',         parentId: '12'),
      SubCategory(id: 's25', name: 'Development',    parentId: '14'),
      SubCategory(id: 's26', name: 'Design',         parentId: '14'),
    ];
    for (final s in defaults) {
      await _service.addSubCategory(
        id: s.id,
        name: s.name,
        parentId: s.parentId,
      );
    }
  }

  Future<void> addSubCategory({
    required String name,
    required String parentId,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _service.addSubCategory(id: id, name: name, parentId: parentId);
  }
}