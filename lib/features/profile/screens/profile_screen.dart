import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/auth_service.dart';
import '../../../models/user_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  String? _block;
  bool _editing = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _startEdit(UserModel user) {
    _nameCtrl.text = user.name;
    _block = user.hostelBlock;
    setState(() => _editing = true);
  }

  Future<void> _saveProfile(UserModel user) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).updateUserProfile(
            user.copyWith(name: _nameCtrl.text.trim(), hostelBlock: _block),
          );
      ref.invalidate(currentUserProvider);
      setState(() => _editing = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          userAsync.when(
            data: (user) => user != null && !_editing
                ? IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _startEdit(user),
                  )
                : const SizedBox(),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('Not logged in'));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: cs.primaryContainer,
                    child: Text(
                      user.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(fontSize: 36, color: cs.primary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (user.isAdmin)
                    Chip(
                      label: const Text('Admin'),
                      backgroundColor: cs.primary,
                      labelStyle: TextStyle(color: cs.onPrimary),
                    ),
                  const SizedBox(height: 24),
                  if (_editing) ...[
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline)),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _block,
                      decoration: const InputDecoration(
                          labelText: 'Hostel Block',
                          prefixIcon: Icon(Icons.apartment_outlined)),
                      items: AppConstants.hostelBlocks
                          .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                          .toList(),
                      onChanged: (v) => setState(() => _block = v),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _editing = false),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _loading ? null : () => _saveProfile(user),
                            child: _loading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child:
                                        CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    _ProfileTile(
                        icon: Icons.person, label: 'Name', value: user.name),
                    _ProfileTile(
                        icon: Icons.email, label: 'Email', value: user.email),
                    _ProfileTile(
                        icon: Icons.school,
                        label: 'Course',
                        value: user.course),
                    _ProfileTile(
                        icon: Icons.calendar_today,
                        label: 'Year',
                        value: 'Year ${user.year}'),
                    _ProfileTile(
                        icon: Icons.apartment,
                        label: 'Hostel Block',
                        value: user.hostelBlock),
                  ],
                  const SizedBox(height: 32),
                  if (!_editing)
                    OutlinedButton.icon(
                      onPressed: () async {
                        await ref.read(authServiceProvider).signOut();
                        if (context.mounted) context.go('/login');
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text('Sign Out',
                          style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: cs.primary),
      title: Text(label, style: Theme.of(context).textTheme.bodySmall),
      subtitle: Text(value,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.w500)),
    );
  }
}
