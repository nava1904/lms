// filepath: /Users/navadeepreddy/learning mangement system/l_m_s/features/lms/feature_lms/lib/plugins/plugin_base.dart

import 'package:flutter/foundation.dart';

/// Base class for all LMS plugins following Vyuh patterns
abstract class LmsPlugin {
  /// Unique identifier for this plugin
  String get id;
  
  /// Display name
  String get name;
  
  /// Plugin version
  String get version;
  
  /// Whether the plugin is enabled
  bool get isEnabled;
  
  /// Initialize the plugin
  Future<void> initialize();
  
  /// Dispose the plugin
  Future<void> dispose();
}

/// Plugin registry to manage all plugins
class PluginRegistry {
  static final PluginRegistry _instance = PluginRegistry._internal();
  factory PluginRegistry() => _instance;
  PluginRegistry._internal();

  final Map<String, LmsPlugin> _plugins = {};

  /// Register a plugin
  void register(LmsPlugin plugin) {
    _plugins[plugin.id] = plugin;
    debugPrint('🔌 Plugin registered: ${plugin.name} v${plugin.version}');
  }

  /// Unregister a plugin
  void unregister(String pluginId) {
    _plugins.remove(pluginId);
  }

  /// Get a plugin by ID
  T? getPlugin<T extends LmsPlugin>(String id) {
    return _plugins[id] as T?;
  }

  /// Get all plugins
  List<LmsPlugin> get allPlugins => _plugins.values.toList();

  /// Initialize all plugins
  Future<void> initializeAll() async {
    for (final plugin in _plugins.values) {
      if (plugin.isEnabled) {
        await plugin.initialize();
      }
    }
  }

  /// Dispose all plugins
  Future<void> disposeAll() async {
    for (final plugin in _plugins.values) {
      await plugin.dispose();
    }
  }
}
