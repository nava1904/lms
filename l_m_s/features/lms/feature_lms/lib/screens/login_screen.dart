import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../sanity_client_helper.dart';
import '../models/models.dart';
import '../services/lms_sanity_service.dart';
import '../theme/lms_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rollNumberController = TextEditingController();
  String _selectedRole = 'student';
  bool _isLoading = false;
  String? _errorMessage;
  AdBanner? _adBanner;
  final _lmsService = LmsSanityService();

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  Future<void> _loadBanner() async {
    final banner = await _lmsService.getActiveAdBanner();
    if (mounted) setState(() => _adBanner = banner);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _rollNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final query = _buildQuery();
      final params = _buildQueryParams();

      final response = await SanityClientHelper.client.fetch(query, params: params.map((k, v) => MapEntry(k, v.toString())));
      dynamic raw = response.result;
      if (raw is List && raw.isNotEmpty) raw = raw.first;
      final result = raw is Map ? Map<String, dynamic>.from(raw) : null;

      if (result != null) {
        _navigateToDashboard(result);
      } else {
        setState(() => _errorMessage = 'Invalid credentials or user not found.');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _buildQuery() {
    switch (_selectedRole) {
      case 'student':
        return r'*[_type == "student" && rollNumber == $rollNumber][0]';
      case 'teacher':
        return r'*[_type == "teacher" && email == $email][0]';
      case 'admin':
        return r'*[_type == "admin" && email == $email][0]';
      default:
        throw Exception('Invalid role selected');
    }
  }

  Map<String, dynamic> _buildQueryParams() {
    switch (_selectedRole) {
      case 'student':
        return {'rollNumber': _rollNumberController.text.trim()};
      case 'teacher':
      case 'admin':
        return {'email': _emailController.text.trim()};
      default:
        throw Exception('Invalid role selected');
    }
  }

  void _navigateToDashboard(Map<String, dynamic> user) {
    switch (_selectedRole) {
      case 'student': {
        final id = user['_id'] as String? ?? '';
        context.go('/student-dashboard/$id', extra: {
          'studentName': user['name'] ?? 'Student',
          'rollNumber': user['rollNumber'] ?? '',
        });
        break;
      }
      case 'teacher':
        context.go('/teacher-dashboard', extra: {
          'teacherName': user['name'] ?? 'Teacher',
          'teacherId': user['_id'] ?? '',
        });
        break;
      case 'admin':
        context.go('/admin-dashboard', extra: {
          'adminName': user['name'] ?? 'Admin',
          'adminId': user['_id'] ?? '',
          'adminRole': user['role'] ?? 'admin',
        });
        break;
    }
  }

  static const Color _gradientStart = Color(0xFFEFF6FF);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _mutedForeground = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_gradientStart, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(context),
                    if (_adBanner != null) ...[
                      const SizedBox(height: 24),
                      _buildBanner(context),
                    ],
                    const SizedBox(height: 32),
                    _buildLoginCard(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: LMSTheme.primaryColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: LMSTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.menu_book_rounded, size: 36, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          'LearnHub',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: LMSTheme.onSurfaceColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to your account',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: _mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildBanner(BuildContext context) {
    if (_adBanner == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LMSTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LMSTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_adBanner!.headline != null && _adBanner!.headline!.isNotEmpty)
            Text(
              _adBanner!.headline!,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: LMSTheme.primaryColor,
              ),
            ),
          if (_adBanner!.callToAction != null && _adBanner!.callToAction!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _adBanner!.callToAction!,
              style: GoogleFonts.inter(fontSize: 13, color: _mutedForeground),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: const [
                DropdownMenuItem(value: 'student', child: Text('Student')),
                DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (value) => setState(() => _selectedRole = value!),
              decoration: InputDecoration(
                labelText: 'Role',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _border),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedRole != 'student')
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Email is required';
                  if (!value!.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
            if (_selectedRole == 'student')
              TextFormField(
                controller: _rollNumberController,
                decoration: InputDecoration(
                  labelText: 'Roll Number',
                  prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Roll Number is required' : null,
              ),
            if (_selectedRole != 'student') ...[
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Password is required';
                  if (value!.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
            ],
            const SizedBox(height: 20),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: LMSTheme.errorColor,
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: LMSTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Sign in',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}