import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/currency_provider.dart';
import '../../core/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      setState(() => _version = '1.0.0');
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


Future<void> _clearAllData() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Clear All Data'),
      content: const Text(
          'Бүх transaction, category өгөгдлийг устгах уу?\nЭнэ үйлдлийг буцаах боломжгүй!'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Clear', style: TextStyle(color: Colors.red)),
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

      // 🗑️ Transactions устгах
      final txns = await userDoc.collection('transactions').get();
      for (final doc in txns.docs) {
        await doc.reference.delete();
      }

      // 🗑️ Categories устгах
      final cats = await userDoc.collection('categories').get();
      for (final doc in cats.docs) {
        await doc.reference.delete();
      }

      // 🗑️ Subcategories устгах
      final subs = await userDoc.collection('subcategories').get();
      for (final doc in subs.docs) {
        await doc.reference.delete();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ All data cleared!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}


  Future<void> _changePassword() async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (newCtrl.text != confirmCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwords do not match!'),
                    backgroundColor: Colors.red,
                  ),
                );
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Password changed!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF7F8FA);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? Colors.white38 : Colors.grey;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text('Settings',
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            )),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            _sectionTitle('Appearance', textColor),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  SwitchListTile(
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
                    title: Text('Dark Mode',
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                    subtitle: Text(isDark ? 'On' : 'Off',
                        style: TextStyle(color: subColor, fontSize: 12)),
                    value: isDark,
                    onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
                    activeColor: Colors.purple,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),


            _sectionTitle('Currency', textColor),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
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
                title: Text('Currency',
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
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, color: subColor),
                  ],
                ),
                onTap: () => _showCurrencyPicker(cardColor, textColor, subColor),
              ),
            ),

            const SizedBox(height: 20),


            _sectionTitle('Security', textColor),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
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
                title: Text('Change Password',
                    style: TextStyle(
                        color: textColor, fontWeight: FontWeight.w500)),
                subtitle: Text('Update your password',
                    style: TextStyle(color: subColor, fontSize: 12)),
                trailing: Icon(Icons.chevron_right, color: subColor),
                onTap: _changePassword,
              ),
            ),

            const SizedBox(height: 20),


            _sectionTitle('Data', textColor),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
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
                title: Text('Clear All Data',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w500)),
                subtitle: Text('Delete all transactions & categories',
                    style: TextStyle(color: subColor, fontSize: 12)),
                trailing: Icon(Icons.chevron_right, color: subColor),
                onTap: _clearAllData,
              ),
            ),

            const SizedBox(height: 20),


            _sectionTitle('About', textColor),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
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
                    title: Text('Version',
                        style: TextStyle(
                            color: textColor, fontWeight: FontWeight.w500)),
                    trailing: Text(_version,
                        style: TextStyle(color: subColor, fontSize: 13)),
                  ),
                  Divider(height: 1, color: isDark ? Colors.white12 : Colors.grey.shade100),
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
                    title: Text('App Name',
                        style: TextStyle(
                            color: textColor, fontWeight: FontWeight.w500)),
                    trailing: Text('Expense Tracker Pro',
                        style: TextStyle(color: subColor, fontSize: 13)),
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


void _showCurrencyPicker(
    Color cardColor, Color textColor, Color subColor) {
  showModalBottomSheet(
    context: context,
    backgroundColor: cardColor,
    isScrollControlled: true, // ← нэмэх
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => DraggableScrollableSheet( // ← ScrollableSheet болгох
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
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('Select Currency',
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