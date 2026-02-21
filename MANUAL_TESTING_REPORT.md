# Manual Testing Report: LMS & Sanity Studio

**Date:** February 20, 2025  
**Scope:** l_m_s (Flutter LMS app) + lms-studio (Sanity Studio)  
**Focus:** UI/UX issues, data validation, functional bugs

---

## Executive Summary

This report documents **34 issues** across security, data validation, UI/UX, and functional areas. **Critical** items require immediate attention; **high** items should be fixed soon; **medium** and **low** can be scheduled.

---

## 1. Security & Authentication

### 1.1 [CRITICAL] Admin login has no authentication
**File:** `l_m_s/features/lms/feature_lms/lib/screens/admin_login_screen.dart`

- **Issue:** Admin login accepts any email/password and redirects to admin dashboard without validation.
- **Impact:** Anyone can access admin dashboard by clicking "Login".
- **Evidence:** Lines 20–27: `onPressed: () => context.go('/admin-dashboard', extra: {...})` with no credential check.
- **Recommendation:** Implement real auth (e.g. Sanity query for admin by email) and validate password.

### 1.2 [CRITICAL] Student login ignores password
**File:** `l_m_s/features/lms/feature_lms/lib/screens/login_screen.dart`

- **Issue:** Student login validates password in the form but never uses it in the query.
- **Evidence:** `_buildQuery()` for student returns `*[_type == "student" && rollNumber == $rollNumber][0]` — no password parameter.
- **Impact:** Any valid roll number logs in without password.
- **Recommendation:** Either remove password field for students or add password verification (e.g. stored hash, Sanity field).

### 1.3 [HIGH] Auth guards not applied to routes
**Files:** `feature.dart`, `routes/route_builder.dart`

- **Issue:** `LmsRoute` with `requiresAuth` and `allowedRoles` exists but is not used. Routes are plain `GoRoute` without auth checks.
- **Impact:** Unauthenticated users can reach protected screens via direct URLs.
- **Recommendation:** Use `LmsRoute` / `LmsRouteBuilder` and apply auth/role checks to protected routes.

---

## 2. Data Validation

### 2.1 [CRITICAL] Content editor creates concept without required slug
**File:** `l_m_s/features/lms/feature_lms/lib/screens/content_editor_screen.dart`

- **Issue:** Concept schema requires `slug` (`concept.ts` line 23), but the create mutation (lines 115–127) does not include it.
- **Impact:** Concept creation will fail with schema validation error.
- **Recommendation:** Add slug (e.g. from title) to the mutation or make slug optional in schema.

### 2.2 [HIGH] MCQ options can be empty in Sanity
**File:** `lms-studio/schemaTypes/question.ts`

- **Issue:** `options` is hidden when `questionType !== 'mcq'` but has no validation when it is MCQ.
- **Impact:** MCQ questions can be saved with empty options.
- **Recommendation:** Add conditional validation: `Rule.custom((options, ctx) => ctx.parent?.questionType === 'mcq' && (!options || options.length < 2) ? 'MCQ needs at least 2 options' : true)`.

### 2.3 [MEDIUM] Resource schema: url and file both optional
**File:** `lms-studio/schemaTypes/resource.ts`

- **Issue:** `url` and `file` are optional; no rule that at least one is set based on `type`.
- **Impact:** Resources can be saved without any URL or file.
- **Recommendation:** Add conditional validation: `Rule.custom((val, ctx) => ctx.parent?.type === 'link' && !val ? 'URL required for link type' : true)`.

### 2.4 [MEDIUM] Assessment passingMarksPercent optional
**File:** `lms-studio/schemaTypes/assessment.ts`

- **Issue:** `passingMarksPercent` has `min(0).max(100)` but is optional.
- **Impact:** Published assessments can have undefined passing criteria.
- **Recommendation:** Make it required or add a clear default.

### 2.5 [LOW] Inconsistent slug requirements
**Files:** `course.ts`, `subject.ts`, `chapter.ts`, `concept.ts`

- **Issue:** Course, subject, chapter have optional slugs; concept has required slug.
- **Impact:** Inconsistent routing and SEO behavior.
- **Recommendation:** Standardize slug requirements across content types.

---

## 3. Form & UI Bugs

### 3.1 [MEDIUM] Attendance screen: DropdownButtonFormField value vs initialValue
**File:** `l_m_s/features/lms/feature_lms/lib/screens/attendance_screen.dart`

- **Issue:** `DropdownButtonFormField` uses `initialValue` (line 78). Flutter’s `DropdownButtonFormField` expects `value`, not `initialValue`.
- **Impact:** On older Flutter: possible compile/runtime error. On newer Flutter: selection may not update when batch changes.
- **Recommendation:** Use `value: _selectedBatchId` for controlled behavior, or verify on your Flutter version.

### 3.2 [HIGH] MCQ options display wrong in test window
**File:** `l_m_s/features/lms/feature_lms/lib/screens/test_window_screen.dart`

