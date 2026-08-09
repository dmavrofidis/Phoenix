# Phoenix Android release checklist

This checklist keeps Android production work reproducible without changing the developer machine or uploading user data.

## Identity and version

- Confirm `applicationId` is `com.phoenix.fitness`.
- Read `versionName` and `versionCode` from `mobile/pubspec.yaml`; CI or the release operator may override them with Flutter's `--build-name` and `--build-number` flags.
- Build a signed App Bundle only when `mobile/android/key.properties` is supplied outside source control. The repository otherwise uses debug signing for local verification.
- Record the Git commit and Flutter version beside every artifact.

## Privacy and platform configuration

- Android cloud backup and device transfer remain disabled for Phoenix health profiles. Portability is handled through explicit, encrypted `.phx` exports.
- Cleartext traffic is disabled. Optional media links must use HTTPS.
- The only requested permissions are Internet (optional HTTPS media), Camera (explicit meal/photo capture), notification delivery, and boot-completed rescheduling.
- Verify the `phoenix_workout_reminders` notification channel on Android 13+ and confirm denial leaves the app fully usable.
- Verify `phoenix://open` opens Phoenix but never imports, deletes, or changes data without an in-app confirmation.

## Icon and splash audit

- Inspect launcher icons at mdpi, hdpi, xhdpi, xxhdpi and xxxhdpi.
- Inspect both light and dark launch themes.
- Confirm adaptive-icon foreground content stays inside the safe zone.
- Confirm the notification glyph is monochrome and recognizable.
- Capture phone and tablet screenshots without real user data.

## Pre-release commands

Run from `mobile`:

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build appbundle --release --build-name <x.y.z> --build-number <integer>
```

Android SDK/signing may be unavailable on a contributor machine. In that case, do not install or alter system components: record the missing toolchain and run the platform-neutral analyze, tests and web build.

## Manual smoke test

- Start offline, create a local profile, complete a workout and restart the app.
- Deny camera and notification permissions; verify recovery paths.
- Export an encrypted backup, reject a wrong password, then restore with the correct password.
- Exercise profile switching and verify isolation.
- Trigger a reminder inside and outside quiet hours.
- Confirm background privacy shield and vault cooldown.
- Confirm German/Spanish core catalog strings use English fallback where a full translation is not yet present.

## Store gate

- No analytics, advertising ID, mandatory account, remote database, or silent background upload.
- Data-safety answers must match the shipped binary and its optional HTTPS media behavior.
- A human release owner must approve screenshots, content rating, privacy copy and signing before upload.
