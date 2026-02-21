# Seed data for LMS

To populate the dataset with sample data so the Flutter app does not show empty screens:

1. **Get a token**: In [sanity.io/manage](https://sanity.io/manage), open your project → API → Tokens, create a token with "Editor" permissions.

2. **NDJSON import**

   - **Medium** (2 courses, 4 subjects, 8 chapters, 16 concepts, 4 assignments, 2 tests, 2 teachers with full profiles, 10 students, 1 banner):
     ```bash
     cd lms-studio
     npx sanity@latest dataset import seed-medium.json production --replace
     ```
   - **Large / stress** (5 courses, 15 subjects, 50 chapters, **117 concepts**, 50 assignments, 60 questions, 15 tests, 3 teachers with **subjects teaching + full profiles**, 20 students, 1 banner). Generate and import:
     ```bash
     cd lms-studio
     node scripts/generate-large-seed.mjs > seed-large.json
     npx sanity@latest dataset import seed-large.json production --replace
     ```
   Replace `production` with your dataset name if different. Use **`--replace`** so existing documents with the same IDs are updated (required if you've already imported once). Use **`--missing`** to only add documents that don't exist.

3. **Run the seed script** (alternative):
   ```bash
   cd lms-studio
   SANITY_TOKEN=your_token node scripts/seed.mjs
   ```
   Or use the Flutter app's in-app mock data (see main README "Seed data (Sanity)").

4. **Manual option**: Create documents in Sanity Studio: at least one **Course**, one **Student** (with enrolled courses), one **Assessment** (with worksheet/questions), and optionally **testAttempt**, **adBanner**. Publish them.
