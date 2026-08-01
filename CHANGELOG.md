## 0.0.4

* Removed unused `shake_flutter` dependency. It merged
  `FOREGROUND_SERVICE_MEDIA_PROJECTION`, `DETECT_SCREEN_CAPTURE`,
  `READ_EXTERNAL_STORAGE`, `HIGH_SAMPLING_RATE_SENSORS` and a `mediaProjection`
  foreground service into every host app, causing Google Play publishing
  rejections. Shake detection already uses the built-in `sensors_plus` based
  `ShakeDetector`.

## 0.0.1

* TODO: Describe initial release.
