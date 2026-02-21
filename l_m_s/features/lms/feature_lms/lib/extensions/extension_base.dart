// filepath: /Users/navadeepreddy/learning mangement system/l_m_s/features/lms/feature_lms/lib/extensions/extension_base.dart

import 'package:flutter/material.dart';

/// Base class for extension points following Vyuh patterns
/// Extensions allow adding functionality without modifying core code
abstract class LmsExtension {
  /// Unique extension identifier
  String get id;
  
  /// Extension name
  String get name;
  
  /// Extension priority (higher = executed first)
  int get priority => 0;
}

/// Extension point for adding items to navigation
abstract class NavigationExtension extends LmsExtension {
  /// Get navigation items to add
  List<NavigationItem> getNavigationItems(BuildContext context);
}

/// Navigation item definition
class NavigationItem {
  final String id;
  final String label;
  final IconData icon;
  final String route;
  final int order;
  final bool showInDrawer;
  final bool showInBottomNav;

  const NavigationItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.route,
    this.order = 0,
    this.showInDrawer = true,
    this.showInBottomNav = true,
  });
}

/// Extension point for dashboard widgets
abstract class DashboardExtension extends LmsExtension {
  /// Get dashboard widgets to display
  List<Widget> getDashboardWidgets(BuildContext context);
}

/// Extension point for user profile sections
abstract class ProfileExtension extends LmsExtension {
  /// Get profile section widgets
  List<Widget> getProfileSections(BuildContext context, Map<String, dynamic> userData);
}

/// Extension point for test customization
abstract class TestExtension extends LmsExtension {
  /// Called before test starts
  Future<void> onTestStart(String testId, String studentId);
  
  /// Called after test submission
  Future<void> onTestSubmit(String testId, String studentId, int score, bool passed);
  
  /// Get additional test UI elements
  Widget? getTestHeader(BuildContext context, Map<String, dynamic> testData);
}

/// Extension point for content customization
abstract class ContentExtension extends LmsExtension {
  /// Process content before display
  Map<String, dynamic> processContent(Map<String, dynamic> content);
  
  /// Get additional content actions
  List<Widget> getContentActions(BuildContext context, Map<String, dynamic> content);
}

/// Extension registry
class ExtensionRegistry {
  static final ExtensionRegistry _instance = ExtensionRegistry._internal();
  factory ExtensionRegistry() => _instance;
  ExtensionRegistry._internal();

  final Map<String, List<LmsExtension>> _extensions = {};

  /// Register an extension
  void register<T extends LmsExtension>(T extension) {
    final type = T.toString();
    _extensions[type] ??= [];
    _extensions[type]!.add(extension);
    _extensions[type]!.sort((a, b) => b.priority.compareTo(a.priority));
    debugPrint('🔧 Extension registered: ${extension.name} (${extension.id})');
  }

  /// Get all extensions of a type
  List<T> getExtensions<T extends LmsExtension>() {
    final type = T.toString();
    return (_extensions[type] ?? []).cast<T>();
  }

  /// Execute navigation extensions
  List<NavigationItem> getNavigationItems(BuildContext context) {
    final items = <NavigationItem>[];
    for (final ext in getExtensions<NavigationExtension>()) {
      items.addAll(ext.getNavigationItems(context));
    }
    items.sort((a, b) => a.order.compareTo(b.order));
    return items;
  }

  /// Execute dashboard extensions
  List<Widget> getDashboardWidgets(BuildContext context) {
    final widgets = <Widget>[];
    for (final ext in getExtensions<DashboardExtension>()) {
      widgets.addAll(ext.getDashboardWidgets(context));
    }
    return widgets;
  }
}

/// Built-in navigation extension for LMS
class LmsNavigationExtension extends NavigationExtension {
  @override
  String get id => 'lms_navigation';

  @override
  String get name => 'LMS Navigation';

  @override
  int get priority => 100;

  @override
  List<NavigationItem> getNavigationItems(BuildContext context) {
    return const [
      NavigationItem(id: 'home', label: 'Home', icon: Icons.home, route: '/', order: 0),
      NavigationItem(id: 'courses', label: 'Courses', icon: Icons.book, route: '/content', order: 1),
      NavigationItem(id: 'tests', label: 'Tests', icon: Icons.quiz, route: '/tests', order: 2),
      NavigationItem(id: 'attendance', label: 'Attendance', icon: Icons.calendar_today, route: '/attendance', order: 3),
    ];
  }
}

/// Built-in dashboard extension for quick stats
class QuickStatsDashboardExtension extends DashboardExtension {
  @override
  String get id => 'quick_stats';

  @override
  String get name => 'Quick Stats';

  @override
  int get priority => 100;

  @override
  List<Widget> getDashboardWidgets(BuildContext context) {
    return [
      const _QuickStatsWidget(),
    ];
  }
}

class _QuickStatsWidget extends StatelessWidget {
  const _QuickStatsWidget();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Stats', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _StatItem(icon: Icons.book, label: 'Courses', value: '0'),
                _StatItem(icon: Icons.quiz, label: 'Tests', value: '0'),
                _StatItem(icon: Icons.check_circle, label: 'Completed', value: '0'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
