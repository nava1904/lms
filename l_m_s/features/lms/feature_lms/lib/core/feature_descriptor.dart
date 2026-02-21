// filepath: /Users/navadeepreddy/learning mangement system/l_m_s/features/lms/feature_lms/lib/core/feature_descriptor.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Vyuh-style Feature Descriptor
/// Defines the complete feature configuration including routes, extensions, and plugins
abstract class FeatureDescriptor {
  /// Unique identifier for this feature
  String get name;
  
  /// Human-readable title
  String get title;
  
  /// Feature description
  String get description;
  
  /// Feature icon
  IconData get icon;
  
  /// Feature routes
  List<RouteBase> get routes;
  
  /// Content builders for CMS content types
  Map<String, ContentBuilder> get contentBuilders => {};
  
  /// Extension points this feature provides
  List<ExtensionPoint> get extensionPoints => [];
  
  /// Extensions this feature contributes to other features
  List<Extension> get extensions => [];
  
  /// Plugins required by this feature
  List<Plugin> get plugins => [];
  
  /// Initialize the feature
  Future<void> init() async {}
  
  /// Dispose the feature
  Future<void> dispose() async {}
}

/// Content Builder - Maps CMS content types to Flutter widgets
typedef ContentBuilder = Widget Function(BuildContext context, Map<String, dynamic> content);

/// Extension Point - Defines where other features can extend this feature
class ExtensionPoint {
  final String id;
  final String name;
  final String description;
  final Type expectedType;
  
  const ExtensionPoint({
    required this.id,
    required this.name,
    required this.description,
    required this.expectedType,
  });
}

/// Extension - A contribution to an extension point
class Extension {
  final String targetFeature;
  final String extensionPointId;
  final dynamic value;
  
  const Extension({
    required this.targetFeature,
    required this.extensionPointId,
    required this.value,
  });
}

/// Plugin - Modular functionality that can be added to features
abstract class Plugin {
  String get name;
  Future<void> init();
  Future<void> dispose();
}

/// Feature Registry - Manages all registered features
class FeatureRegistry {
  static final FeatureRegistry _instance = FeatureRegistry._internal();
  factory FeatureRegistry() => _instance;
  FeatureRegistry._internal();
  
  final Map<String, FeatureDescriptor> _features = {};
  final List<Plugin> _plugins = [];
  
  /// Register a feature
  void register(FeatureDescriptor feature) {
    _features[feature.name] = feature;
  }
  
  /// Get a feature by name
  FeatureDescriptor? get(String name) => _features[name];
  
  /// Get all features
  List<FeatureDescriptor> get all => _features.values.toList();
  
  /// Get all routes from all features
  List<RouteBase> get allRoutes {
    return _features.values.expand((f) => f.routes).toList();
  }
  
  /// Register a plugin
  void registerPlugin(Plugin plugin) {
    _plugins.add(plugin);
  }
  
  /// Initialize all features and plugins
  Future<void> initAll() async {
    for (final plugin in _plugins) {
      await plugin.init();
    }
    for (final feature in _features.values) {
      await feature.init();
    }
  }
  
  /// Dispose all features and plugins
  Future<void> disposeAll() async {
    for (final feature in _features.values) {
      await feature.dispose();
    }
    for (final plugin in _plugins) {
      await plugin.dispose();
    }
  }
}
