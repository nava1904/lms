import 'package:flutter/material.dart';

/// App-level theme mode for Erudex-style dark/light toggle.
/// Not persisted (add shared_preferences in app if needed).
class ThemeModeHolder {
  ThemeModeHolder._();
  static final ValueNotifier<ThemeMode> notifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  static ThemeMode get value => notifier.value;
  static set value(ThemeMode v) {
    if (notifier.value != v) {
      notifier.value = v;
    }
  }

  static void toggle() {
    value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

/// Provides [ThemeModeHolder.notifier] to descendants; wrap shell or app root.
class ThemeModeScope extends InheritedWidget {
  const ThemeModeScope({
    super.key,
    required this.notifier,
    required super.child,
  });

  final ValueNotifier<ThemeMode> notifier;

  static ValueNotifier<ThemeMode> of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeModeScope>();
    return scope?.notifier ?? ThemeModeHolder.notifier;
  }

  @override
  bool updateShouldNotify(ThemeModeScope oldWidget) =>
      oldWidget.notifier != notifier;
}
