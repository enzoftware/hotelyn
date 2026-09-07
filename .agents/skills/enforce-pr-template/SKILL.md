---
name: enforce-pr-template
description: Enforces using the official Hotelyn pull request template (.github/PULL_REQUEST_TEMPLATE.md) for all pull requests created in the repository.
---

# Enforce PR Template

## Overview
Every pull request submitted to the Hotelyn repository must adhere strictly to the repository's official PR template located at `.github/PULL_REQUEST_TEMPLATE.md`. This standard ensures consistent reviewability across the monorepo, documents testing evidence, guarantees compliance with semantic CI checks, and maintains an auditable changelog of engineering decisions.

## When to Use
Use this skill whenever:
- Preparing, opening, or drafting a Pull Request in the Hotelyn repository.
- Using CLI commands such as `gh pr create`.
- Using MCP tools such as `github:create_pull_request`.
- Delegating PR creation to subagents or automated workflows.

## Mandatory Requirements

1. **Read the Template First**:
   Before composing any PR description, agents MUST inspect `.github/PULL_REQUEST_TEMPLATE.md` to ensure they are using the latest version of the repository template.

2. **Adhere Strictly to Template Structure**:
   Do NOT invent custom headings, drop required sections, or submit a single unformatted paragraph. Every PR body must include:
   - `## Summary & Context`
   - `## Related Issue(s)`
   - `## Type of Change`
   - `## Key Changes`
   - `## Visual Changes / Screenshots`
   - `## Testing & Verification`
   - `## Pre-Submission Checklist`

3. **No Raw Placeholder Comments or Blank Sections**:
   - Strip out explanatory HTML comment blocks (`<!-- ... -->`) from the template when generating the final PR description.
   - Do NOT leave empty bullets or unresolved placeholders (such as `- ` or `Closes #` with no issue number).
   - If an issue is not applicable, write `- None`.
   - In `Key Changes`, only include packages/apps affected by the PR. Omit untouched packages or mark them clearly.
   - In `Visual Changes / Screenshots`, if the PR does not touch UI in `apps/hotelyn_app`, `apps/hotelyn_dashboard`, or `packages/california_ui/widgetbook`, state `_N/A - Non-UI change_`.

4. **Verify Automated Tests Before Submitting**:
   Agents MUST execute and record automated verification results prior to opening the PR:
   - `melos run analyze`: Static analysis across all packages.
   - `melos run test`: Automated test suites across all packages.
   - `melos run format`: Code formatting checks.
   - `supabase test db`: pgTAP database tests (mandatory if `supabase/` files are touched).
   Include actual passing status in the `Testing & Verification` checklist and provide concrete manual verification steps.

5. **Semantic PR Title (Conventional Commits)**:
   The PR title MUST adhere to the Conventional Commits specification (e.g., `feat(app): ...`, `fix(api): ...`, `chore: ...`). The `semantic-pull-request` workflow runs on all PRs and blocks merging if the PR title does not comply.

---

## Agent Workflow: Opening a Pull Request

```
1. Run Verification Checks (`melos run analyze`, `melos run test`, etc.)
               │
               ▼
2. Read `.github/PULL_REQUEST_TEMPLATE.md`
               │
               ▼
3. Compose PR title adhering to Conventional Commits
               │
               ▼
4. Fill out all template sections with specific, factual details
   (Remove HTML comment placeholders, prune untouched package headers)
               │
               ▼
5. Submit PR via `gh pr create` or GitHub MCP tool
```

### 1. Verification Phase
Run the relevant verification commands in your workspace:
```bash
# Analyze all workspace packages
melos run analyze

# Run all workspace test suites
melos run test

# Check code formatting
melos run format

# Run Supabase pgTAP tests if database/policies were modified
supabase test db
```

### 2. Composition Phase
Draft the PR title and body. Verify that:
- PR title matches: `type(scope)?: description` (all lowercase description, no trailing period).
- All checkboxes reflect actual state (`[x]` for completed, `[ ]` for non-applicable).
- Evidence of manual checks is clearly enumerated.

### 3. Submission Phase
Use `gh pr create` or the `create_pull_request` MCP tool. For example:
```bash
gh pr create \
  --base main \
  --head <your-branch> \
  --title "feat(dashboard): add tenant occupancy analytics chart" \
  --body-file pr_body.md
```