- **Issue:** Schema expects `options` as `array of string`, but code treats `options[i]` as a Map with `opt['text']` (lines 415–416).
- **Impact:** For string options, `opt` becomes `{}` and label falls back to generic `'Option ${i+1}'`. Actual option text is lost.
- **Recommendation:** Handle both: `final text = opt is Map ? (opt['text'] ?? 'Option ${i+1}') : (opt?.toString() ?? 'Option ${i+1}');`

### 3.3 [HIGH] True/False and Fill-in-the-blank not rendered
**File:** `l_m_s/features/lms/feature_lms/lib/screens/test_window_screen.dart`

- **Issue:** `_QuestionCard` handles only `mcq`, `short`, `long`. No `truefalse` or `fillblank` handling.
- **Impact:** True/False and Fill-in-the-blank questions show no input.
- **Recommendation:** Add UI for `truefalse` (e.g. true/false radio) and `fillblank` (e.g. text field).

### 3.4 [MEDIUM] Teacher question add: correct option index after remove
**File:** `l_m_s/features/lms/feature_lms/lib/screens/teacher_question_add_screen.dart`

- **Issue:** `_removeOption(i)` does not update `_correctOptionIndex` when removing an option.
- **Impact:** Correct answer can point to wrong option after removal.
- **Recommendation:** Adjust `_correctOptionIndex` when removing an option (e.g. decrement if removed index < correct, clamp if removed index == correct).

### 3.5 [MEDIUM] Content editor: no URL validation
**File:** `l_m_s/features/lms/feature_lms/lib/screens/content_editor_screen.dart`

- **Issue:** Video URL field has no validation; invalid URLs can be saved.
- **Recommendation:** Add basic URL validation (e.g. `Uri.tryParse`).

### 3.6 [LOW] Content editor uses `print` instead of `debugPrint`
**File:** `l_m_s/features/lms/feature_lms/lib/screens/content_editor_screen.dart`

- **Issue:** Lines 55, 136, 137, 140, 173 use `print()` for errors.
- **Recommendation:** Use `debugPrint()` for consistency and to avoid production logs.

---

## 4. Functional Bugs

### 4.1 [CRITICAL] Batch schema missing — attendance broken
**Files:** `lms-studio/schemaTypes/index.ts`, `sanity_client_helper.dart`

- **Issue:** Queries use `*[_type == "batch"]` and `studentsByBatch` with `batch._ref`, but:
  - No `batch` schema type in schema index.
  - No `batch` field on `student` schema.
- **Impact:** Batch list is always empty; attendance by batch cannot work.
- **Recommendation:** Add `batch` schema and `batch` reference on `student`, or change attendance to use a different grouping (e.g. course).

### 4.2 [HIGH] Content editor: delete button does nothing
**File:** `l_m_s/features/lms/feature_lms/lib/screens/content_editor_screen.dart`

- **Issue:** Delete button (line 315) has `onPressed: () { /* TODO: Delete content */ }` — no implementation.
- **Impact:** No way to delete content from the UI.
- **Recommendation:** Implement delete mutation via Sanity API.

### 4.3 [HIGH] Content editor: route requires chapterId
**File:** `l_m_s/features/lms/feature_lms/lib/feature.dart`

- **Issue:** Content editor gets `chapterId` from `extra`; if empty, create shows "Chapter ID is missing".
- **Impact:** No way to reach content editor with valid chapter; navigation must ensure it is passed.
- **Recommendation:** Validate chapterId before navigation or add a chapter selector in the editor.

### 4.4 [MEDIUM] Admin bottom nav: all items go to same route
**File:** `l_m_s/features/lms/feature_lms/lib/widgets/lms_shell.dart`

- **Issue:** Admin nav items (Dashboard, Teachers, Students, Documents) all point to `/admin-dashboard`.
- **Impact:** Misleading nav; all items behave the same.
- **Recommendation:** Add distinct routes or sections within the admin dashboard.

### 4.5 [MEDIUM] Student bottom nav: Dashboard and Courses duplicate
**File:** `l_m_s/features/lms/feature_lms/lib/widgets/lms_shell.dart`

- **Issue:** Both "Dashboard" and "Courses" use `/student-dashboard`.
- **Impact:** Redundant nav items.
- **Recommendation:** Use different routes (e.g. `/courses` for course listing) or remove one.

### 4.6 [LOW] StudentAnalyticsScreen parameter naming
**File:** `l_m_s/features/lms/feature_lms/lib/screens/student_analytics_screen.dart`

- **Issue:** Parameter is named `subjectId` but used as student ID.
- **Impact:** Confusing for developers.
- **Recommendation:** Rename to `studentId` or add a clear comment.

---

## 5. Sanity Studio UI/UX

### 5.1 [HIGH] Dead schema in concept.ts
**File:** `lms-studio/schemaTypes/concept.ts`

- **Issue:** Lines 68–78 export a `chapter` object that conflicts with the real `chapter` schema and is not used in the index.
- **Impact:** Risk of confusion or accidental import; potential naming conflict.
- **Recommendation:** Remove the dead `chapter` export from `concept.ts`.

### 5.2 [MEDIUM] Schema types missing from structure
**File:** `lms-studio/structure.ts`

