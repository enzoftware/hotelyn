# Edge Functions (Deno / TypeScript)

Supabase Edge Functions for Hotelyn. This workspace is **isolated** from the
Dart monorepo: it has its own `deno.json`, its own CI job
(`.github/workflows/ci-edge-functions.yml`), and its own toolchain (Deno). It
imports **nothing** from `packages/*` or `backend/*` and shares **no** type with
the Dart side.

## ⚠️ Use for external HTTP callbacks only

Edge Functions here are **webhooks-only**: external HTTP callbacks such as

- payment provider notifications,
- SMS delivery receipts,
- third-party push-notification hooks.

**No hold / availability / user-auth / messaging logic lives here.** All
business logic — GraphQL resolvers, user/application authentication, realtime,
holds, availability, messaging — lives in the Dart Frog server
(`hotelyn_server`, INFRA-1005). Edge Functions must never duplicate logic that
already exists in the Dart server; they receive an external callback, do minimal
validation, and hand off to the Dart server or Supabase.

Verifying the **provider's** webhook signature (see [Authentication](#authentication)
below) is not application auth — it only proves the callback came from the
expected provider. That check belongs here; everything downstream of it does
not.

## Layout

```
supabase/functions/
├── deno.json               # Deno config + import map for the whole workspace
├── README.md               # this file
└── webhook-placeholder/    # placeholder webhook (replace with real handlers)
    ├── index.ts
    └── index.test.ts
```

## Local development

```bash
# Lint
deno lint

# Test (handlers read the signing secret from the env — no network access)
deno test --allow-env

# Format
deno fmt

# Serve a single function locally (requires `supabase start`)
supabase functions serve webhook-placeholder
```

## Authentication

`verify_jwt` is **off** for webhook functions (external providers can't present
a Supabase JWT), so each handler authenticates the caller itself. The
placeholder verifies an HMAC-SHA256 signature of the raw request body against a
shared secret and **fails closed**:

| Condition                                      | Response |
| ---------------------------------------------- | -------- |
| Non-`POST` method                              | `405`    |
| `WEBHOOK_SIGNING_SECRET` not configured        | `500`    |
| `x-webhook-signature` header missing           | `401`    |
| Signature doesn't match the body               | `401`    |
| Valid signature                                | `200`    |

Real handlers must keep an equivalent provider-signature check — never accept an
unauthenticated callback.

## Secrets

Never commit secrets. Provide the signing secret (`WEBHOOK_SIGNING_SECRET`) and
any provider API keys through Supabase function secrets
(`supabase secrets set WEBHOOK_SIGNING_SECRET=...`) or the local
`supabase/functions/.env` file, which is git-ignored.
