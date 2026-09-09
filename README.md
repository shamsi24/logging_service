This project is fork of https://github.com/samiraghayev12/logging

## Google Play: FOREGROUND_SERVICE_MEDIA_PROJECTION

`logging_service` never records or captures the screen and declares no
media-projection permission. Versions before `0.0.4` depended on
`shake_flutter`, which merged
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
