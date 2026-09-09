# logging_service

Shake to open network inspector for Flutter apps. Attach the interceptor to
your Dio client, shake the device, and read every call the app made — with
credentials masked before they are ever stored.

Fork of https://github.com/samiraghayev12/logging

## Install

```yaml
dependencies:
  logging_service:
    git:
      url: https://github.com/shamsi24/logging_service.git
      ref: v0.1.0
```

## Usage

```dart
import 'package:dio/dio.dart';
import 'package:logging_service/logging_service.dart';

final dio = Dio()..interceptors.add(DioLoggingInterceptor());

// Somewhere below MaterialApp, once:
final debugTool = DebugTool()..start(context);
```

Shake the device to open the inspector, or call `debugTool.open(context)`.
Both the interceptor and `DebugTool` are inactive outside debug builds unless
you pass `enabled: true`.

## Redaction

Secrets are masked at capture time, so they never reach the store, the console
output, the detail screen or a cURL export.

Masked by default: `Authorization`, `Proxy-Authorization`, `Cookie`,
`Set-Cookie`, `X-Api-Key` and similar headers; `password`, `pin`, `otp`,
`token`, `access_token`, `refresh_token`, `client_secret`, `card_number`,
`cvv` and similar body keys at any nesting depth; the same names as query
parameters.

```dart
DioLoggingInterceptor(
  redaction: const RedactionConfig().extend(
    headerKeys: {'x-tenant-signature'},
    bodyKeys: {'iban', 'national_id'},
  ),
);
```

`const RedactionConfig.disabled()` turns masking off. Only do that on a
throwaway environment.

## Copy as cURL

The terminal icon on the detail screen copies the call as a runnable cURL
command. Values are the redacted ones, so a command pasted into a ticket
carries no real credential.

```dart
final command = CurlBuilder.build(NetworkLogStore.instance.entries.first);
```

## Search and filters

The call list filters on a free text query (URL, method or status code), on
HTTP method chips, and on the outcome (all / success / error). It updates live
while calls arrive.

## Beyond Dio

`NetworkLogEntry` and `NetworkLogStore` reference no HTTP client.
`DioLoggingInterceptor` is only an adapter, so another client can feed the same
store:

```dart
final entry = NetworkLogEntry(
  id: id,
  method: 'GET',
  uri: uri,
  startedAt: DateTime.now(),
);
NetworkLogStore.instance.add(entry);

NetworkLogStore.instance.update(
  id,
  (e) => e.completeWith(completedAt: DateTime.now(), statusCode: 200),
);
```

The store keeps the last 200 calls; pass `NetworkLogStore(maxEntries: ...)` for
a different budget.

## Google Play: FOREGROUND_SERVICE_MEDIA_PROJECTION

`logging_service` is a pure Dart package with no native code, so it
contributes nothing at all to your `AndroidManifest.xml` — no permission, no
service. Versions before `0.0.4` depended on `shake_flutter`, which merged
`android.permission.FOREGROUND_SERVICE_MEDIA_PROJECTION` and a
`mediaProjection` foreground service into every host app — Google Play rejects
uploads that declare it without a user-visible screen-capture feature.

If Play still reports it after upgrading, the permission is coming from the app,
not from this package. Find the real source:

```bash
flutter build appbundle --release
grep -n "MEDIA_PROJECTION" build/app/outputs/logs/manifest-merger-release-report.txt
```

The report names the manifest that injected it. Then:

1. Delete the line if it sits in `android/app/src/main/AndroidManifest.xml`.
2. If another library injects it, strip it in the app manifest:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <uses-permission
        android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PROJECTION"
        tools:node="remove" />
</manifest>
```

3. Rebuild with a clean cache so a stale merged manifest is not reused:

```bash
flutter clean && flutter pub get && flutter build appbundle --release
```
