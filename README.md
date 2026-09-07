<p align="center">
  <img src="apps/hotelyn_app/assets/thumbnail/hotelyn_logo.png" height="56" alt="Hotelyn logo" />
</p>

<h1 align="center">Hotelyn</h1>

<p align="center">
  A modern, full-stack hotel booking and hospitality management platform built with Flutter, Dart Frog, and Supabase.
</p>

<p align="center">
  <a href="https://github.com/enzoftware/hotelyn/actions/workflows/main.yaml"><img src="https://github.com/enzoftware/hotelyn/actions/workflows/main.yaml/badge.svg" alt="Build Status"></a>
  <img src="https://img.shields.io/badge/Flutter-%E2%89%A5%203.27.0-02569B?logo=flutter" alt="Flutter version">
  <img src="https://img.shields.io/badge/Dart-%E2%89%A5%203.5.0-0175C2?logo=dart" alt="Dart version">
  <img src="https://img.shields.io/badge/Melos-%E2%89%A5%207.0-blueviolet" alt="Melos">
</p>

---

## Overview

**Hotelyn** provides an end-to-end hospitality solution featuring a guest-facing mobile booking application, an administrative staff dashboard, a lightweight Dart Frog REST backend, and a robust PostgreSQL database powered by Supabase.

### Key Features

- 🏨 **Hotel & Room Discovery**: Proximity-based search, dynamic recommendations, and real-time room availability.
- ⏱️ **Hold & Reservation System**: Short-lived, race-condition-free room holds guaranteeing single-reservation integrity during checkout.
- 🔐 **Flexible Authentication**: Passwordless email OTP authentication for guests and credentials-based authentication for hotel staff.
- 📊 **Staff Inventory Management**: Live room availability toggling, reservation confirmations/rejections, and in-person payment processing.
- 🎨 **Shared Design System**: Reusable UI component library (`california_ui`) with an interactive Widgetbook catalog.

---

## Architecture & Repository Layout

Hotelyn is structured as a unified Dart workspaces monorepo orchestrated with **Melos**. Client applications interact strictly via the REST backend, maintaining a clean decoupling from the database layer.

```text
hotelyn/
├── apps/
│   ├── hotelyn_app/        # Flutter mobile app (Android & iOS)
│   └── hotelyn_dashboard/  # Flutter web & admin dashboard
├── packages/
│   ├── hotelyn_api_client/ # Typed REST client over the Dart Frog API
│   ├── hotelyn_domain/     # Shared domain entities & json_serializable models
│   └── california_ui/      # Shared design system, UI components & Widgetbook catalog
├── backend/                # Dart Frog REST server (interacts with Supabase)
└── supabase/               # Local Supabase configuration, migrations & seed data
```

### Tech Stack

