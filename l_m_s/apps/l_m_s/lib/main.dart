import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:feature_lms/feature_lms.dart' as lms;
import 'package:vyuh_core/vyuh_core.dart' as vc;
import 'package:vyuh_extension_content/vyuh_extension_content.dart';
import 'package:vyuh_feature_developer/vyuh_feature_developer.dart' as developer;
import 'package:vyuh_feature_auth/vyuh_feature_auth.dart' as auth;
import 'package:vyuh_feature_system/vyuh_feature_system.dart' as system;
import 'package:sanity_client/sanity_client.dart';
import 'package:vyuh_plugin_content_provider_sanity/vyuh_plugin_content_provider_sanity.dart' as sanity_plugin;
import 'package:feature_lms/lms_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  const projectId = String.fromEnvironment(
    'SANITY_PROJECT_ID',
    defaultValue: 'w18438cu',
  );
  const dataset = String.fromEnvironment(
    'SANITY_DATASET',
    defaultValue: 'production',
  );

  final contentProvider = sanity_plugin.SanityContentProvider.withConfig(
    config: SanityConfig(
      projectId: projectId,
      dataset: dataset,
      perspective: Perspective.published,
      useCdn: true,
    ),
    cacheDuration: const Duration(minutes: 5),
  );

  vc.runApp(
    initialLocation: '/',
    plugins: vc.PluginDescriptor(
      content: DefaultContentPlugin(provider: contentProvider),
    ),
    features: () => [
      system.feature,
      auth.feature(),
      lms.feature,
      developer.feature,
    ],
  );
  runApp(const LMSApp());
}
