# GitHub Secrets for Vercel Deployment

Add these secrets in **Settings > Secrets and variables > Actions** for the deploy workflow to work.

## Required for Vercel Deploy

| Secret Name | Description | Where to Get |
|-------------|-------------|--------------|
| `VERCEL_TOKEN` | Vercel API token | [Vercel Account > Tokens](https://vercel.com/account/tokens) - Create new token |
| `VERCEL_ORG_ID` | Your Vercel team/org ID | Run `vercel link` in `l_m_s/apps/l_m_s/build/web`, then check `.vercel/project.json` |
| `VERCEL_PROJECT_ID` | Vercel project ID | Same as above - from `.vercel/project.json` |

## Optional (Sanity CMS)

| Secret Name | Description | Default |
|-------------|-------------|---------|
| `SANITY_PROJECT_ID` | Sanity project ID | `w18438cu` |
| `SANITY_DATASET` | Sanity dataset name | `production` |
| `SANITY_API_TOKEN` | Sanity API token for write access | Empty (read-only without it) |

## One-Time Setup

1. Build locally: `cd l_m_s/apps/l_m_s && flutter build web`
2. Link Vercel: `cd build/web && npx vercel link`
3. Copy `orgId` and `projectId` from `.vercel/project.json` into GitHub Secrets
4. Create a token at https://vercel.com/account/tokens and add as `VERCEL_TOKEN`
