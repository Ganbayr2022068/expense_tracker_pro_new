import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/models/subcategory.dart';

final subcategoryProvider =
    StateNotifierProvider<SubCategoryNotifier, List<SubCategory>>(
  (ref) => SubCategoryNotifier(),
);

class SubCategoryNotifier extends StateNotifier<List<SubCategory>> {
  SubCategoryNotifier() : super([]) {
    _init();
  }

  final _box = Hive.box<SubCategory>('subcategories');

  Future<void> _init() async {
    await _box.clear();
      await _seedDefaultSubcategories();
    _load();
  }

  void _load() {
    state = _box.values.toList();
  }

  Future<void> _seedDefaultSubcategories() async {
    final defaults = [
SubCategory(id: 's1',  name: 'Restaurant',            parentId: '1'),
SubCategory(id: 's2',  name: 'Fast Food',             parentId: '1'),
SubCategory(id: 's3',  name: 'Coffee',                parentId: '1'),
SubCategory(id: 's4',  name: 'Grocery',               parentId: '1'),
SubCategory(id: 's5',  name: 'Home Cooking',          parentId: '1'),
SubCategory(id: 's6',  name: 'Street Food',           parentId: '1'),

SubCategory(id: 's7',  name: 'Taxi',                  parentId: '2'),
SubCategory(id: 's8',  name: 'Bus',                   parentId: '2'),
SubCategory(id: 's9',  name: 'Metro',                 parentId: '2'),
SubCategory(id: 's10', name: 'Fuel',                  parentId: '2'),
SubCategory(id: 's11', name: 'Car Repair',            parentId: '2'),
SubCategory(id: 's12', name: 'Parking',               parentId: '2'),

SubCategory(id: 's13', name: 'Clothing',              parentId: '3'),
SubCategory(id: 's14', name: 'Electronics',           parentId: '3'),
SubCategory(id: 's15', name: 'Home Supplies',         parentId: '3'),
SubCategory(id: 's16', name: 'Toys',                  parentId: '3'),
SubCategory(id: 's17', name: 'Gifts',                 parentId: '3'),

SubCategory(id: 's18', name: 'Apartment',             parentId: '4'),
SubCategory(id: 's19', name: 'Utilities',             parentId: '4'),
SubCategory(id: 's20', name: 'Internet',              parentId: '4'),
SubCategory(id: 's21', name: 'Electricity',           parentId: '4'),
SubCategory(id: 's22', name: 'Water',                 parentId: '4'),

SubCategory(id: 's23', name: 'Pharmacy',              parentId: '5'),
SubCategory(id: 's24', name: 'Doctor Visit',          parentId: '5'),
SubCategory(id: 's25', name: 'Dentist',               parentId: '5'),
SubCategory(id: 's26', name: 'Laboratory',            parentId: '5'),
SubCategory(id: 's27', name: 'Insurance',             parentId: '5'),

SubCategory(id: 's28', name: 'Cinema',                parentId: '6'),
SubCategory(id: 's29', name: 'Gaming',                parentId: '6'),
SubCategory(id: 's30', name: 'Travel',                parentId: '6'),
SubCategory(id: 's31', name: 'Concert',               parentId: '6'),
SubCategory(id: 's32', name: 'Sports Event',          parentId: '6'),

SubCategory(id: 's33', name: 'Shoes',                 parentId: '7'),
SubCategory(id: 's34', name: 'Bag',                   parentId: '7'),
SubCategory(id: 's35', name: 'Hat',                   parentId: '7'),
SubCategory(id: 's36', name: 'Underwear',             parentId: '7'),

SubCategory(id: 's37', name: 'Tuition Fee',           parentId: '8'),
SubCategory(id: 's38', name: 'Books',                 parentId: '8'),
SubCategory(id: 's39', name: 'Online Course',         parentId: '8'),
SubCategory(id: 's40', name: 'Stationery',            parentId: '8'),

SubCategory(id: 's41', name: 'Haircut',               parentId: '9'),
SubCategory(id: 's42', name: 'Skin Care',             parentId: '9'),
SubCategory(id: 's43', name: 'Cosmetics',             parentId: '9'),
SubCategory(id: 's44', name: 'Nail Care',             parentId: '9'),

SubCategory(id: 's45', name: 'Pet Food',              parentId: '10'),
SubCategory(id: 's46', name: 'Vet',                   parentId: '10'),
SubCategory(id: 's47', name: 'Pet Toys',              parentId: '10'),
SubCategory(id: 's48', name: 'Grooming',              parentId: '10'),

SubCategory(id: 's49', name: 'Base Salary',           parentId: '11'),
SubCategory(id: 's50', name: 'Bonus',                 parentId: '11'),
SubCategory(id: 's51', name: 'Overtime',              parentId: '11'),
SubCategory(id: 's52', name: 'Allowance',             parentId: '11'),

SubCategory(id: 's53', name: 'Stocks',                parentId: '12'),
SubCategory(id: 's54', name: 'Crypto',                parentId: '12'),
SubCategory(id: 's55', name: 'Savings Interest',      parentId: '12'),
SubCategory(id: 's56', name: 'Bonds',                 parentId: '12'),

SubCategory(id: 's57', name: 'Cash Gift',             parentId: '13'),
SubCategory(id: 's58', name: 'Prize',                 parentId: '13'),
SubCategory(id: 's59', name: 'Support',               parentId: '13'),

SubCategory(id: 's60', name: 'Design',                parentId: '14'),
SubCategory(id: 's61', name: 'Development',           parentId: '14'),
SubCategory(id: 's62', name: 'Translation',           parentId: '14'),
SubCategory(id: 's63', name: 'Consulting',            parentId: '14'),
SubCategory(id: 's64', name: 'Content Creation',      parentId: '14'),

SubCategory(id: 's65', name: 'Apartment',             parentId: '15'),
SubCategory(id: 's66', name: 'Car',                   parentId: '15'),
SubCategory(id: 's67', name: 'Equipment',             parentId: '15'),
    ];

    for (final s in defaults) {
      await _box.put(s.id, s);
    }
  }

  Future<void> addSubCategory({
    required String name,
    required String parentId,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final sub = SubCategory(
      id: id,
      name: name,
      parentId: parentId,
    );

    await _box.put(id, sub);
    _load();
  }
}