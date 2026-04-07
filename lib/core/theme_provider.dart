import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final themeProvider = StateNotifierProvider<ThemeNotifer, bool>((ref) {
  return ThemeNotifer();
});

class ThemeNotifer extends StateNotifier<bool> {
  ThemeNotifer() :super(false) {
    _load();
  }
  final _box = Hive.box('settings');

  void _load() {
    state = _box.get('isDarkMode', defaultValue: false);
  }

  void toggle() {
    state = !state;
    _box.put('isDarkMode', state);
  }
}