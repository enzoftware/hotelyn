// Placeholder Edge Function (INFRA-901).
//
// Edge Functions are WEBHOOKS-ONLY: external HTTP callbacks such as payment
// provider notifications, SMS delivery receipts, or third-party push hooks.
// They MUST NOT contain hold/availability/auth/messaging business logic — that
// lives in the Dart Frog server (hotelyn_server). See the README in this folder.
//
// JWT verification is disabled for this function (see supabase/config.toml)
// because external providers can't present a Supabase JWT. Authentication is
// therefore done in-handler by verifying an HMAC-SHA256 signature of the raw
// body against a shared secret. This is the shape a real provider handler
// should keep; replace the acknowledgement with real provider handling, but do
// NOT drop the signature check and do NOT add domain logic here.

/** Header carrying the hex-encoded HMAC-SHA256 signature of the raw body. */
const SIGNATURE_HEADER = "x-webhook-signature";

/** Env var holding the shared signing secret. Never commit its value. */
const SECRET_ENV = "WEBHOOK_SIGNING_SECRET";

function json(body: unknown, status: number, headers: HeadersInit = {}): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json", ...headers },
  });
}

/** Hex-encode bytes, e.g. for comparing an HMAC digest. */
function toHex(bytes: ArrayBuffer): string {
  return Array.from(new Uint8Array(bytes))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

/**
 * Constant-time string comparison, so a caller can't learn the expected
 * signature byte-by-byte from response timing.
 */
function timingSafeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) {
    diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }
  return diff === 0;
}

/**
 * Compute the hex HMAC-SHA256 of the raw `body` bytes under `secret`. Signing
 * the original bytes (not a UTF-8 round-trip) keeps it correct for binary or
 * non-UTF-8 payloads a provider might send.
 */
async function sign(secret: string, body: ArrayBuffer): Promise<string> {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign("HMAC", key, body);
  return toHex(signature);
}

/**
 * Handle an inbound webhook callback.
 *
 * - Only `POST` is accepted (405 otherwise).
 * - The function must be configured with a signing secret (500 if missing —
 *   it's a deployment error, not a caller error).
 * - The request must carry a valid `x-webhook-signature` over the raw body
 *   (401 if the header is missing or the signature doesn't match).
 */
export async function handleWebhook(request: Request): Promise<Response> {
  if (request.method !== "POST") {
    return json({ error: "method_not_allowed" }, 405, { allow: "POST" });
  }

  const secret = Deno.env.get(SECRET_ENV);
  if (!secret) {
    // Fail closed: never accept a webhook when we can't authenticate it.
    return json({ error: "server_misconfigured" }, 500);
  }

  const provided = request.headers.get(SIGNATURE_HEADER);
  if (!provided) {
    return json({ error: "missing_signature" }, 401);
  }

  const body = await request.arrayBuffer();
  const expected = await sign(secret, body);
  if (!timingSafeEqual(provided, expected)) {
    return json({ error: "invalid_signature" }, 401);
  }

  // Authenticated. A real handler would dispatch on the payload here; the
  // placeholder just acknowledges receipt.
  return json({ received: true }, 200);
}

// Only start the server when run as the entrypoint, so tests can import
// `handleWebhook` without binding a port.
if (import.meta.main) {
  Deno.serve(handleWebhook);
}
