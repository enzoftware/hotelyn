<p align="center">
<img src="apps/hotelyn_app/assets/thumbnail/hotelyn_logo.png" height="51" alt="Hotelyn logo" />
</p>
<p align="center">The most incredible 🏨 app in the 🌎</p>
<a href="https://github.com/enzoftware/hotelyn/actions"><img src="https://github.com/enzoftware/hotelyn/actions/workflows/main.yaml/badge.svg" alt="Build Status"></a>
<p align="center">⚠️ Hotelyn is being reimagined as a Dart workspaces monorepo. See INFRA-1004 for the full migration plan. ⚠️</p>

## Repository layout

```
hotelyn/
├── pubspec.yaml            ← workspace root (workspace: [...])
├── melos.yaml              ← Melos scripting (analyze, test, build, format)
├── apps/
│   └── hotelyn_app/        ← Flutter mobile app
├── packages/
│   ├── hotelyn_domain/     ← domain entities & repository interfaces
│   ├── hotelyn_gql/        ← Ferry GraphQL codegen + generated types
│   └── hotelyn_ui/         ← shared widget library & design system
└── server/
    └── hotelyn_server/     ← Dart Frog GraphQL server (talks to Supabase)
```

## Setup

**Prerequisites:** Flutter stable channel, Dart ≥ 3.5.0, [Melos](https://melos.codes) ≥ 7.

```bash
# Activate Melos globally (once)
dart pub global activate melos

# Install all workspace dependencies from the repo root
dart pub get

# Or bootstrap via Melos (equivalent, also links packages)
melos bootstrap
```

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
