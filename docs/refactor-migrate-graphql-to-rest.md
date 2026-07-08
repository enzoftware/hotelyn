# Migrate GraphQL/Ferry to REST

- **PR:** #230 — https://github.com/enzoftware/hotelyn/pull/230
- **Branch:** refactor/migrate-graphql-to-rest → main
- **Status:** open
- **Created:** 2026-07-08
- **Author:** Enzo Lizama

## Summary
Replaces the GraphQL/Ferry direction with REST as the single protocol between the
Flutter apps and the Dart Frog backend. The GraphQL surface was small (only the
geo-search slice was implemented and no app code consumed it yet), so the switch
is mostly mechanical while removing indirection that hurt readability. Also
rewrites the 12 open GraphQL/Ferry GitHub issues to their REST equivalents.

## Changes
- **Issues (GitHub):** renamed epic labels `epic:dart-frog-gql → epic:rest-api`
  and `epic:ferry-client → epic:rest-client`; rewrote #181 and #210–#220
  (titles, bodies, labels) from GraphQL/Ferry to REST, preserving acceptance
  criteria intent.
- **hotelyn_domain:** `Hotel`/`Room` now use `json_serializable`
  (`FieldRename.snake`); generated `*.g.dart` committed. The generated `fromJson`
  reproduces the old hand-written RPC row mappers exactly.
- **hotelyn_gql → hotelyn_api_client:** renamed the package and rebuilt it as a
  `package:http` REST client (`HotelynApiClient`) with `getNearbyHotels`,
  `getRecommendedHotels`, `getRooms`, a JWT token provider, and a typed
  `ApiException`.
- **backend (Dart Frog):** dropped `graphql_schema2`/`graphql_server2` and the
  `POST /graphql` endpoint; added resource routes `GET /health`,
  `GET /hotels/nearby`, `GET /hotels/recommended`, `GET /hotels/{id}/rooms`. Kept
  the `HotelDataClient`/Supabase seam; it now decodes via `Hotel.fromJson`.
- **apps + docs:** `GRAPHQL_URL`/`graphqlUrl` → `API_BASE_URL`/`apiBaseUrl`
  (default drops the `/graphql` suffix) across both apps' config, bootstrap
  guards, `.dart_defines/*.example`, and tests. Updated `CLAUDE.md` and
  `README.md`.

## Verification
- `flutter analyze` / `dart analyze` clean on all changed packages (including
  `--fatal-infos`).
- Tests pass: hotelyn_domain (11), hotelyn_api_client (7), backend (14), both app
  `app_config` suites.
- Codegen re-runs to a no-op diff; `dart format --set-exit-if-changed` clean.
- End-to-end: `dart_frog build` compiled the route tree; the running server
  returned `/health` → 200, missing/invalid params → 400, wrong method → 405, and
  valid hotel requests reached the Supabase data layer (→ 500 with no internal
  leak, since no live DB was attached). Build artifacts cleaned up.

## Notes / follow-ups
- Auth OTP, reservations/holds, messaging, and realtime endpoints (#214–216,
  #218–220) are **not** implemented in code — only their issues were rewritten to
  REST. They remain future work under their now-REST issues.
- Nothing committed or pushed on this branch yet.
