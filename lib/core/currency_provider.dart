import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final currencyProvider = StateNotifierProvider<CurrencyNotifier, String>((ref) {
  return CurrencyNotifier();
});

class CurrencyNotifier extends StateNotifier<String> {
  CurrencyNotifier() : super('₮') {
    _load();
  }

  void _load() {
    final box = Hive.box('settings');
    state = box.get('currency', defaultValue: '₮');
  }

  Future<void> setCurrency(String currency) async {
    final box = Hive.box('settings');
    await box.put('currency', currency);
    state = currency;
  }
}