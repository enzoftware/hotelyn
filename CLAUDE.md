# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository status

The repo is a Dart workspaces monorepo (INFRA-1004). The mobile app lives at `apps/hotelyn_app/`; see "Monorepo layout" below for the full tree.

## Commands

```bash
# Get dependencies
flutter pub get

# Run the app (two flavors)
flutter run -t lib/main_development.dart
flutter run -t lib/main_production.dart

# Analyze
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/features/intro/bloc/intro_bloc_test.dart

# Code generation (l10n, json_serializable)
flutter pub run build_runner build --delete-conflicting-outputs

# Scaffold a new feature (Mason)
mason make feature_brick
```

CI runs on the `stable` Flutter channel via [VeryGoodOpenSource/very_good_workflows](https://github.com/VeryGoodOpenSource/very_good_workflows). PRs require semantic titles.

## Architecture

### Layer structure

```
lib/
├── app/            # App root: HotelynApp widget, AppRouter, AppBloc
├── bootstrap.dart  # Initialisation (BlocObserver, Clarity, orientation lock)
├── components/     # Design system: theme, colors, text styles, reusable widgets
├── core/
│   ├── data/       # SharedStorage (SharedPreferences wrapper)
│   ├── domain/     # Repository interfaces + domain models (Hotel, User)
│   └── services/   # ClarityService (Microsoft Clarity analytics)
├── features/       # One folder per screen/feature (see below)
└── l10n/           # ARB files (EN, ES) + generated AppLocalizations
```

### Dependency injection

Repositories are constructed in `main_development.dart` / `main_production.dart` and provided at the app root via `MultiRepositoryProvider`. Features read them with `context.read<T>()`. No service locator; no global singletons.

### State management

- **BLoC** (`Bloc<Event, State>`) for features with multiple distinct events: `AppBloc`, `SplashBloc`, `HomeBloc`, `IntroBloc`, `PaymentBloc`, `RegisterBloc`.
- **Cubit** for simpler, single-stream state: `LoginCubit`, `NavigationBarCubit`, `ProfileCubit`, `MessagesCubit`, `SearchCubit`.
- **Riverpod** (`ProviderScope`) wraps the app but is not used in any existing feature — reserved for the upcoming REST data layer.
- `formz` is used for form-field validation models (see `lib/features/login/models/`).

### Routing

`AppRouter` (GoRouter) has five routes: `/` → SplashScreen → decides between `/intro`, `/home`, `/login` based on `SplashBloc`. `/payment` is reached from within the home flow. `HomePage` hosts four tabs (Home, Search, Messages, Profile) via `NavigationBarCubit`; tab bodies are swapped inline, not via sub-routes.

### Localization

ARB files live in `lib/l10n/arb/`. Generated code is committed. Access strings via `context.l10n` (the `BuildContext` extension in `lib/l10n/l10n.dart`). The template locale is English (`app_en.arb`).

### Analytics

Microsoft Clarity is wired in `bootstrap.dart` (project ID `vaoffuzfn7`). `AuthRepository.login()` sets a custom user ID in Clarity. `ClarityService` tracks screen names; inject it where needed via `context.read<ClarityService>()`.

### Testing conventions

- `test/helpers/pump_app.dart` — `WidgetTester.pumpApp(widget)` wraps any widget in a `MaterialApp` with localization delegates.
- `test/helpers/mocks.dart` — Mocktail mocks for all repositories.
- BLoC tests use `bloc_test` (`blocTest<>`, `build`, `act`, `expect`).
- Feature tests mirror the `lib/features/` tree under `test/features/`.

### Monorepo layout

```
hotelyn/
├── apps/
│   ├── hotelyn_app/        # Flutter mobile app (Android, iOS)
│   └── hotelyn_dashboard/  # Flutter dashboard app (Android, iOS, Web)
├── packages/
│   ├── hotelyn_api_client/ # REST client (package:http) over the Dart Frog API
│   ├── hotelyn_domain/     # Domain entities (json_serializable) & interfaces
│   └── hotelyn_ui/         # Shared widget library
└── backend/                # Dart Frog REST API (talks to Supabase)
```

The Flutter apps will have **no** direct Supabase dependency. All data access goes through the Dart Frog **REST** layer; apps depend on `hotelyn_api_client`, which calls the REST endpoints with `package:http` and decodes JSON into `hotelyn_domain` models (`json_serializable`). See issues #209–#220 for the migration plan (`hotelyn_dashboard` was added afterward and is not tracked by those issues). REST is the single protocol between apps and backend.
