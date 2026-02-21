import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:feature_lms/feature_lms.dart' as lms;
import 'package:feature_lms/sanity_client_helper.dart';
import 'package:vyuh_core/vyuh_core.dart' as vc;
import 'package:vyuh_extension_content/vyuh_extension_content.dart';
import 'package:vyuh_feature_auth/vyuh_feature_auth.dart' as auth;
import 'package:vyuh_feature_developer/vyuh_feature_developer.dart' as developer;
import 'package:vyuh_feature_system/vyuh_feature_system.dart' as system;
import 'package:sanity_client/sanity_client.dart';
import 'package:vyuh_plugin_content_provider_sanity/vyuh_plugin_content_provider_sanity.dart' as sanity_plugin;
import 'package:vyuh_plugin_telemetry_provider_console/vyuh_plugin_telemetry_provider_console.dart' as telemetry_console;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env from asset bundle. IMPORTANT: run from this app dir so .env is bundled:
  //   cd apps/l_m_s && flutter run -d chrome
  // Or pass token at build time: flutter run -d chrome --dart-define=SANITY_API_TOKEN=sk...
  await dotenv.load(fileName: '.env');

  // Token: .env first, then --dart-define (for web: flutter run -d chrome --dart-define=SANITY_API_TOKEN=sk...)
  const apiToken = String.fromEnvironment('SANITY_API_TOKEN', defaultValue: '');
  const envToken = String.fromEnvironment('SANITY_TOKEN', defaultValue: '');
  final sanityToken = dotenv.env['SANITY_API_TOKEN'] ??
      dotenv.env['SANITY_TOKEN'] ??
      (apiToken.isNotEmpty ? apiToken : envToken);
  // Normalize: remove all whitespace so header is valid
  final String? tokenOrNull = () {
    final t = sanityToken.replaceAll(RegExp(r'\s+'), '').trim();
    return t.isEmpty ? null : t;
  }();

  // So LMS login and other feature Sanity calls use the same token from .env
  SanityClientHelper.tokenOverride = tokenOrNull;
  // SanityService (Tests, teacher dashboard, etc.) also needs the token
  lms.LmsSanityConfig.setWriteToken(tokenOrNull ?? '');

  vc.runApp(
    initialLocation: '/',
    features: () => [
      system.feature,
      // Use LMS-owned /login (and /admin-login) instead of CMS route for /login
      auth.feature(routes: () => []),
      lms.feature,
      developer.feature,
    ],
    plugins: vc.PluginDescriptor(
      content: DefaultContentPlugin(
        provider: sanity_plugin.SanityContentProvider.withConfig(
          config: SanityConfig(
            projectId: dotenv.env['SANITY_PROJECT_ID'] ?? 'w18438cu',
            dataset: dotenv.env['SANITY_DATASET'] ?? 'production',
            perspective: Perspective.published,
            useCdn: true,
            apiVersion: 'v2024-01-01',
            token: tokenOrNull,
          ),
          cacheDuration: const Duration(hours: 1),
        ),
      ),
      telemetry: vc.TelemetryPlugin(
        providers: [telemetry_console.ConsoleLoggerTelemetryProvider()],
      ),
    ),
  );
}
