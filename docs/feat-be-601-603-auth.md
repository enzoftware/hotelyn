# feat(auth): guest OTP + staff login over REST, RLS isolation test (BE-601..603)

- **PR:** #234 — https://github.com/enzoftware/hotelyn/pull/234
- **Branch:** feat/be-601-603-auth → main
- **Status:** open
- **Created:** 2026-07-09
- **Author:** Enzo Lizama

## Summary

Adds EPIC-06 authentication, routed through the Dart Frog backend so the apps keep no direct Supabase dependency (per the REST-only architecture). Guests authenticate with an email OTP (request → verify → session); staff authenticate with invite-only email/password. Cross-tenant isolation is proven by extended pgTAP RLS tests, now enforced in CI on any `supabase/**` change.

## Changes

### Backend (Dart Frog)
- New `AuthClient` seam (`SupabaseAuthClient`, [auth_client.dart](../backend/lib/src/data/auth_client.dart)) wrapping GoTrue with the **anon** key and the **implicit** flow (PKCE persisted a code verifier and crashed `signInWithOtp` on the stateless server); all GoTrue calls are timeout-bounded.
- Shared `authAction` + `parseJsonBody` helpers ([auth.dart](../backend/lib/src/http/auth.dart)) centralize auth, error mapping, and validation; unexpected 500s are stderr-logged.
- Three routes: `POST /auth/login` (staff), `POST /auth/otp/request` (202), `POST /auth/otp/verify` (session).
- Registered the auth client in [hotelyn_server.dart](../backend/lib/hotelyn_server.dart) and [_middleware.dart](../backend/routes/_middleware.dart).

### API client (`hotelyn_api_client`)
- Auth methods + typed `AuthApiException` carrying the stable `code`, `retry_after_seconds`, and HTTP status ([api_exception.dart](../packages/hotelyn_api_client/lib/src/api_exception.dart), [hotelyn_api_client.dart](../packages/hotelyn_api_client/lib/src/hotelyn_api_client.dart)).

### Domain (`hotelyn_domain`)
- New `AuthSession` model (access/refresh tokens, user, expiry, token type); tokens redacted from `toString` ([auth_session.dart](../packages/hotelyn_domain/lib/src/auth_session.dart)).

### RLS / CI
- Extended [rls_test.sql](../supabase/tests/rls_test.sql) with staff cross-tenant reservation read/update/delete boundaries (68 pgTAP assertions total).
- Path-filtered GitHub Actions job runs `supabase test db` on every PR touching `supabase/**` ([main.yaml](../.github/workflows/main.yaml)); CLI pinned + `timeout-minutes`.
- [config.toml](../supabase/config.toml) documents invite-only staff and the email-recycling / shared-mailbox caveat (accepted MVP trade-off).

### Dependency note
- Reverts `test` `1.31.0 → 1.30.0` workspace-wide (from #233): `1.31.0` needs `test_api 0.7.11` but the installed Flutter SDK bundles `0.7.10`, so `main` did not resolve. `1.30.0` matches the SDK (see #225).

## Verification

- `supabase db reset` applies cleanly; `supabase test db` green — 68 pgTAP assertions.
- `dart analyze --fatal-infos` clean: `hotelyn_domain`, `hotelyn_api_client`, `backend`.
- `dart test` green — domain (24), api_client (21), backend (70); `dart format` clean.
- Live HTTP e2e through the running Dart Frog server: staff login → JWT, wrong creds → 401, empty/malformed body → 400, OTP request → 202, wrong OTP → 401 `otp_expired`.
- Addressed a CodeRabbit review (19 findings; all actionable ones fixed) — notably `AuthSession.toString()` token leak via Equatable `stringify`, missing GoTrue timeouts, `AuthApiException` dropping HTTP status, and rate-limit detection now keying on the 429 status.

## Notes / follow-ups

- **Flutter login UI** — out of scope (this is the `layer:backend` slice). Rewiring `LoginCubit`/`AuthRepository` to the new flow is an app-layer follow-up.
- **Backend JWT signature verification** (from EPIC-05) still applies to the staff endpoints — tracked follow-up.
- **Account recovery / email-change re-verification** for the recycled-email caveat.
- Closes #175, #176, #177.
