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
