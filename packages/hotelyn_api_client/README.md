# hotelyn_api_client

REST client for the Hotelyn Dart Frog API. It is the single seam through which
the Flutter apps reach the backend — the apps never depend on `supabase` or on
any transport detail; they call typed methods that return `hotelyn_domain`
entities.

## Usage

```dart
final client = HotelynApiClient(
  baseUrl: AppConfig.apiBaseUrl, // e.g. http://127.0.0.1:8080
  tokenProvider: () async => storage.readAccessToken(),
);

final hotels = await client.getNearbyHotels(
  lat: -12.11,
  lng: -77.03,
  radiusKm: 200,
);
```

`baseUrl` is the server root (no path suffix). The optional `tokenProvider` is
called before every request to obtain the Supabase JWT, which is attached as a
`Bearer` token in the `Authorization` header; return `null` when signed out.

Non-2xx responses throw an `ApiException` carrying the HTTP `statusCode` and the
server-provided message when one is present. Two typed subtypes let callers
react to specific failures without string-matching:

- `RoomAlreadyHeldException` — a `409` from `createReservationHold` (the room was
  grabbed first). Still an `ApiException`, so a generic `catch` handles it too.
- `AuthApiException` — an auth failure carrying the server's stable `code`
  (e.g. `otp_expired`, `invalid_credentials`) and, for rate limits,
  `retryAfterSeconds`.

## Methods

### Discovery

| Method | Endpoint |
| --- | --- |
| `getNearbyHotels({lat, lng, radiusKm})` | `GET /hotels/nearby` |
| `getRecommendedHotels({lat, lng, radiusKm})` | `GET /hotels/recommended` |
| `getRooms({hotelId})` | `GET /hotels/{id}/rooms` |

### Reservations

| Method | Endpoint |
| --- | --- |
| `createReservationHold({hotelId, roomId, checkIn, checkOut})` | `POST /hotels/{id}/holds` |
| `confirmReservation({reservationId})` | `POST /reservations/{id}/confirm` |
| `rejectReservation({reservationId})` | `POST /reservations/{id}/reject` |

### Staff inventory

| Method | Endpoint |
| --- | --- |
| `getStaffRooms()` | `GET /staff/rooms` |
| `setRoomAvailability({roomId, isAvailable})` | `PATCH /staff/rooms/{id}/availability` |

`getStaffRooms` is scoped to the acting staff member's hotel via the caller's
token — there is no hotel parameter.

### Auth

| Method | Endpoint |
| --- | --- |
| `requestEmailOtp({email})` | `POST /auth/otp/request` |
| `verifyEmailOtp({email, token})` | `POST /auth/otp/verify` |
| `signInWithPassword({email, password})` | `POST /auth/login` |

Call `close()` to release the underlying HTTP client when the client is disposed.

## Testing

Inject `http`'s `MockClient` via the `httpClient` parameter to assert request
URLs/bodies and drive canned responses — no live server needed.