- **Mobile & Web Apps**: [Flutter](https://flutter.dev) with BLoC/Cubit for predictable state management, GoRouter for declarative routing, and `california_ui` for standardized components.
- **Backend**: [Dart Frog](https://dartfrog.vgv.dev) providing stateless, high-performance REST endpoints.
- **Database & Auth**: [Supabase](https://supabase.com) (PostgreSQL) with Row-Level Security (RLS) ensuring strict multi-tenant isolation, spatial indexing for location search, and deterministic seeding for testing.
- **Monorepo Management**: [Melos](https://melos.codes) for managing multi-package versioning, dependency graph resolution, and unified development scripts.

---

## Getting Started

Follow these steps to set up and run the entire Hotelyn stack locally.

### Prerequisites

Ensure the following tools are installed on your machine:

- **Flutter & Dart**: Flutter ≥ 3.27.0 and Dart ≥ 3.5.0. Using [FVM (Flutter Version Management)](https://fvm.app/) is recommended for managing Flutter versions consistently.
- **Melos**: Monorepo CLI tool (`dart pub global activate melos`).
- **Docker Desktop**: Required to run the local Supabase stack.
- **Supabase CLI**: Required for local database migrations and services (`brew install supabase/tap/supabase` or platform equivalent).
- **Dart Frog CLI**: Required to run the backend API (`dart pub global activate dart_frog_cli`).

---

### Step-by-Step Local Setup

#### 1. Clone & Bootstrap Workspace

Clone the repository and install dependencies across all apps and packages in one command:

```bash
git clone https://github.com/enzoftware/hotelyn.git
cd hotelyn

# Using FVM (recommended)
fvm flutter pub get
fvm dart run melos bootstrap

# Or using global toolchains
flutter pub get
melos bootstrap
```

#### 2. Start the Local Supabase Stack

Make sure Docker is running, then initialize the local Supabase containers (Postgres, Auth, Storage, Inbucket, and Studio):

```bash
supabase start
```

Once started, the CLI will output your local service URLs and API keys:
- **Supabase Studio (Database GUI)**: `http://127.0.0.1:54323`
- **Inbucket (Local Email Testing)**: `http://127.0.0.1:54324`
- **API URL**: `http://127.0.0.1:54321`

To apply all migrations and load deterministic seed data (hotels, rooms, and test accounts):

```bash
supabase db reset
```

**Default Test Accounts** (password: `password123`):

| Email | Role | Access |
|---|---|---|
| `guest@hotelyn.test` | Guest | Mobile booking and reservation management |
| `staff@hotelyn.test` | Hotel Staff | Room management and reservation approvals (Lima hotel) |

#### 3. Configure Environment Variables

Create environment configuration files from the provided templates:

```bash
# Backend configuration
cp backend/.env.example backend/.env

# App environment configurations
cp apps/hotelyn_app/.env.example apps/hotelyn_app/.env
cp apps/hotelyn_dashboard/.env.example apps/hotelyn_dashboard/.env

# Mobile app Dart defines for local environment
cp apps/hotelyn_app/.dart_defines/local.json.example apps/hotelyn_app/.dart_defines/local.json
```

If necessary, update `backend/.env` with any custom keys output by `supabase status`.

#### 4. Run the Dart Frog Backend

Start the REST API server:

```bash
cd backend
dart_frog dev
```

The backend server will run at `http://localhost:8080`. You can verify it with:

```bash
curl http://localhost:8080/health
# Output: {"status":"ok"}
```

#### 5. Run the Mobile App

In a separate terminal, launch the mobile application:

```bash
cd apps/hotelyn_app

# Using FVM (recommended)
fvm flutter run -t lib/main_development.dart --dart-define-from-file=.dart_defines/local.json

# Or using global Flutter
flutter run -t lib/main_development.dart --dart-define-from-file=.dart_defines/local.json
```

> **Targeting Devices:**
> - **iOS Simulator**: Works directly with `http://127.0.0.1:8080`.
> - **Android Emulator**: In `apps/hotelyn_app/.dart_defines/local.json`, set `API_BASE_URL` to `http://10.0.2.2:8080`.
> - **Physical Device**: Set `API_BASE_URL` to your development machine's local network IP address (e.g. `http://192.168.1.50:8080`).

#### 6. (Optional) Run Dashboard & Widgetbook

- **Staff Dashboard App**:

  ```bash
  cd apps/hotelyn_dashboard
  flutter run -d chrome
  ```

- **Interactive Widgetbook Component Catalog**:

  ```bash
  # From repository root
  melos run widgetbook
  ```

---

## Monorepo Commands & Code Quality

Melos scripts allow you to run validation tasks across the entire monorepo from the root directory:

```bash
# Static analysis across all packages
melos run analyze

# Run unit and widget tests across all packages
melos run test

# Check code formatting
melos run format

# Run code generation (build_runner, json_serializable)
melos run build
```

To run commands within an individual package:

```bash
# Analyze a specific package
cd apps/hotelyn_app && flutter analyze

# Run tests for a specific package
cd apps/hotelyn_app && flutter test
```

---

## Contributing Guide

We welcome contributions! Please follow our standardized development workflow and conventions.

### Git Workflow & Branching

1. Ensure your local branch is updated from `main`:

   ```bash
   git checkout main
   git pull origin main
   ```

2. Create a new topic branch using our naming conventions:
   - `feat/<feature-name>`: New functionality or enhancement
   - `fix/<bug-name>`: Bug fixes
   - `docs/<doc-topic>`: Documentation updates
   - `refactor/<refactor-scope>`: Code restructuring without feature changes
   - `chore/<task-name>`: Maintenance, tooling, or dependency updates

### Commit Conventions

We enforce [Conventional Commits](https://www.conventionalcommits.org/). Commit messages should follow this structure:

```text
<type>(<optional scope>): <description>

[optional body]
```

Common types:
- `feat`: Introduces a new feature
- `fix`: Patches a bug
- `docs`: Documentation modifications
- `style`: Formatting or whitespace changes (no code behavior change)
- `refactor`: Refactoring production code without behavior changes
- `test`: Adding or updating test suites
- `chore`: Build scripts, CI workflow, or tooling updates

*Example:* `feat(hotelyn_app): add room availability filter to search screen`

### Quality & Verification Checklist

Before submitting a pull request, ensure all checks pass:

- [ ] Code formatted: `melos run format` (or `dart format .`)
- [ ] Static analysis passes with zero warnings: `melos run analyze`
- [ ] Test suites succeed: `melos run test`
- [ ] Database tests pass (if modifying migrations/database logic): `supabase test db`
