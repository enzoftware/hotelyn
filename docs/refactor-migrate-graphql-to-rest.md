# refactor(api)!: migrate app↔backend protocol from GraphQL to REST

- **PR:** #230 — https://github.com/enzoftware/hotelyn/pull/230
- **Branch:** refactor/migrate-graphql-to-rest → main
- **Status:** open
- **Created:** 2026-07-08
- **Author:** Enzo Lizama

## Summary
Makes **REST the single protocol** between the Flutter apps and the Dart Frog
backend, replacing the GraphQL/Ferry direction. The GraphQL surface was small —
only the geo-search slice was implemented and no app code consumed it yet — so
the switch is mostly mechanical while removing indirection that hurt readability.
The branch also carries the not-yet-merged geo-search commit (`1353da1`, "…over
GraphQL"), which is included here and superseded by the migration in the same PR.
The 12 open GraphQL/Ferry GitHub issues were rewritten to their REST equivalents.

## Changes
- **backend (Dart Frog):** dropped `graphql_schema2`/`graphql_server2` and the
  `POST /graphql` endpoint; added resource routes `GET /health`,
  `GET /hotels/nearby`, `GET /hotels/recommended`, `GET /hotels/{id}/rooms` plus a
  `query_params` helper and route middleware. Kept the `HotelDataClient`/Supabase
  seam; it now decodes rows via `Hotel.fromJson`.
- **hotelyn_gql → hotelyn_api_client:** renamed the package and rebuilt it as a
  `package:http` REST client (`HotelynApiClient`) with `getNearbyHotels`,
  `getRecommendedHotels`, `getRooms`, a JWT token provider, and a typed
  `ApiException`.
- **hotelyn_domain:** `Hotel`/`Room` now use `json_serializable`
  (`FieldRename.snake`); generated `*.g.dart` committed. The generated `fromJson`
  reproduces the old hand-written RPC row mappers exactly.
- **apps (both):** `GRAPHQL_URL`/`graphqlUrl` → `API_BASE_URL`/`apiBaseUrl`
  (default drops the `/graphql` suffix) across `hotelyn_app` and
  `hotelyn_dashboard` config, bootstrap guards, `.dart_defines/*.example`, and
  tests.
- **db (Supabase):** geo-search migration `20260707140000_geo_search.sql`
  (nearby/recommended/rooms RPCs), seed update, and `geo_search_test.sql` — from
  the carried geo-search commit.
- **docs + tooling:** updated `CLAUDE.md` and `README.md`; added the
  `/document-pr` skill and `docs/` work log (this entry seeded).
- **Issues (GitHub):** renamed epic labels `epic:dart-frog-gql → epic:rest-api`
  and `epic:ferry-client → epic:rest-client`; rewrote #181 and #210–#220 (titles,
  bodies, labels) from GraphQL/Ferry to REST, preserving acceptance-criteria
  intent.

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
- Breaking: the app↔backend transport is now REST. `POST /graphql` is gone,
  `hotelyn_gql` is replaced by `hotelyn_api_client`, and `GRAPHQL_URL` is renamed
  to `API_BASE_URL` (no `/graphql` suffix).
- Auth OTP, reservations/holds, messaging, and realtime endpoints (#214–216,
  #218–220) are **not** implemented in code — only their issues were rewritten to
  REST. They remain future work under their now-REST issues.
