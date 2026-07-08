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
│   ├── hotelyn_api_client/ ← REST client (package:http) over the Dart Frog API
│   ├── hotelyn_domain/     ← domain entities (json_serializable) & interfaces
│   └── hotelyn_ui/         ← shared widget library & design system
├── backend/                ← Dart Frog REST server (talks to Supabase)
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

The app never talks to Supabase directly (see [Architecture](CLAUDE.md#architecture)) — only the `backend` REST server does. To run that stack locally:

**Prerequisites:** [Docker](https://www.docker.com/products/docker-desktop/) running, [Supabase CLI](https://supabase.com/docs/guides/local-development/cli/getting-started) ≥ 2.x.

1. Start the stack (Postgres, Auth, Storage, Realtime, PostgREST, Studio). On the
   first run this also applies every migration in `supabase/migrations/` and loads
   `supabase/seed.sql`:
   ```bash
   supabase start
   ```
2. Confirm every service is healthy and note the printed URLs/keys:
   ```bash
   supabase status
   ```
3. Apply the schema and (re)load the seed data. Run this whenever migrations or
   `supabase/seed.sql` change, or whenever you want a clean, known dataset — it
   drops the local database, re-runs all migrations (the first enables `postgis`),
   then loads the seed:
   ```bash
   supabase db reset
   ```
   The seed is **idempotent and deterministic** (fixed IDs/coordinates), so a
   reset always produces the same six hotels, their rooms, and the two test
   accounts listed under [Data model](#data-model) — safe to run as often as you
   like.
4. Verify the seed loaded (should print `6`). Copy `DB_URL` from `supabase status`:
   ```bash
   psql "$DB_URL" -c 'select count(*) from hotels;'
   ```
   No local `psql`? Browse the tables in Studio (step 6), or run the query inside
   the database container:
   ```bash
   docker exec -it supabase_db_hotelyn \
     psql -U postgres -d postgres -c 'select count(*) from public.hotels;'
   ```
5. Copy the env templates and fill in the values `supabase status` printed:
   ```bash
   cp backend/.env.example backend/.env
   cp apps/hotelyn_app/.env.example apps/hotelyn_app/.env
   cp apps/hotelyn_dashboard/.env.example apps/hotelyn_dashboard/.env
   ```
6. Open Studio at the printed `STUDIO_URL` (defaults to `http://127.0.0.1:54323`)
   to browse the seeded schema and data.
7. When you're done, stop the stack:
   ```bash
   supabase stop
   ```

### Data model

The schema (see `supabase/migrations/`) is four normalized tables plus enum
types and Row Level Security:

| Table          | Notes                                                                              |
| -------------- | ---------------------------------------------------------------------------------- |
| `profiles`     | 1:1 with `auth.users`; holds `role` (`guest`/`hotel_staff`/`admin`) + `hotel_id`.  |
| `hotels`       | Includes a PostGIS `location geometry(Point, 4326)` with a GiST index.             |
| `rooms`        | FK → `hotels`; `is_available` flags bookable rooms.                                 |
| `reservations` | FK → `hotels`/`rooms`/`profiles`; `status` enum; `hold_expires_at` + unique `confirmation_code`. Partial unique index on `room_id WHERE status IN ('held','confirmed')` makes double-booking impossible. |

RLS is enabled on every table: guests browse available rooms and manage only
their own reservations; hotel staff read/write only their own hotel's rooms and
reservations. The seed (`supabase/seed.sql`, loaded by `supabase db reset`) is
deterministic: six hotels across LatAm + North America launch cities, a mix of
available/unavailable rooms, and two test accounts (local password
`password123`):

| Account              | Role          |
| -------------------- | ------------- |
| `guest@hotelyn.test` | `guest`       |
| `staff@hotelyn.test` | `hotel_staff` (owns the Lima hotel) |

Metre-accurate proximity search casts `location` to `geography` (a distance in
metres), which is served by the dedicated functional GiST index rather than the
degree-based one:

```sql
-- hotels within 5 km of a point (lon, lat)
select name from hotels
where st_dwithin(location::geography,
                 st_setsrid(st_makepoint(-77.03, -12.11), 4326)::geography, 5000);
```

The RLS policies (and the geolocation functions below) are covered by automated
pgTAP tests — the Hotel A / Hotel B isolation proof plus the search-function
behaviour:

```bash
supabase test db
```

### Geolocation search & recommendations

Three SECURITY DEFINER SQL functions (migration `..._geo_search.sql`) power
search. They read every reservation to compute availability but only ever return
public catalogue rows:

| Function | Purpose |
| -------- | ------- |
| `nearby_hotels(lat, lng, radius_km)` | Hotels within the radius (`ST_DWithin`), nearest-first with a `distance_km` (`ST_Distance`). Empty set when nothing is in range. |
| `rooms_with_availability(hotel_id?)` | Each room with `available_now` = flagged available **and** no unexpired `held`/`confirmed` hold (`hold_expires_at > now()`). Expired holds don't block. |
| `recommended_hotels(lat, lng, radius_km)` | In-radius hotels ranked by `confirmed` reservations in the trailing `recommendation_window_days()` (30), ties broken by proximity. Cold-start (all zero) falls back to nearby filtered to available-now. |

Nearby search is index-accelerated: **p95 ≈ 0.3 ms with 100 hotels** (200 runs,
local stack) — well under the 300 ms budget.

### Reservation holds (EPIC-04)

A hold is a short-lived, exclusive claim on a room (default 15 min, see
`hold_duration()`) so a guest can finish checkout without being double-booked.
Correctness is the database's job — the migration
`..._reservation_holds.sql` enforces it structurally:

| Piece | What it does |
| ----- | ------------ |
| Partial unique index `reservations_active_room_uidx` | At most one `held`/`confirmed` reservation per room. A concurrent second hold loses to the constraint — no application lock needed (BE-401). |
| `create_reservation_hold(room_id, guest_id, check_in, check_out)` | `INSERT … ON CONFLICT DO NOTHING`: returns the created reservation, or **zero rows** when the room is already held (the client maps this to a typed 409 `RoomAlreadyHeldException`). Generates the `confirmation_code` in the same transaction and reclaims any lapsed hold first (BE-402). |
| Query-time expiry | No paid scheduler: `status` may read `held` after real expiry, but every read path treats `held AND hold_expires_at < now()` as free, so no user ever sees a stale-blocked room (BE-403). |

The single-winner guarantee and expiry behaviour are covered by pgTAP
(`supabase/tests/reservation_holds_test.sql`).

### REST API (Dart Frog)

The `backend/` Dart Frog server exposes these over resource-based REST endpoints,
each handled through a Supabase-backed data client — the Flutter apps never call
Supabase directly. Run it with the local stack up:

```bash
cd backend && dart_frog dev   # http://localhost:8080
```

| Method & path | Purpose |
| --- | --- |
| `GET /health` | Liveness probe (`{ "status": "ok" }`). |
| `GET /hotels/nearby?lat=&lng=&radiusKm=` | Nearby hotels, nearest-first. |
| `GET /hotels/recommended?lat=&lng=&radiusKm=` | Recommended hotels. |
| `GET /hotels/{id}/rooms` | Rooms for a hotel with `available_now`. |

```bash
curl 'http://localhost:8080/hotels/nearby?lat=-12.11&lng=-77.03&radiusKm=200'
```

Responses are JSON arrays with snake_case keys (e.g. `distance_km`), matching the
`hotelyn_domain` `json_serializable` models. A missing/invalid query parameter
returns `400`; a data-layer failure returns `500` (internal detail not leaked).

### Email testing (local)

Auth emails (OTP codes) are **not** sent to a real inbox during local development.
They are captured by the built-in inbucket viewer at
**http://127.0.0.1:54324** — open it in your browser after `supabase start` to
read any OTP that would have been delivered.

## Email delivery (Resend)

Guest authentication uses email OTP. In staging and production, Supabase Auth
delivers the 6-digit code via [Resend](https://resend.com) (free tier: 3,000
emails/month, 100/day).

### Why Resend, not SMS?

SMS providers (Twilio, MessageBird, Vonage) charge per message with no free
tier. LatAm — the primary Hotelyn market — has among the highest per-SMS rates.
Resend's free quota covers the entire MVP phase at zero cost. See issue
[#158](https://github.com/enzoftware/hotelyn/issues/158) for the decision record.

### One-time Resend setup (staging / production)

> Local dev does **not** need this. Emails are captured by the inbucket at
> `http://127.0.0.1:54324`.

1. Create a free account at <https://resend.com>.
2. Generate an API key under **Resend → API Keys**. Keep it secret — never
   commit it.
3. **Optional (recommended for production):** Verify your sending domain under
   **Resend → Domains** to avoid spam filters. For staging you can use the
   shared `onboarding@resend.dev` sender without any domain setup.
4. In the **Supabase Dashboard** for your hosted project, go to
   **Auth → SMTP Settings** and fill in:

   | Field | Value |
   |---|---|
   | Host | `smtp.resend.com` |
   | Port | `587` |
   | Username | `resend` |
   | Password | *(your Resend API key)* |
   | Sender name | `Hotelyn` |
   | Sender email | your verified address, or `onboarding@resend.dev` for staging |

5. Add the two variables to your CI secrets / Supabase project secrets (see
   `backend/.env.example`):
5. Add the two variables to your CI secrets / Supabase project secrets (see
   `backend/.env.example`):
6. In **Auth → Email**, set the OTP expiry to **600 seconds** (10 min) —
   already configured in `supabase/config.toml` for the local stack.

> **Never** commit your Resend API key. Store it in CI/CD secrets and in the
> Supabase project's secret manager only.

## Running the app

Each app has three entry points — one per environment:

| Entry point | Environment |
|---|---|
| `lib/main_development.dart` | Local development |
| `lib/main_staging.dart` | Staging |
| `lib/main_production.dart` | Production |

The backend endpoint (`API_BASE_URL`) is injected at build time via
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

For the **Android emulator**, use `http://10.0.2.2:8080`.
For a **physical device**, override `API_BASE_URL` to your machine's LAN IP instead of `127.0.0.1`.

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
