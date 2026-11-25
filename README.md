# Doodh Hisaab

Doodh Hisaab is an offline-first milk ledger for households. Record daily
deliveries, skipped days, rate changes and payments; track the running balance;
and share a monthly bill as a PDF.

## Requirements

- Flutter 3.50.1 or later (Dart 3.14 or later)
- Android SDK 36 or later
- Android API 24 or later. Flutter 3.50 requires API 24; API 23 is not supported
  by this Flutter version.

## Run and validate

From PowerShell in the project directory:

```powershell
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter run
```

The default language is Hindi. Change the language and theme in Settings.
Core ledger features work without an internet connection.

## Android release

The Android application ID is `com.doodhhisaab.milkledger`. For a signed
production build, create a private keystore and `android/key.properties` as
described in [USER_GUIDE.md](USER_GUIDE.md). Never commit the keystore or its
passwords.

```powershell
flutter build apk --release
flutter build apk --release --split-per-abi
flutter build appbundle --release
```

Without `android/key.properties`, Gradle uses the debug signing key for local
release-build verification only. Do not publish that build.
Use `--split-per-abi` for smaller device-specific APKs; the regular APK includes
all supported ABIs.
