# L M S

A Vyuh Flutter project created by Vyuh CLI.

> This app is powered by the [Vyuh Framework](https://vyuh.tech).

## Technologies at play

- Dart
- Flutter
- Node.js
- Vyuh Framework

## Getting Started

- All apps are in the `/apps` directory. This includes the Flutter App and the
  Sanity Studio (if using the CMS)
- All plugins are in the `/plugins` directory
- All features are in the `/features` directory
- All shared packages are in the `/packages` directory

## Seed data (Sanity)

To avoid blank screens in a new install, seed the Sanity dataset with sample data:

1. **Option A – Sanity Studio**: In the LMS Studio project (`lms-studio/`), create a few documents manually: **Course**, **Student** (with enrolled courses), **Subject**, **Chapter**, **Assessment** / **Worksheet** with questions, **testAttempt**, **batch**, **adBanner**. Publish them.

2. **Option B – Seed script**: From repo root, with a Sanity write token:
   - `cd lms-studio && SANITY_TOKEN=your_token node scripts/seed.mjs`
   - Creates a sample course and student. See `lms-studio/scripts/seed.md` for details.

3. **In-app fallback**: The Flutter app uses mock data (see `features/lms/feature_lms/lib/utils/mock_data.dart`) when Sanity returns empty lists for dashboard and analytics, so you can run the app without seed data; labels indicate demo content.