---

## Complete Reference Example

Below is an example of a properly formatted pull request body conforming to `.github/PULL_REQUEST_TEMPLATE.md`:

```markdown
## Summary & Context
Introduces a tenant occupancy trend chart to the analytics overview screen in `hotelyn_dashboard`. This enables hotel managers to view 30-day occupancy trajectories without exporting raw reservation reports, resolving a primary friction point identified in user feedback for milestone v1.2.

## Related Issue(s)
- Closes #142

## Type of Change
- [x] ✨ `feat`: New feature (non-breaking change which adds functionality)
- [ ] 🛠️ `fix`: Bug fix (non-breaking change which fixes an issue)
- [ ] 🧹 `refactor`: Code refactoring without functional changes
- [ ] ⚡ `perf`: Performance optimization
- [ ] 📝 `docs`: Documentation updates
- [ ] 🏗️ `chore`: Tooling, build config, CI, dependencies, or monorepo maintenance
- [ ] 💥 `breaking`: Breaking change (alters existing behavior, APIs, or data models)

## Key Changes

### `apps/hotelyn_dashboard`
- Added `OccupancyTrendChart` widget in `lib/features/analytics/presentation/`.
- Integrated `OccupancyBloc` with real-time stream subscription from `hotelyn_api_client`.
- Added unit and widget tests for chart rendering states (loading, data, empty, error).

### `packages/hotelyn_api_client`
- Added `getOccupancyMetrics()` endpoint client method in `AnalyticsApiClient`.
- Added mock responses for unit test isolation.

### `packages/hotelyn_domain`
- Added `OccupancyMetric` and `DailyOccupancy` data models with `json_serializable` support.

## Visual Changes / Screenshots

| Before | After |
| :---: | :---: |
| _No occupancy visualization (static table only)_ | ![Occupancy Chart](https://github.com/user-attachments/assets/example-chart.png) |

## Testing & Verification

### Automated Tests
- [x] `melos run analyze` (Static analysis passed with zero errors or warnings)
- [x] `melos run test` (Unit / widget test suite passed: 48 tests passed)
- [x] `melos run format` (Dart formatting verified)
- [ ] `supabase test db` (pgTAP database suite passed - required if touching `supabase/`)

### Manual Verification
1. Ran `hotelyn_dashboard` in Chrome (`flutter run -d chrome`).
2. Navigated to Analytics > Occupancy tab.
3. Verified chart updates smoothly when toggling between 7-day and 30-day date ranges.
4. Tested edge cases: zero reservations (displays empty state graphic) and network failure (displays retry prompt).

## Pre-Submission Checklist
- [x] My branch is rebased on the latest `origin/main`.
- [x] PR title adheres to [Conventional Commits](https://www.conventionalcommits.org/) (e.g., `feat:`, `fix:`, `chore:`).
- [x] Commits follow Conventional Commits standard.
- [x] Code follows repository style guidelines and `analysis_options.yaml`.
- [x] No temporary debug prints, unnecessary logging, or leftover commented code.
- [x] Relevant documentation has been updated (e.g., `README.md`, `CLAUDE.md`, docs).
- [x] I have filled out all applicable sections of this template and removed placeholder comments.
```

---

## Red Flags & Common Rationalizations

| Excuse / Rationalization | Reality & Enforcement |
| :--- | :--- |
| *"The PR is small, so a brief one-line description is fine."* | **Forbidden.** Monorepo changes require traceability and automated test confirmation regardless of line count. |
| *"I will run tests on CI after opening the PR."* | **Forbidden.** Automated checks (`melos run analyze`, `melos run test`) must be run locally prior to submission to avoid wasting CI cycles. |
| *"Leaving HTML comments in the PR body doesn't hurt anyone."* | **Forbidden.** Comments clutter PR descriptions and render reviews messy. Clean them up before submitting. |
| *"I don't need to specify package headings because only one file changed."* | **Forbidden.** Specify the exact package/app (e.g., `apps/hotelyn_app`) to assist monorepo maintainers in tracking dependencies. |
| *"I'll fix the PR title later if CI complains."* | **Forbidden.** Use Conventional Commits (`feat:`, `fix:`, `chore:`, etc.) immediately so `semantic-pull-request` passes on first run. |
