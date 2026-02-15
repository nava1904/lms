import 'package:sanity_client/sanity_client.dart';

/// Default Sanity project ID (override with --dart-define=SANITY_PROJECT_ID=xxx).
const String lmsSanityProjectId = String.fromEnvironment(
  'SANITY_PROJECT_ID',
  defaultValue: 'w18438cu',
);

/// Default Sanity dataset (override with --dart-define=SANITY_DATASET=xxx).
const String lmsSanityDataset = String.fromEnvironment(
  'SANITY_DATASET',
  defaultValue: 'production',
);

/// Creates a Sanity client for LMS GROQ queries.
/// Uses [lmsSanityProjectId] and [lmsSanityDataset] unless overridden.
SanityClient createLmsClient({
  String? projectId,
  String? dataset,
  bool useCdn = true,
}) {
  return SanityClient(
    SanityConfig(
      projectId: projectId ?? lmsSanityProjectId,
      dataset: dataset ?? lmsSanityDataset,
      useCdn: useCdn,
      apiVersion: 'v2024-01-01',
    ),
  );
}

/// GROQ fragments and queries for LMS content.
class LmsQueries {
  static const String courseList = r'''
    *[_type == "course"] | order(order asc) {
      _id,
      title,
      "slug": slug.current,
      description,
      order
    }
  ''';

  static const String worksheetList = r'''
    *[_type == "worksheet"] | order(order asc) {
      _id,
      title,
      "slug": slug.current,
      "course": course->{ _id, title },
      "questionCount": count(questions),
      order
    }
  ''';

  static const String assessmentList = r'''
    *[_type == "assessment"] {
      _id,
      title,
      "slug": slug.current,
      "worksheet": worksheet->{ _id, title },
      durationMinutes,
      openInSeparateWindow,
      passingMarksPercent
    }
  ''';

  static String assessmentById(String id) => '''
    *[_type == "assessment" && _id == \$id][0] {
      _id,
      title,
      durationMinutes,
      "worksheet": worksheet->{
        _id,
        "questions": questions[]->{
          _id,
          queText,
          type,
          options,
          solution,
          imageInQue,
          imageInSol,
          marks
        }
      }
    }
  ''';

  static const String conceptList = r'''
    *[_type == "concept"] | order(order asc) {
      _id,
      title,
      "slug": slug.current,
      "course": course->{ _id, title },
      order
    }
  ''';

  static const String attendanceList = r'''
    *[_type == "attendance"] | order(date desc) [0...50] {
      _id,
      date,
      status,
      "student": student->{ _id, name },
      notes
    }
  ''';

  static const String adBanner = r'''
    *[_type == "adBanner"] | order(_createdAt desc)[0] {
      _id,
      headline,
      image,
      callToAction
    }
  ''';
}
