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
    SubCategory(id: 's1',  name: 'Restaurant',   nameMn: 'Ресторан',          parentId: '1'),
    SubCategory(id: 's2',  name: 'Fast Food',     nameMn: 'Түргэн хоол',       parentId: '1'),
    SubCategory(id: 's3',  name: 'Coffee',        nameMn: 'Кофе',              parentId: '1'),
    SubCategory(id: 's4',  name: 'Grocery',       nameMn: 'Хүнсний дэлгүүр',  parentId: '1'),
    SubCategory(id: 's5',  name: 'Street Food',   nameMn: 'Гудамжны хоол',    parentId: '1'),
    SubCategory(id: 's6',  name: 'Taxi',          nameMn: 'Такси',             parentId: '2'),
    SubCategory(id: 's7',  name: 'Bus',           nameMn: 'Автобус',           parentId: '2'),
    SubCategory(id: 's8',  name: 'Metro',         nameMn: 'Метро',             parentId: '2'),
    SubCategory(id: 's9',  name: 'Fuel',          nameMn: 'Түлш',              parentId: '2'),
    SubCategory(id: 's10', name: 'Car Repair',    nameMn: 'Машин засвар',      parentId: '2'),
    SubCategory(id: 's11', name: 'Clothing',      nameMn: 'Хувцас',            parentId: '3'),
    SubCategory(id: 's12', name: 'Electronics',   nameMn: 'Электроник',        parentId: '3'),
    SubCategory(id: 's13', name: 'Home Supplies', nameMn: 'Гэрийн хэрэгсэл',  parentId: '3'),
    SubCategory(id: 's14', name: 'Apartment',     nameMn: 'Орон сууц',         parentId: '4'),
    SubCategory(id: 's15', name: 'Utilities',     nameMn: 'Нийтийн үйлчилгээ',parentId: '4'),
    SubCategory(id: 's16', name: 'Internet',      nameMn: 'Интернет',          parentId: '4'),
    SubCategory(id: 's17', name: 'Pharmacy',      nameMn: 'Эмийн сан',         parentId: '5'),
    SubCategory(id: 's18', name: 'Doctor Visit',  nameMn: 'Эмч үзлэг',        parentId: '5'),
    SubCategory(id: 's19', name: 'Cinema',        nameMn: 'Кино',              parentId: '6'),
    SubCategory(id: 's20', name: 'Gaming',        nameMn: 'Тоглоом',           parentId: '6'),
    SubCategory(id: 's21', name: 'Base Salary',   nameMn: 'Үндсэн цалин',     parentId: '11'),
    SubCategory(id: 's22', name: 'Bonus',         nameMn: 'Урамшуулал',        parentId: '11'),
    SubCategory(id: 's23', name: 'Stocks',        nameMn: 'Хувьцаа',           parentId: '12'),
    SubCategory(id: 's24', name: 'Crypto',        nameMn: 'Крипто',            parentId: '12'),
    SubCategory(id: 's25', name: 'Development',   nameMn: 'Хөгжүүлэлт',       parentId: '14'),
    SubCategory(id: 's26', name: 'Design',        nameMn: 'Дизайн',            parentId: '14'),
    ];
    for (final s in defaults) {
      await _service.addSubCategory(
        id: s.id,
        name: s.name,
        nameMn: s.nameMn,
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