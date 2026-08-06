# feat: Add Widgetbook and update project structure

- **PR:** #245 — https://github.com/enzoftware/hotelyn/pull/245
- **Branch:** be-806-core-ui-package-california → main
- **Status:** open
- **Created:** 2026-08-05
- **Author:** Enzo Lizama

## Summary

Implements BE-806: introduces `california_ui`, the shared widget library and design system for Hotelyn ("Hotel California"), replacing the empty `hotelyn_ui` placeholder package. Ships the initial theme (colors, spacing, typography) and seven core widgets, each with unit tests, plus a Widgetbook catalog app (web + macOS targets) for interactively browsing components.

## Changes

### `packages/california_ui` — new package (replaces `packages/hotelyn_ui`)

- `lib/src/theme/` — `california_colors.dart`, `california_spacing.dart`, `california_typography.dart`.
- `lib/src/widgets/` — `california_button`, `california_checkbox`, `california_input_field`, `california_navigation_bar`, `california_product_card`, `california_selector`, `california_top_bar`.
- `lib/california_ui.dart` — package barrel exporting theme + widgets.
- Bundled fonts: DM Sans (Bold, Medium, Regular) under `assets/fonts/`.
- `test/` — full coverage for theme values and each widget (53 tests total), plus `pump_app`/`test_image` helpers.

### `packages/california_ui/widgetbook` — new Widgetbook catalog app

- Use-case files for every widget under `lib/use_cases/`, `main.dart`, generated `main.directories.g.dart`, and `src/app_themes.dart`.
- Platform scaffolding for web (`web/`) and macOS (`macos/`), including Xcode project, entitlements, and app icons, so the catalog can run as `flutter run -d chrome` or as a native macOS app.

### Workspace / tooling

- `pubspec.yaml` (root) — workspace members updated: `packages/hotelyn_ui` removed, `packages/california_ui` and `packages/california_ui/widgetbook` added.
- `melos.yaml` (via root `pubspec.yaml`) — new `widgetbook:generate` and `widgetbook` melos scripts (build_runner + `flutter run -d chrome`), and `build` script now runs with `concurrency: 1`.
- `pubspec.lock` — regenerated for the new/renamed packages and Widgetbook's dependencies.
- Minor version bumps in `hotelyn_api_client`, `hotelyn_domain`, `backend`, and `apps/hotelyn_app` `pubspec.yaml` files.
- `CLAUDE.md`, `README.md` — updated to document the `california_ui` package and the `melos run widgetbook` command.

## Verification

- `melos test --scope="california_ui" --no-select` — all 53 tests passed.
- Widgetbook catalog scaffolding added for manual/visual verification of each widget; not exercised headlessly in this pass.

## Notes / follow-ups

- `packages/hotelyn_ui` is fully replaced; any remaining references to it elsewhere in the app should be migrated to `california_ui` in a follow-up if not already done.
- macOS target was added specifically so the Widgetbook catalog can run as a native app in addition to web.
