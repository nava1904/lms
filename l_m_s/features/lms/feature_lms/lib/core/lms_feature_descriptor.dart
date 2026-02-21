import 'package:vyuh_core/vyuh_core.dart';

/// LMS Feature Descriptor
/// Defines the LMS feature for the Vyuh framework.
class LmsFeatureDescriptor extends FeatureDescriptor {
  LmsFeatureDescriptor()
      : super(
          id: 'lms',
          name: 'Learning Management System',
          description: 'A comprehensive LMS with courses, tests, and analytics.',
          version: '1.0.0',
        );
}