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
server-provided message when one is present.

## Methods

| Method | Endpoint |
| --- | --- |
| `getNearbyHotels({lat, lng, radiusKm})` | `GET /hotels/nearby` |
| `getRecommendedHotels({lat, lng, radiusKm})` | `GET /hotels/recommended` |
| `getRooms({hotelId})` | `GET /hotels/{id}/rooms` |

Auth, reservation, and messaging methods are added as their endpoints land
(see issues FE-2002, FE-2004).

## Testing

Inject `http`'s `MockClient` via the `httpClient` parameter to assert request
URLs/bodies and drive canned responses — no live server needed.
