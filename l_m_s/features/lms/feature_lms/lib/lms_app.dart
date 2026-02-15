import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/vyuh_auth_plugin.dart';
import 'screens/figma_landing_page.dart';
import 'screens/enhanced_login_screen.dart';
import 'screens/premium_home_dashboard.dart';
import 'screens/teacher_main_dashboard.dart';
import 'screens/admin_dashboard_screen.dart';

class LMSApp extends StatelessWidget {
  const LMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VyuthAuthService()),
      ],
      child: MaterialApp.router(
        title: 'EduLearn - Professional LMS',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A73E8),
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        routerConfig: _buildGoRouter(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  GoRouter _buildGoRouter() {
    return GoRouter(
      initialLocation: '/',
      errorPageBuilder: (context, state) => MaterialPage(
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Page Not Found'),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Go Home'),
                ),
              ],
            ),
          ),
        ),
      ),
      redirect: (context, state) {
        final authService = context.read<VyuthAuthService>();
        final isAuthenticated = authService.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/enhanced-login';
        final isSigningUp = state.matchedLocation == '/signup';
        final isHome = state.matchedLocation == '/';

        if (!isAuthenticated && !isLoggingIn && !isSigningUp && !isHome) {
          return '/enhanced-login';
        }

        if (isAuthenticated && (isLoggingIn || isSigningUp)) {
          final role = authService.currentUser?.role;
          return _getDashboardRoute(role);
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const FigmaLandingPage(),
        ),
        GoRoute(
          path: '/enhanced-login',
          name: 'login',
          builder: (context, state) => const EnhancedLoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: '/student-dashboard',
          name: 'student-dashboard',
          builder: (context, state) {
            final authService = context.read<VyuthAuthService>();
            return PremiumHomeDashboard(
              userName: authService.currentUser?.name ?? 'Student',
              userRole: 'student',
            );
          },
        ),
        GoRoute(
          path: '/teacher-dashboard',
          name: 'teacher-dashboard',
          builder: (context, state) {
            final authService = context.read<VyuthAuthService>();
            return TeacherMainDashboard(
              teacherName: authService.currentUser?.name ?? 'Teacher',
              teacherId: authService.currentUser?.id ?? 'teacher1',
            );
          },
        ),
        GoRoute(
          path: '/admin-dashboard',
          name: 'admin-dashboard',
          builder: (context, state) {
            final authService = context.read<VyuthAuthService>();
            return AdminDashboardScreen(
              adminId: authService.currentUser?.id ?? 'admin1',
              adminName: authService.currentUser?.name ?? 'Admin',
              adminEmail: authService.currentUser?.email ?? 'admin@example.com',
              adminRole: 'admin',
            );
          },
        ),
      ],
    );
  }

  String _getDashboardRoute(String? role) {
    switch (role) {
      case 'student':
        return '/student-dashboard';
      case 'teacher':
        return '/teacher-dashboard';
      case 'admin':
        return '/admin-dashboard';
      default:
        return '/';
    }
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'student';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    final authService = context.read<VyuthAuthService>();
    final success = await authService.register(
      _emailController.text,
      _passwordController.text,
      _nameController.text,
      _selectedRole,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      context.go(_getDashboardRoute(_selectedRole));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email already exists')),
        );
      }
    }
  }

  String _getDashboardRoute(String role) {
    switch (role) {
      case 'student':
        return '/student-dashboard';
      case 'teacher':
        return '/teacher-dashboard';
      case 'admin':
        return '/admin-dashboard';
      default:
        return '/';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(40),
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Account',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  'Join EduLearn and start learning today',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign Up'),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/enhanced-login'),
                      child: Text(
                        'Sign In',
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
        ),
      ),
    );
  }

  Widget _buildRoleButton(String label, String role) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
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
}