import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/language_provider.dart';
import '../../core/app_strings.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _login() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('💰 ${AppStrings.get('app_name', lang)}',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),

              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('email', lang),
                  prefixIcon: const Icon(Icons.email),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('password', lang),
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 8),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                  child: Text(AppStrings.get('forgot_password', lang))
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(AppStrings.get('login', lang))
                ),
              ),
              const SizedBox(height: 12),

              TextButton(
                onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: Text(AppStrings.get('no_account', lang))
              ),
            ],
          ),
        ),
      ),
    );
  }
}