// filepath: /Users/navadeepreddy/learning mangement system/l_m_s/features/lms/feature_lms/lib/core/extension_points.dart
import 'package:flutter/material.dart';
import 'feature_descriptor.dart';

/// LMS Extension Points
/// These are the points where other features can extend the LMS functionality

class LmsExtensionPoints {
  /// Dashboard widgets - Add custom widgets to dashboards
  static const dashboardWidgets = ExtensionPoint(
    id: 'lms.dashboard.widgets',
    name: 'Dashboard Widgets',
    description: 'Add custom widgets to role-specific dashboards',
    expectedType: Widget,
  );
  
  /// Content renderers - Add custom content type renderers
  static const contentRenderers = ExtensionPoint(
    id: 'lms.content.renderers',
    name: 'Content Renderers',
    description: 'Add custom renderers for CMS content types',
    expectedType: Widget,
  );
  
  /// Assessment types - Add custom assessment types
  static const assessmentTypes = ExtensionPoint(
    id: 'lms.assessment.types',
    name: 'Assessment Types',
    description: 'Add custom assessment types beyond MCQ',
    expectedType: Widget,
  );
  
  /// Navigation items - Add items to navigation menus
  static const navigationItems = ExtensionPoint(
    id: 'lms.navigation.items',
    name: 'Navigation Items',
    description: 'Add items to role-specific navigation menus',
    expectedType: NavigationDestination,
  );
  
  /// Report generators - Add custom report types
  static const reportGenerators = ExtensionPoint(
    id: 'lms.reports.generators',
    name: 'Report Generators',
    description: 'Add custom report generation capabilities',
    expectedType: Function,
  );
  
  /// All extension points
  static List<ExtensionPoint> get all => [
    dashboardWidgets,
    contentRenderers,
    assessmentTypes,
    navigationItems,
    reportGenerators,
  ];
}

/// Extension Manager - Manages extensions for the LMS
class ExtensionManager {
  static final ExtensionManager _instance = ExtensionManager._internal();
  factory ExtensionManager() => _instance;
  ExtensionManager._internal();
  
  final Map<String, List<dynamic>> _extensions = {};
  
  /// Register an extension
  void register(String extensionPointId, dynamic extension) {
    _extensions.putIfAbsent(extensionPointId, () => []);
    _extensions[extensionPointId]!.add(extension);
  }
  
  /// Get all extensions for a point
  List<T> get<T>(String extensionPointId) {
    return (_extensions[extensionPointId] ?? []).cast<T>();
  }
  
  /// Get dashboard widgets for a role
  List<Widget> getDashboardWidgets(String role) {
    return get<DashboardWidgetExtension>(LmsExtensionPoints.dashboardWidgets.id)
        .where((ext) => ext.roles.contains(role) || ext.roles.contains('all'))
        .map((ext) => ext.widget)
        .toList();
  }
  
  /// Get navigation items for a role
  List<NavigationDestination> getNavigationItems(String role) {
    return get<NavigationItemExtension>(LmsExtensionPoints.navigationItems.id)
        .where((ext) => ext.roles.contains(role) || ext.roles.contains('all'))
        .map((ext) => ext.destination)
        .toList();
  }
}

/// Dashboard Widget Extension
class DashboardWidgetExtension {
  final String id;
  final String title;
  final Widget widget;
  final List<String> roles; // Which roles can see this widget
  final int order;
  
  const DashboardWidgetExtension({
    required this.id,
    required this.title,
    required this.widget,
    required this.roles,
    this.order = 100,
  });
}

/// Navigation Item Extension
class NavigationItemExtension {
  final String id;
  final NavigationDestination destination;
  final Widget Function() screenBuilder;
  final List<String> roles;
  final int order;
  
  const NavigationItemExtension({
    required this.id,
    required this.destination,
    required this.screenBuilder,
    required this.roles,
    this.order = 100,
  });
}

/// Content Renderer Extension
class ContentRendererExtension {
  final String contentType;
  final Widget Function(BuildContext, Map<String, dynamic>) builder;
  
  const ContentRendererExtension({
    required this.contentType,
    required this.builder,
  });
}

/// Assessment Type Extension
class AssessmentTypeExtension {
  final String id;
  final String name;
  final String description;
  final Widget Function(Map<String, dynamic> question, Function(String) onAnswer) questionWidget;
  final bool Function(String answer, Map<String, dynamic> question) grader;
  
  const AssessmentTypeExtension({
    required this.id,
    required this.name,
    required this.description,
    required this.questionWidget,
    required this.grader,
  });
}

/// Example: Register built-in extensions
void registerBuiltInExtensions() {
  final manager = ExtensionManager();
  
  // Example: Quick stats widget for admin dashboard
  manager.register(
    LmsExtensionPoints.dashboardWidgets.id,
    DashboardWidgetExtension(
      id: 'quick-stats',
      title: 'Quick Stats',
      widget: const _QuickStatsWidget(),
      roles: ['admin', 'teacher'],
      order: 1,
    ),
  );
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
            const SizedBox(height: 8),
            const Text('This is an extensible widget added via the extension system'),
          ],
        ),
      ),
    );
  }
}
