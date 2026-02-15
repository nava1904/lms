/// # Vyuh-Inspired Authentication Plugin
/// 
/// This authentication system follows the Vyuh architecture patterns for
/// extensible, production-ready authentication management.
/// 
/// ## Architecture
/// 
/// ### 1. AuthProvider (Abstract Base)
/// - Defines contract for all authentication providers
/// - Methods: authenticate, register, logout, isAuthenticated
/// - Extensible for different authentication strategies
/// 
/// ### 2. AuthResult (Data Model)
/// - Encapsulates authentication operation results
/// - Properties: success, userId, email, name, role, error, token
/// 
/// ### 3. AuthUser (User Model)
/// - Represents authenticated user information
/// - Properties: id, email, name, role, avatar, createdAt, lastLoginAt
/// 
/// ### 4. EmailPasswordAuthProvider (Implementation)
/// - Concrete implementation for email/password authentication
/// - Includes mock user database for demo
/// - Supports user registration and login
/// 
/// ### 5. VyuhAuthService (Service Provider)
/// - Extends ChangeNotifier for reactive updates
/// - Manages current authentication state
/// - Provides login, register, logout operations
/// - Stores user tokens and session data
/// 
/// ## Usage Example
/// 
/// ```dart
/// // Initialize with provider
/// final authService = VyuhAuthService(
///   provider: EmailPasswordAuthProvider(),
/// );
/// 
/// // Login
/// bool success = await authService.login('user@example.com', 'password');
/// 
/// // Register
/// bool registered = await authService.register(
///   'newuser@example.com',
///   'password',
///   'John Doe',
///   'student',
/// );
/// 
/// // Check authentication status
/// if (authService.isAuthenticated) {
///   print('User: ${authService.currentUser?.name}');
///   print('Role: ${authService.currentUser?.role}');
/// }
/// 
/// // Logout
/// await authService.logout();
/// ```
/// 
/// ## Features
/// 
/// - **Extensible Provider Pattern**: Easy to swap authentication providers
/// - **Role-Based Access**: Built-in support for multiple user roles
/// - **Session Management**: Token and session data handling
/// - **User Information**: Comprehensive user profile data
/// - **Error Handling**: Structured error reporting
/// - **Reactive State**: ChangeNotifier integration for UI updates
/// 
/// ## Demo Credentials
/// 
/// | Role | Email | Password |
/// |------|-------|----------|
/// | Student | student@example.com | student123 |
/// | Teacher | teacher@example.com | teacher123 |
/// | Admin | admin@example.com | admin123 |
/// 
/// ## Mock Database Structure
/// 
/// ```dart
/// {
///   'email@example.com': {
///     'id': 'user_id',
///     'password': 'hashed_password',
///     'name': 'User Name',
///     'role': 'student|teacher|admin',
///     'email': 'email@example.com',
///     'avatar': 'image_url',
///   }
/// }
/// ```
/// 
/// ## Extension Points
/// 
/// ### 1. Custom Auth Providers
/// Extend `AuthProvider` to implement:
/// - Firebase Authentication
/// - OAuth2 / OpenID Connect
/// - SAML
/// - Custom REST APIs
/// 
/// ### 2. User Persistence
/// Add local storage integration:
/// - SharedPreferences for simple storage
/// - Hive for offline-first apps
/// - SQLite for complex data
/// 
/// ### 3. Token Management
/// Implement token refresh:
/// - JWT token validation
/// - Automatic token refresh
/// - Token expiration handling
/// 
/// ## Future Enhancements
/// 
/// - [ ] Biometric authentication
/// - [ ] Social login (Google, GitHub, Facebook)
/// - [ ] Two-factor authentication
/// - [ ] Password reset flow
/// - [ ] Email verification
/// - [ ] Account recovery
/// - [ ] Session management
/// - [ ] Rate limiting
/// - [ ] Audit logging
/// - [ ] RBAC (Role-Based Access Control)
/// 
/// ## Integration with Flutter UI
/// 
/// ```dart
/// // Wrap app with Provider
/// MultiProvider(
///   providers: [
///     ChangeNotifierProvider(
///       create: (_) => VyuhAuthService(),
///     ),
///   ],
///   child: MaterialApp(...),
/// )
/// 
/// // Use in widgets
/// Consumer<VyuthAuthService>(
///   builder: (context, authService, child) {
///     if (authService.isAuthenticated) {
///       return Dashboard();
///     } else {
///       return LoginScreen();
///     }
///   },
/// )
/// ```
/// 
/// ## Security Considerations
/// 
/// - Never store passwords in plain text (use bcrypt/scrypt in production)
/// - Use HTTPS for all authentication API calls
/// - Implement rate limiting on login attempts
/// - Use secure token storage (secure_storage package)
/// - Implement certificate pinning for API calls
/// - Validate tokens server-side
/// - Implement automatic logout on token expiration
/// - Clear sensitive data on logout
/// 
library vyuh_auth_plugin;
