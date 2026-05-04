import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/currency_provider.dart';
import '../../core/theme_provider.dart';
import '../../core/language_provider.dart';
import '../../core/app_strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _version = '';
  String _selectedCurrency = '₮';
  bool _isLoading = false;

  final List<Map<String, String>> _currencies = [
    {'symbol': '₮', 'name': 'Mongolian Tögrög (MNT)'},
    {'symbol': '\$', 'name': 'US Dollar (USD)'},
    {'symbol': '€', 'name': 'Euro (EUR)'},
    {'symbol': '¥', 'name': 'Japanese Yen (JPY)'},
    {'symbol': '£', 'name': 'British Pound (GBP)'},
    {'symbol': '₩', 'name': 'Korean Won (KRW)'},
    {'symbol': '¥', 'name': 'Chinese Yuan (CNY)'},
    {'symbol': '₽', 'name': 'Russian Ruble (RUB)'},
  ];

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'mn', 'name': 'Монгол', 'flag': '🇲🇳'},
  ];

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _loadCurrency();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() => _version = '${info.version} (${info.buildNumber})');
    } catch (_) {
      setState(() => _version = '2.0.0');
    }
  }

  void _loadCurrency() {
    final currency = ref.read(currencyProvider);
    setState(() => _selectedCurrency = currency);
  }

  Future<void> _saveCurrency(String currency) async {
    await ref.read(currencyProvider.notifier).setCurrency(currency);
    setState(() => _selectedCurrency = currency);
  }

  String s(String key) {
    final lang = ref.read(languageProvider);
    return AppStrings.get(key, lang);
  }

  Future<void> _clearAllData() async {
    final lang = ref.read(languageProvider);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.get('clear_confirm_title', lang)),
        content: Text(AppStrings.get('clear_confirm_body', lang)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.get('cancel', lang)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.get('clear', lang),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) return;
        final firestore = FirebaseFirestore.instance;
        final userDoc = firestore.collection('users').doc(uid);
        final txns = await userDoc.collection('transactions').get();
        for (final doc in txns.docs) await doc.reference.delete();
        final cats = await userDoc.collection('categories').get();
        for (final doc in cats.docs) await doc.reference.delete();
        final subs = await userDoc.collection('subcategories').get();
        for (final doc in subs.docs) await doc.reference.delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppStrings.get('data_cleared', lang)),
            backgroundColor: Colors.green,
          ));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${AppStrings.get('error', lang)}: $e'),
            backgroundColor: Colors.red,
          ));
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _changePassword() async {
    final lang = ref.read(languageProvider);
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.get('change_password', lang)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppStrings.get('current_password', lang),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppStrings.get('new_password', lang),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppStrings.get('confirm_password', lang),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.get('cancel', lang)),
          ),
          TextButton(
            onPressed: () async {
              if (newCtrl.text != confirmCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppStrings.get('passwords_no_match', lang)),
                  backgroundColor: Colors.red,
                ));
                return;
              }
              try {
                final user = FirebaseAuth.instance.currentUser;
                final cred = EmailAuthProvider.credential(
                  email: user?.email ?? '',
                  password: currentCtrl.text,
                );
                await user?.reauthenticateWithCredential(cred);
                await user?.updatePassword(newCtrl.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(AppStrings.get('password_changed', lang)),
                    backgroundColor: Colors.green,
                  ));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${AppStrings.get('error', lang)}: $e'),
                    backgroundColor: Colors.red,
                  ));
                }
              }
            },
            child: Text(AppStrings.get('save', lang)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final lang = ref.watch(languageProvider);
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
          AppStrings.get('settings', lang),
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── APPEARANCE ──
                  _sectionTitle(AppStrings.get('appearance', lang), textColor),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16)),
                    child: SwitchListTile(
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isDark ? Icons.dark_mode : Icons.light_mode,
                          color: Colors.purple,
                          size: 20,
                        ),
                      ),
                      title: Text(AppStrings.get('dark_mode', lang),
                          style: TextStyle(
                              color: textColor, fontWeight: FontWeight.w500)),
                      subtitle: Text(
                          isDark
                              ? AppStrings.get('on', lang)
                              : AppStrings.get('off', lang),
                          style: TextStyle(color: subColor, fontSize: 12)),
                      value: isDark,
                      onChanged: (_) =>
                          ref.read(themeProvider.notifier).toggle(),
                      activeColor: Colors.purple,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── LANGUAGE ──
                  _sectionTitle(AppStrings.get('language', lang), textColor),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.language,
                            color: Colors.blue, size: 20),
                      ),
                      title: Text(AppStrings.get('language', lang),
                          style: TextStyle(
                              color: textColor, fontWeight: FontWeight.w500)),
                      subtitle: Text(
                          lang == 'mn' ? '🇲🇳 Монгол' : '🇺🇸 English',
                          style: TextStyle(color: subColor, fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(lang == 'mn' ? '🇲🇳' : '🇺🇸',
                              style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right, color: subColor),
                        ],
                      ),
                      onTap: () =>
                          _showLanguagePicker(cardColor, textColor, subColor),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── CURRENCY ──
                  _sectionTitle(AppStrings.get('currency', lang), textColor),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.attach_money,
                            color: Colors.green, size: 20),
                      ),
                      title: Text(AppStrings.get('currency', lang),
                          style: TextStyle(
                              color: textColor, fontWeight: FontWeight.w500)),
                      subtitle: Text(
                        _currencies.firstWhere(
                          (c) => c['symbol'] == _selectedCurrency,
                          orElse: () => _currencies.first,
                        )['name']!,
                        style: TextStyle(color: subColor, fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_selectedCurrency,
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right, color: subColor),
                        ],
                      ),
                      onTap: () =>
                          _showCurrencyPicker(cardColor, textColor, subColor),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── SECURITY ──
                  _sectionTitle(AppStrings.get('security', lang), textColor),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.lock_outline,
                            color: Colors.blue, size: 20),
                      ),
                      title: Text(AppStrings.get('change_password', lang),
                          style: TextStyle(
                              color: textColor, fontWeight: FontWeight.w500)),
                      subtitle: Text(AppStrings.get('update_password', lang),
                          style: TextStyle(color: subColor, fontSize: 12)),
                      trailing: Icon(Icons.chevron_right, color: subColor),
                      onTap: _changePassword,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── DATA ──
                  _sectionTitle(AppStrings.get('data', lang), textColor),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.delete_outline,
                            color: Colors.red, size: 20),
                      ),
                      title: Text(AppStrings.get('clear_all_data', lang),
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w500)),
                      subtitle: Text(AppStrings.get('clear_data_sub', lang),
                          style: TextStyle(color: subColor, fontSize: 12)),
                      trailing: Icon(Icons.chevron_right, color: subColor),
                      onTap: _clearAllData,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── ABOUT ──
                  _sectionTitle(AppStrings.get('about', lang), textColor),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.info_outline,
                                color: Colors.purple, size: 20),
                          ),
                          title: Text(AppStrings.get('version', lang),
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w500)),
                          trailing: Text(_version,
                              style:
                                  TextStyle(color: subColor, fontSize: 13)),
                        ),
                        Divider(
                            height: 1,
                            color: isDark
                                ? Colors.white12
                                : Colors.grey.shade100),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.apps,
                                color: Colors.orange, size: 20),
                          ),
                          title: Text(AppStrings.get('app_name', lang),
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w500)),
                          trailing: Text('Expense Tracker Pro',
                              style:
                                  TextStyle(color: subColor, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  void _showLanguagePicker(
      Color cardColor, Color textColor, Color subColor) {
    final lang = ref.read(languageProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.get('select_language', lang),
              style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ..._languages.map((l) => ListTile(
                  leading: Text(l['flag']!,
                      style: const TextStyle(fontSize: 24)),
                  title: Text(l['name']!,
                      style: TextStyle(color: textColor, fontSize: 15)),
                  trailing: lang == l['code']
                      ? const Icon(Icons.check_circle, color: Colors.blue)
                      : null,
                  onTap: () {
                    ref
                        .read(languageProvider.notifier)
                        .setLanguage(l['code']!);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(
      Color cardColor, Color textColor, Color subColor) {
    final lang = ref.read(languageProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(AppStrings.get('select_currency', lang),
                  style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ..._currencies.map((c) => ListTile(
                    leading: Text(c['symbol']!,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w700)),
                    title: Text(c['name']!,
                        style: TextStyle(color: textColor, fontSize: 14)),
                    trailing: _selectedCurrency == c['symbol']
                        ? const Icon(Icons.check_circle, color: Colors.purple)
                        : null,
                    onTap: () {
                      _saveCurrency(c['symbol']!);
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: textColor.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }
}