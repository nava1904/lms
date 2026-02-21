# Environment Variables & API Keys

This document lists all environment variables and API keys used by the LMS project.

---

## Sanity CMS (lms-studio + Flutter app)

### Required

| Variable | Where used | Description |
|----------|------------|-------------|
| **Project ID** | `lms-studio/sanity.config.ts` + Flutter app | Your Sanity project ID (e.g. `w18438cu`). Find it at [sanity.io/manage](https://www.sanity.io/manage) → your project → **Project ID**. |
| **Dataset** | Same as above | Dataset name, usually `production` or `development`. |

### Where to set them

1. **Sanity Studio** (`lms-studio`):  
   Edit `lms-studio/sanity.config.ts`:
   ```ts
   projectId: 'YOUR_PROJECT_ID',  // e.g. 'w18438cu'
   dataset: 'production',
   ```

2. **Flutter app**:  
   Defaults are in code (`w18438cu` / `production`). To override at build time:
   ```bash
   flutter run --dart-define=SANITY_PROJECT_ID=your_project_id --dart-define=SANITY_DATASET=production
   ```
   Or change defaults in:
   - `l_m_s/apps/l_m_s/lib/main.dart` (content provider config)
   - `l_m_s/features/lms/feature_lms/lib/sanity_client_helper.dart` (LMS screens)

### Optional: Sanity API token (for draft content)

If you need to **read draft content** from the Flutter app or from scripts:

| Variable | Where | Description |
|----------|--------|-------------|
| **SANITY_API_TOKEN** | Flutter (future) / scripts | Create at [sanity.io/manage](https://www.sanity.io/manage) → Project → API → Tokens. Use **Viewer** or **Editor** scope. |

- With a token you can set `perspective: Perspective.drafts` (or `raw`) and `useCdn: false` in the Sanity config.  
- **Never commit the token.** Use `.env` (and add `.env` to `.gitignore`) or CI secrets.

---

## Flutter app (.env) – optional

The app has an `apps/l_m_s/.env` file in `assets` for future use (e.g. `flutter_dotenv`). Right now Sanity config uses **dart-define** or code defaults.

If you add more keys later (e.g. Firebase, analytics), use:

- **File:** `l_m_s/apps/l_m_s/.env`
- **Example:** `l_m_s/apps/l_m_s/.env.example`

Example contents for later:

```env
# Sanity (optional – can use dart-define instead)
SANITY_PROJECT_ID=w18438cu
SANITY_DATASET=production

# Future: Firebase / Auth
# FIREBASE_API_KEY=...
# FIREBASE_PROJECT_ID=...
```

Keep `.env` out of version control; commit only `.env.example` with placeholder values.

---

## Summary

| What you need | Action |
|---------------|--------|
| **Run Sanity Studio** | Set `projectId` and `dataset` in `lms-studio/sanity.config.ts` (or use existing values). |
| **Run Flutter app** | No env vars required if you keep the default project ID/dataset. For a different project, use `--dart-define=SANITY_PROJECT_ID=...` and `SANITY_DATASET=...` or change defaults in code. |
| **Draft content in app** | Create a Sanity API token (Viewer), store it securely, and use it in the Sanity client config with `perspective: Perspective.drafts` and `useCdn: false`. |

No other API keys are required for the current LMS setup (student app + Sanity Studio).
