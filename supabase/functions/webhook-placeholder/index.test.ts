import { assertEquals } from "@std/assert";

import { handleWebhook } from "./index.ts";

const SECRET = "test-signing-secret";
const BODY = JSON.stringify({ event: "ping" });

/** Compute the hex HMAC-SHA256 the handler expects, for a given body/secret. */
async function signature(secret: string, body: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const digest = await crypto.subtle.sign(
    "HMAC",
    key,
    new TextEncoder().encode(body).buffer,
  );
  return Array.from(new Uint8Array(digest))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

function request(
  { method = "POST", body = BODY, sig }: {
    method?: string;
    body?: string;
    sig?: string;
  } = {},
): Request {
  const headers = new Headers();
  if (sig !== undefined) headers.set("x-webhook-signature", sig);
  return new Request("http://localhost/webhook-placeholder", {
    method,
    headers,
    body: method === "GET" ? undefined : body,
  });
}

Deno.test("non-POST methods are rejected with 405", async () => {
  Deno.env.set("WEBHOOK_SIGNING_SECRET", SECRET);
  for (const method of ["GET", "PUT", "DELETE", "PATCH"]) {
    const response = await handleWebhook(request({ method }));
    assertEquals(response.status, 405, `${method} should be rejected`);
    assertEquals(response.headers.get("allow"), "POST");
    assertEquals(await response.json(), { error: "method_not_allowed" });
  }
});

Deno.test("returns 500 when the signing secret is not configured", async () => {
  Deno.env.delete("WEBHOOK_SIGNING_SECRET");
  const response = await handleWebhook(
    request({ sig: await signature(SECRET, BODY) }),
  );
  assertEquals(response.status, 500);
  assertEquals(await response.json(), { error: "server_misconfigured" });
});

Deno.test("returns 401 when the signature header is missing", async () => {
  Deno.env.set("WEBHOOK_SIGNING_SECRET", SECRET);
  const response = await handleWebhook(request());
  assertEquals(response.status, 401);
  assertEquals(await response.json(), { error: "missing_signature" });
});

Deno.test("returns 401 when the signature is invalid", async () => {
  Deno.env.set("WEBHOOK_SIGNING_SECRET", SECRET);
  const response = await handleWebhook(request({ sig: "deadbeef" }));
  assertEquals(response.status, 401);
  assertEquals(await response.json(), { error: "invalid_signature" });
});

Deno.test("returns 401 when the signature is for a different body", async () => {
  Deno.env.set("WEBHOOK_SIGNING_SECRET", SECRET);
  const response = await handleWebhook(
    request({ sig: await signature(SECRET, "tampered") }),
  );
  assertEquals(response.status, 401);
  assertEquals(await response.json(), { error: "invalid_signature" });
});

Deno.test("accepts a POST with a valid signature", async () => {
  Deno.env.set("WEBHOOK_SIGNING_SECRET", SECRET);
  const response = await handleWebhook(
    request({ sig: await signature(SECRET, BODY) }),
  );
  assertEquals(response.status, 200);
  assertEquals(response.headers.get("content-type"), "application/json");
  assertEquals(await response.json(), { received: true });
});
