# LMS - Learning Management System

A Flutter-based LMS with Sanity CMS backend, built using the Vyuh framework. Students can browse content, view attendance, and take tests in a dedicated test window. Content (courses, questions, worksheets) is managed in Sanity Studio.

## Architecture

- **Frontend**: Flutter app (`l_m_s/apps/l_m_s/`) – student-facing LMS (dashboard, content, attendance, tests).
- **CMS**: Sanity Studio (`lms-studio/`) – manage courses, concepts, worksheets, questions, assessments, students, and attendance.

## Run on localhost

### Prerequisites

- **Node.js** (v18+) and **pnpm** (or npm)
- **Flutter** (SDK ^3.10.8)

### Terminal 1: Sanity Studio

```bash
cd lms-studio
pnpm install   # first time only
pnpm dev
```

→ **http://localhost:3333**

### Terminal 2: Flutter app

```bash
cd l_m_s/apps/l_m_s
flutter pub get   # first time only
flutter run -d chrome
```

→ **http://localhost:8080** (or the port shown)

### Routes in the app

| Route        | Description                          |
|-------------|--------------------------------------|
| `/`         | Dashboard (Content, Attendance, Tests) |
| `/content`  | Courses & worksheets                 |
| `/attendance` | Attendance records                 |
| `/tests`    | List of assessments                  |
| `/test/:id` | Full-screen test window             |

## Environment variables and API keys

You only need a **Sanity project ID** and **dataset** (e.g. `production`). No API key is required for reading published content.

| What        | Where to set |
|------------|----------------|
| **Sanity** | `lms-studio/sanity.config.ts`: `projectId`, `dataset`. Get project ID from [sanity.io/manage](https://www.sanity.io/manage). |
| **Flutter** | Defaults in code (`w18438cu` / `production`). Override with: `flutter run --dart-define=SANITY_PROJECT_ID=xxx --dart-define=SANITY_DATASET=production` |

Optional: **Sanity API token** – only if you need to read **draft** content; create a Viewer token at [sanity.io/manage](https://www.sanity.io/manage) → Project → API → Tokens. Never commit it.

→ Full details: **[ENV.md](./ENV.md)**  
→ Example file: **`l_m_s/apps/l_m_s/.env.example`**

## Vercel deployment

See **[GITHUB_SECRETS.md](./GITHUB_SECRETS.md)** for required GitHub Secrets. The workflow `.github/workflows/deploy-lms-vercel.yml` builds Flutter web and deploys to Vercel on push to `main`.

## Project structure

```
learning mangement system/
├── ENV.md                 # Environment variables & API keys
├── README.md              # This file
├── GITHUB_SECRETS.md      # GitHub Secrets for Vercel deploy
├── lms-studio/            # Sanity CMS
│   ├── schemaTypes/       # course, concept, question, worksheet, assessment, student, attendance, testAttempt
│   ├── sanity.config.ts
│   └── structure.ts
└── l_m_s/
    ├── apps/l_m_s/        # Flutter app (main.dart, .env.example)
    └── features/lms/feature_lms/
        ├── lib/screens/   # dashboard, content, attendance, tests, test_window
        └── sanity_client_helper.dart
```

## Creating content (Sanity Studio)

1. **Course** – Content → Courses (title, slug, description).
2. **Questions** – Content → Questions (text, type: MCQ/Short/Long, options, solution, images).
3. **Worksheet** – Content → Worksheets (link course + questions).
4. **Assessment** – Assessments → Tests (link worksheet, duration, passing %).
5. **Students** – People & Records → Students.
6. **Attendance** – People & Records → Attendance (student, date, status).

## Troubleshooting

- **Sanity won't start**: `cd lms-studio && rm -rf node_modules .sanity && pnpm install && pnpm dev`
- **Flutter**: `flutter clean && flutter pub get`
- **Port in use**: Flutter web: `flutter run -d web-server --web-port=8081`
- **App can't reach Sanity**: Same `projectId` and `dataset` in `lms-studio/sanity.config.ts` and Flutter (see ENV.md).

## Auth

`vyuh_feature_auth` is registered; routes like `/login`, `/signup` can be wired and enforced as needed.

## Docs

- [Sanity](https://www.sanity.io/docs) · [Vyuh](https://docs.vyuh.tech) · [Flutter](https://docs.flutter.dev)