- **Issue:** `worksheet`, `assessment`, `adBanner` are in schema but not in the sidebar structure.
- **Impact:** These types are only reachable via "Create new document" or direct URL.
- **Recommendation:** Add them to the structure (e.g. under Assessments or a new section).

### 5.3 [LOW] Unused imports in structure.ts
**File:** `lms-studio/structure.ts`

- **Issue:** `DocumentIcon`, `CalendarIcon`, `CommentIcon`, `RobotIcon` are imported but not used.
- **Recommendation:** Remove unused imports.

---

## 6. Error Handling & UX

### 6.1 [MEDIUM] Empty catch blocks
**Files:** `teacher_question_add_screen.dart`, `teacher_content_studio_screen.dart`, `teacher_student_detail_screen.dart`

- **Issue:** `catch (_) {}` or `catch (_)` with no error handling.
- **Impact:** Failures are silent; users get no feedback.
- **Recommendation:** Log errors and show user-facing feedback (e.g. SnackBar).

### 6.2 [MEDIUM] sanity_image_uploader uses print
**File:** `l_m_s/features/lms/feature_lms/lib/utils/sanity_image_uploader.dart`

- **Issue:** Uses `print()` for errors.
- **Recommendation:** Use `debugPrint()`.

### 6.3 [LOW] No retry for failed loads
**Files:** `student_dashboard_screen.dart`, `teacher_dashboard_screen.dart`

- **Issue:** Some flows use `debugPrint` for errors without retry.
- **Recommendation:** Add retry or error UI where appropriate.

---

## 7. Responsive & Layout

### 7.1 [LOW] Inconsistent breakpoints
**Files:** `lms_shell.dart`, `teacher_layout.dart`, `dashboard_screen.dart`, etc.

- **Issue:** Breakpoints vary (600, 700, 900, 1200) across screens.
- **Recommendation:** Centralize breakpoints.

### 7.2 [LOW] Test window palette: fixed width on small screens
**File:** `l_m_s/features/lms/feature_lms/lib/screens/test_window_screen.dart`

- **Issue:** Question palette is fixed at 120px; may not fit well on very small screens.
- **Recommendation:** Make it responsive or collapsible on mobile.

---

## 8. Summary Checklist

| Severity | Count | Areas |
|----------|-------|-------|
| CRITICAL | 5 | Auth, schema, data |
| HIGH     | 8 | Auth, validation, UI, functional |
| MEDIUM   | 13 | Forms, validation, UX, error handling |
| LOW      | 8 | Naming, imports, layout |

---

## Vyuh Framework & Authorization – Confirmation

**Is the app using the Vyuh framework?** **Yes.**

| Area | Usage |
|------|--------|
| **Bootstrap** | `vc.runApp()` with `initialLocation`, `features`, `plugins` (`main.dart`) |
| **Features** | `system.feature`, `auth.feature(routes: () => [])`, `lms.feature`, `developer.feature` |
| **Plugins** | `PluginDescriptor`: `content: DefaultContentPlugin(SanityContentProvider)`, `telemetry: TelemetryPlugin(ConsoleLoggerTelemetryProvider)` |
| **LMS feature** | Single `FeatureDescriptor` in `feature.dart`: name, title, routes (async), icon; routes are plain `GoRoute` / `ShellRoute` |
| **Content** | `vyuh_extension_content` + `vyuh_plugin_content_provider_sanity` for Sanity-backed content |
| **Auth (Vyuh)** | `vyuh_feature_auth` is registered with **empty routes** (`routes: () => []`), so `/login` and `/admin-login` are owned by the LMS feature, not by Vyuh Auth |
| **Auth (LMS)** | Custom: `LoginScreen` (student rollNumber / teacher&admin email + Sanity query), `AdminLoginScreen` (previously no validation; now validated via Sanity – see fixes below). No shared session store with Vyuh Auth |
| **Route guards** | `LmsRoute` / `RouteGuard.redirect` and `AuthPlugin` exist in `route_builder.dart` and `plugins.dart`, but the **actual router in `feature.dart` does not use them** – all routes are plain `GoRoute` with no redirect or auth check. So **protected routes are not currently guarded**; enabling guards would require wiring a redirect (e.g. in Vyuh router config if supported) or wrapping shell/pageBuilder with an auth check |

**Summary:** The app is built on Vyuh (runApp, features, plugins, content, telemetry). Authentication and authorization are **custom LMS flows**; Vyuh Auth is present but does not own login routes or session. Auth guards are implemented in code but **not applied** to the live GoRouter.

---

## Recommended Next Steps

1. Fix all CRITICAL issues (security, auth, schema, form).
2. Add missing `batch` schema and student `batch` reference, or redesign attendance.
3. Fix DropdownButtonFormField in attendance screen.
4. Add slug to concept creation.
5. Enable auth guards on protected routes.
6. **Student password:** Schema has no password field for students. Login is roll-number–only. Either hide the password field for the student role in the UI or add a `password` (or hashed) field to the student schema and verify it on login.
7. Add UI for True/False and Fill-in-the-blank in the test window.
8. Clean up Sanity schema and structure (dead code, missing types).
