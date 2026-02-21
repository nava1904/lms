import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/current_admin_holder.dart';
import '../sanity_client_helper.dart';

/// Admin login: validates email against Sanity admin document (isActive) before allowing access.
/// Admin schema has no password field; add one in Sanity and verify here if needed.
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final email = _emailController.text.trim();
      final client = createLmsClient();
      const query = r'*[_type == "admin" && email == $email][0]{ _id, name, email, role, isActive }';
      final response = await client.fetch(query, params: {'email': email});
      final raw = response.result;
      final admin = raw is Map ? Map<String, dynamic>.from(raw as Map) : null;

      if (!mounted) return;
      if (admin == null || admin.isEmpty) {
        setState(() {
          _errorMessage = 'No admin found with this email.';
          _isLoading = false;
        });
        return;
      }
      final isActive = admin['isActive'];
      if (isActive == false) {
        setState(() {
          _errorMessage = 'This account is inactive.';
          _isLoading = false;
        });
        return;
      }
      setState(() => _isLoading = false);
      final adminId = admin['_id'] as String? ?? '';
      final adminName = admin['name'] as String? ?? 'Admin';
      final adminEmail = admin['email'] as String? ?? email;
      final adminRole = admin['role'] as String? ?? 'admin';
      CurrentAdminHolder.set(adminId, name: adminName, email: adminEmail, role: adminRole);
      context.go('/admin-dashboard', extra: {
        'adminId': adminId,
        'adminName': adminName,
        'adminEmail': adminEmail,
        'adminRole': adminRole,
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  maxLength: 128,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    counterText: '',
                    hintText: 'Min 8 chars, upper, lower, number, special',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password required';
                    if (v.length < 8) return 'Min 8 characters';
                    if (!v.contains(RegExp(r'[A-Z]'))) return 'Include uppercase';
                    if (!v.contains(RegExp(r'[a-z]'))) return 'Include lowercase';
                    if (!v.contains(RegExp(r'[0-9]'))) return 'Include number';
                    if (!v.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return 'Include special char';
                    return null;
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
