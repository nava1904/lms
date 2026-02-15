import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/vyuh_auth_plugin.dart';

class EnhancedLoginScreen extends StatefulWidget {
  const EnhancedLoginScreen({super.key});

  @override
  State<EnhancedLoginScreen> createState() => _EnhancedLoginScreenState();
}

class _EnhancedLoginScreenState extends State<EnhancedLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'student';
  bool _isLoading = false;
  String _errorMessage = '';

  final Map<String, Map<String, String>> demoCredentials = {
    'student': {'email': 'student@example.com', 'password': 'student123', 'name': 'Student Demo'},
    'teacher': {'email': 'teacher@example.com', 'password': 'teacher123', 'name': 'Teacher Demo'},
    'admin': {'email': 'admin@example.com', 'password': 'admin123', 'name': 'Admin Demo'},
  };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill all fields');
      return;
    }

    setState(() => _isLoading = true);

    final authService = context.read<VyuhAuthService>();
    final success = await authService.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        _navigateToDashboard();
      }
    } else {
      setState(() => _errorMessage = 'Invalid credentials for $_selectedRole');
    }
  }

  void _fillDemoCredentials() {
    final creds = demoCredentials[_selectedRole];
    _emailController.text = creds!['email']!;
    _passwordController.text = creds['password']!;
    setState(() => _errorMessage = '');
  }

  void _navigateToDashboard() {
    final role = context.read<VyuhAuthService>().currentUser?.role;
    String route = '/';

    switch (role) {
      case 'student':
        route = '/student-dashboard';
        break;
      case 'teacher':
        route = '/teacher-dashboard';
        break;
      case 'admin':
        route = '/admin-dashboard';
        break;
    }

    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: isMobile
          ? _buildMobileLayout(theme)
          : Row(
              children: [
                Expanded(child: _buildLeftPanel(theme)),
                Expanded(child: _buildLoginForm(theme)),
              ],
            ),
    );
  }

  Widget _buildMobileLayout(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildLeftPanel(theme),
          _buildLoginForm(theme),
        ],
      ),
    );
  }

  Widget _buildLeftPanel(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A73E8).withOpacity(0.95),
            const Color(0xFF8B5CF6).withOpacity(0.95),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'EduLearn',
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Professional Learning Management System',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 40),
          _buildFeatureList(theme),
        ],
      ),
    );
  }

  Widget _buildFeatureList(ThemeData theme) {
    final features = [
      'Learn from industry experts',
      'Access courses anytime, anywhere',
      'Get recognized certificates',
      'Join a community of learners',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features
          .map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature,
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildLoginForm(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome Back',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              'Sign in to continue learning',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            // Role Selection
            Text(
              'Select Your Role',
              style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildRoleButton('Student', 'student'),
                const SizedBox(width: 12),
                _buildRoleButton('Teacher', 'teacher'),
                const SizedBox(width: 12),
                _buildRoleButton('Admin', 'admin'),
              ],
            ),
            const SizedBox(height: 32),
            // Email Input
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            // Password Input
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Demo Credentials Hint
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF1A73E8), size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Click "Use Demo Credentials" to auto-fill test account',
                      style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Use Demo Credentials Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _fillDemoCredentials,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Use Demo Credentials'),
              ),
            ),
            const SizedBox(height: 12),
            // Login Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign In'),
              ),
            ),
            const SizedBox(height: 16),
            // Sign Up Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/signup'),
                  child: Text(
                    'Sign Up',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF1A73E8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(String label, String role) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = role;
            _errorMessage = '';
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1A73E8) : Colors.white,
            border: Border.all(
              color: isSelected ? const Color(0xFF1A73E8) : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get selectedRole => _selectedRole;
}
