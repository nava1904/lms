import 'package:flutter/material.dart';

/// Modular feature system for easy integration of AI and other features
abstract class LMSModule {
  String get name;
  String get description;
  
  Widget buildScreen(Map<String, dynamic> params);
}

// Example: AI Worksheet module (ready to integrate)
class AIWorksheetModule extends LMSModule {
  @override
  String get name => 'AI Worksheets';
  
  @override
  String get description => 'AI-powered adaptive worksheets';
  
  @override
  Widget buildScreen(Map<String, dynamic> params) {
    return const Scaffold(
      body: Center(
        child: Text('AI Worksheet Module - Ready for Integration'),
      ),
    );
  }
}

// Module registry for easy feature management
class ModuleRegistry {
  static final Map<String, LMSModule> _modules = {};
  
  static void registerModule(LMSModule module) {
    _modules[module.name] = module;
  }
  
  static LMSModule? getModule(String name) {
    return _modules[name];
  }
  
  static List<String> getAvailableModules() {
    return _modules.keys.toList();
  }
}

// Initialize modules
void initializeModules() {
  ModuleRegistry.registerModule(AIWorksheetModule());
  // Add more modules here as needed
}
