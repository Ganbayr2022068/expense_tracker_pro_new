import 'package:expense_tracker_pro_new/features/settings/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

import '../../core/theme_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _base64Image;
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController.text = user?.displayName ?? '';
    _emailController.text = user?.email ?? '';
    _loadProfilePhoto();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfilePhoto() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists && doc.data()?['photoBase64'] != null) {
        setState(() => _base64Image = doc.data()!['photoBase64']);
      }
    } catch (_) {}
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 300,
      maxHeight: 300,
    );
    if (picked != null) {
      setState(() => _isLoading = true);
      try {
        final bytes = await File(picked.path).readAsBytes();
        final base64Str = base64Encode(bytes);
        final uid = FirebaseAuth.instance.currentUser!.uid;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({'photoBase64': base64Str}, SetOptions(merge: true));

        setState(() {
          _base64Image = base64Str;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Photo updated!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.updateDisplayName(_nameController.text.trim());

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set({'displayName': _nameController.text.trim()},
              SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure? This action cannot be undone.'),
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
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      }
      await FirebaseAuth.instance.currentUser?.delete();
    }
  }

  Widget _buildAvatar() {
    ImageProvider? imageProvider;
    if (_base64Image != null) {
      imageProvider = MemoryImage(base64Decode(_base64Image!));
    }
    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.purple.withOpacity(0.2),
      backgroundImage: imageProvider,
      child: _isLoading
          ? const CircularProgressIndicator()
          : imageProvider == null
              ? const Icon(Icons.person, size: 60)
              : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ref.read(themeProvider.notifier).toggle(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _isLoading ? null : _pickImage,
              child: Stack(
                children: [
                  _buildAvatar(),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.purple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            if (user?.emailVerified == true)
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text('Verified',
                      style: TextStyle(color: Colors.green, fontSize: 12)),
                ],
              )
            else
              TextButton.icon(
                onPressed: () async {
                  await user?.sendEmailVerification();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Verification email sent!'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.warning, color: Colors.orange, size: 16),
                label: const Text('Verify email',
                    style: TextStyle(color: Colors.orange)),
              ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Personal Info',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Display Name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveProfile,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save),
                        label: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.settings, color: Colors.purple),
                title: const Text('Settings'),
                subtitle: const Text('Currency, Dark mode, Data'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.orange),
                    title: const Text('Logout'),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading:
                        const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text('Delete Account',
                        style: TextStyle(color: Colors.red)),
                    onTap: _deleteAccount,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
