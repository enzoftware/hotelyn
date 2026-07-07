<p align="center">
<img src="apps/hotelyn_app/assets/thumbnail/hotelyn_logo.png" height="51" alt="Hotelyn logo" />
</p>
<p align="center">The most incredible 🏨 app in the 🌎</p>
<a href="https://github.com/enzoftware/hotelyn/actions"><img src="https://github.com/enzoftware/hotelyn/actions/workflows/main.yaml/badge.svg" alt="Build Status"></a>
<p align="center">Hotelyn is a Dart workspaces monorepo. See INFRA-1004 for the migration history.</p>

## Repository layout

```
hotelyn/
├── pubspec.yaml            ← workspace root (workspace: [...], melos: [...])
├── apps/
│   ├── hotelyn_app/        ← Flutter mobile app (Android, iOS)
│   └── hotelyn_dashboard/  ← Flutter dashboard app (Android, iOS, Web)
├── packages/
│   ├── hotelyn_domain/     ← domain entities & repository interfaces
│   ├── hotelyn_gql/        ← Ferry GraphQL codegen + generated types
│   └── hotelyn_ui/         ← shared widget library & design system
└── backend/                ← Dart Frog GraphQL server (talks to Supabase)
```

## Setup

**Prerequisites:** Flutter stable channel, Dart ≥ 3.5.0, [Melos](https://melos.codes) ≥ 7.

Follow these steps in order on a fresh clone:

1. Install Flutter (stable channel) by following the [official install guide](https://docs.flutter.dev/get-started/install) for your OS.
2. Confirm your toolchain is healthy:
   ```bash
   flutter doctor
   ```
   Resolve any issues it reports (e.g. missing Android/iOS toolchains) before continuing.
3. Clone the repository and `cd` into it:
   ```bash
   git clone https://github.com/enzoftware/hotelyn.git
   cd hotelyn
   ```
4. Activate Melos globally (once per machine), then make sure the Pub cache `bin` directory is on your `PATH` so the `melos` command is available in new shells:
   ```bash
   dart pub global activate melos
   export PATH="$PATH:$HOME/.pub-cache/bin"
   ```
5. Bootstrap the workspace — this resolves and links every app/package/server in one shot:
   ```bash
   melos bootstrap
   ```
6. Verify the workspace is healthy:
   ```bash
   melos run analyze
   melos run test
   ```
7. Re-run `flutter doctor` — it should be clean with no unresolved issues:
   ```bash
   flutter doctor
   ```

No other manual setup is required. Steps 1–7 are the complete bootstrap sequence for a new machine.

## Running the app

```bash
cd apps/hotelyn_app

# Development flavor
flutter run -t lib/main_development.dart

# Production flavor
flutter run -t lib/main_production.dart
```

## Common Melos commands

Run these from the **repo root**:

```bash
# Static analysis across all packages
melos run analyze

# Run all tests
melos run test

# Code generation (json_serializable, build_runner)
melos run build

# Check formatting
melos run format
```

## Individual package commands

```bash
# Analyze a single package
cd apps/hotelyn_app && flutter analyze

# Test a single package
cd apps/hotelyn_app && flutter test

# Test a single file
cd apps/hotelyn_app && flutter test test/features/intro/bloc/intro_bloc_test.dart
```
