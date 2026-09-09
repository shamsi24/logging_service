## 0.1.0

**Client agnostic core**

* New `NetworkLogEntry` model and `NetworkLogStore` hold captured calls without
  referencing Dio, so adapters for other HTTP clients can reuse them.
* `DioLoggingInterceptor` replaces `DebugLogging` as a thin adapter on top of
  that core. `DebugLogging` still works but is deprecated.
* Calls are now paired by a per request id instead of by URL, so concurrent
  calls to the same endpoint no longer overwrite each other's response.
* Elapsed time is measured per call instead of through one shared `Stopwatch`,
  which reported wrong durations as soon as two calls overlapped.
* A response for an uncaptured request is ignored instead of throwing a null
  check exception.
* The store is a ring buffer (200 calls by default), so a long session no
  longer grows without bound.

**Credential redaction**

* `RedactionConfig` masks `Authorization`, `Cookie`, `password`, `token`,
  card data and more, in headers, bodies and query parameters. It is on by
  default and runs at capture time, so a secret never reaches the store, the
  console, the detail screen or a cURL export.
* Use `RedactionConfig.extend(...)` to add project specific keys, or
  `RedactionConfig.disabled()` to turn masking off.

**Console output**

* Console printing moved out of the Dio adapter into `NetworkLogPrinter`, so
  any adapter renders the same way.
* A successful call is now a single line — method, path, status, duration and
  response size. A failed one expands into a framed block with both header
  maps, both bodies and a ready to run cURL command, which is the only case
  where the detail is worth the scrollback.
* ANSI colors by method and status class, off with `useColors: false`.
* Error blocks are indented with spaces rather than a box prefix, so the body
  and the cURL command stay copy-paste clean from a terminal. Long bodies are
  cut at `maxBodyLines` (40 by default) with a note saying how much was
  dropped.
* `DioLoggingInterceptor(printer: ...)` replaces `printToConsole`; pass `null`
  to capture silently.

**cURL export**

* `CurlBuilder.build(entry)` renders a call as a runnable cURL command, exposed
  in the detail screen through the terminal icon. Quoting is escaped for POSIX
  shells.

**Search and filters**

* The call list has a search field (URL, method, status code), HTTP method
  chips and an all / success / error filter.
* The list updates live while calls arrive, has a clear action, an empty state
  and shows status code, duration and response size per row.

**Other**

* Single entry point: `import 'package:logging_service/logging_service.dart'`.
* `FormData` request bodies are flattened and shown instead of the previous
  "not supported yet" placeholder.
* The inspector follows the app theme instead of hardcoded black text.
* `DebugTool.open(context)` opens the inspector without a shake, and
  `DebugTool(enabled: ...)` keeps it reachable on profile or release builds.
* Added unit and widget tests.

**Pure Dart package**

* Removed the Android, iOS, macOS, Linux, Windows and web plugin scaffolding.
  It only ever returned the platform version and was never called from Dart.
* The package no longer contributes anything to the host `AndroidManifest.xml`,
  which removes the whole class of manifest merge problems that caused the
  earlier Google Play rejections. The `tools:node="remove"` marker added in
  `0.0.5` is gone with it; if a permission still reaches your app it comes from
  another library, and the README explains how to strip it app side.
* Fixes the broken web build: `pubspec.yaml` declared a web plugin class in
  `lib/logging_service_web.dart`, a file that never existed.
* Dropped the now unused `flutter_web_plugins`, `web` and
  `plugin_platform_interface` dependencies.

**Breaking**

* `DebugModel`, `DebugStorage` and `DebugPage` are removed. Use
  `NetworkLogEntry`, `NetworkLogStore` and `LogsPage`.
* The package is no longer a Flutter plugin. Run `flutter clean` once after
  upgrading so the generated plugin registrant is rebuilt.

## 0.0.5

* Android manifest now explicitly removes `FOREGROUND_SERVICE_MEDIA_PROJECTION`
  from the merged manifest, so stale `shake_flutter` leftovers in a host app's
  library graph or build cache no longer trigger Google Play rejections.

## 0.0.4

* Removed unused `shake_flutter` dependency. It merged
  `FOREGROUND_SERVICE_MEDIA_PROJECTION`, `DETECT_SCREEN_CAPTURE`,
  `READ_EXTERNAL_STORAGE`, `HIGH_SAMPLING_RATE_SENSORS` and a `mediaProjection`
  foreground service into every host app, causing Google Play publishing
  rejections. Shake detection already uses the built-in `sensors_plus` based
  `ShakeDetector`.

## 0.0.1

* TODO: Describe initial release.
