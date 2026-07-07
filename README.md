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
├── backend/                ← Dart Frog GraphQL server (talks to Supabase)
└── supabase/               ← local Supabase stack config + migrations
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

## Local Supabase stack

The app never talks to Supabase directly (see [Architecture](CLAUDE.md#architecture)) — only the `backend` GraphQL server does. To run that stack locally:

**Prerequisites:** [Docker](https://www.docker.com/products/docker-desktop/) running, [Supabase CLI](https://supabase.com/docs/guides/local-development/cli/getting-started) ≥ 2.x.

1. Start the stack (Postgres, Auth, Storage, Realtime, PostgREST, Studio):
   ```bash
   supabase start
   ```
2. Confirm every service is healthy:
   ```bash
   supabase status
   ```
3. Open Studio at the printed `STUDIO_URL` (defaults to `http://127.0.0.1:54323`) to browse the seeded schema.
4. Copy the env templates and fill in the values `supabase status` printed:
   ```bash
   cp backend/.env.example backend/.env
   cp apps/hotelyn_app/.env.example apps/hotelyn_app/.env
   cp apps/hotelyn_dashboard/.env.example apps/hotelyn_dashboard/.env
   ```
5. When you're done, stop the stack:
   ```bash
   supabase stop
   ```

Migrations live in `supabase/migrations/`; the first one enables the `postgis` extension. To apply all migrations to a fresh database:
```bash
supabase db reset
```

## Running the app

Each app has three entry points — one per environment:

| Entry point | Environment |
|---|---|
| `lib/main_development.dart` | Local development |
| `lib/main_staging.dart` | Staging |
| `lib/main_production.dart` | Production |

The backend endpoint (`GRAPHQL_URL`) is injected at build time via
`--dart-define-from-file`. No source edits are needed to switch environments.

### Switching environments (single command)

All commands below are run from **`apps/hotelyn_app/`**.

1. Copy the template for your target environment:
   ```bash
   # Local
   cp .dart_defines/local.json.example .dart_defines/local.json

   # Staging
   cp .dart_defines/staging.json.example .dart_defines/staging.json

   # Production
   cp .dart_defines/production.json.example .dart_defines/production.json
   ```
2. Edit the copied file and fill in the real endpoint URL.
3. Run with the matching entry point and define file:
   ```bash
   # Local (default — works without a define file)
   flutter run -t lib/main_development.dart \
     --dart-define-from-file=.dart_defines/local.json

   # Staging
   flutter run -t lib/main_staging.dart \
     --dart-define-from-file=.dart_defines/staging.json

   # Production
   flutter run -t lib/main_production.dart \
     --dart-define-from-file=.dart_defines/production.json
   ```

> **Note:** `.dart_defines/*.json` files are gitignored. Only the
> `*.json.example` templates are committed. Never commit real endpoint URLs
> or credentials.

For **Android emulator** or **physical device**, override `GRAPHQL_URL` to the
LAN address of your machine (e.g. `http://10.0.2.2:8080/graphql` for the
Android emulator) instead of `127.0.0.1`.

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
