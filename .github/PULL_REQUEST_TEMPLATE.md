<!--
  Hotelyn Pull Request Template
  Please fill out all relevant sections below prior to submitting your pull request.
  Ensure your PR title follows Conventional Commits (e.g., feat(app): ..., fix(backend): ...),
  as this is strictly validated by semantic-pull-request CI.
-->

## Summary & Context
<!--
  Provide a concise summary of the problem, feature, or motivation behind this PR.
  Explain the product context and/or architectural reasoning behind the approach taken.
-->

## Related Issue(s)
<!--
  Link issues using GitHub closing keywords: Fixes #<issue_number>, Closes #<issue_number>, Resolves #<issue_number>.
  If there is no corresponding issue, specify "None".
-->
- Closes #

## Type of Change
<!-- Check all that apply with an "x" inside the brackets: [x] -->
- [ ] ✨ `feat`: New feature (non-breaking change which adds functionality)
- [ ] 🛠️ `fix`: Bug fix (non-breaking change which fixes an issue)
- [ ] 🧹 `refactor`: Code refactoring without functional changes
- [ ] ⚡ `perf`: Performance optimization
- [ ] 📝 `docs`: Documentation updates
- [ ] 🏗️ `chore`: Tooling, build config, CI, dependencies, or monorepo maintenance
- [ ] 💥 `breaking`: Breaking change (alters existing behavior, APIs, or data models)

## Key Changes
<!--
  Detail specific changes grouped by affected package or app in the Hotelyn monorepo.
  Delete or omit sections that were not touched.
-->

### `apps/hotelyn_app`
- 

### `apps/hotelyn_dashboard`
- 

### `packages/california_ui`
- 

### `packages/hotelyn_api_client`
- 

### `packages/hotelyn_domain`
- 

### `backend`
- 

### `supabase`
- 

### Tooling / Root / Other
- 

## Visual Changes / Screenshots
<!--
  Required for UI modifications in apps/hotelyn_app, apps/hotelyn_dashboard, or packages/california_ui/widgetbook.
  Provide side-by-side Before/After comparisons (screenshots or recordings). If non-UI, state "N/A".
-->

| Before | After |
| :---: | :---: |
| _N/A_ | _N/A_ |

## Testing & Verification
<!--
  All changes must be verified prior to submission.
  Check all automated validations that passed, and document manual verification steps taken.
-->

### Automated Tests
- [ ] `melos run analyze` (Static analysis passed with zero errors or warnings)
- [ ] `melos run test` (Unit / widget test suite passed)
- [ ] `melos run format` (Dart formatting verified)
- [ ] `supabase test db` (pgTAP database suite passed - required if touching `supabase/`)

### Manual Verification
1. 
2. 

## Pre-Submission Checklist
- [ ] My branch is rebased on the latest `origin/main`.
- [ ] PR title adheres to [Conventional Commits](https://www.conventionalcommits.org/) (e.g., `feat:`, `fix:`, `chore:`).
- [ ] Commits follow Conventional Commits standard.
- [ ] Code follows repository style guidelines and `analysis_options.yaml`.
- [ ] No temporary debug prints, unnecessary logging, or leftover commented code.
- [ ] Relevant documentation has been updated (e.g., `README.md`, `CLAUDE.md`, docs).
- [ ] I have filled out all applicable sections of this template and removed placeholder comments.
