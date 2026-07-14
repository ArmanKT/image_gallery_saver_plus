# Changelog

## 5.1.0

- Added an optional `creationDate` parameter to `saveImage` and `saveFile`.
- Added iOS support for preserving custom creation dates for saved images and videos.
- Lowered the minimum supported versions to Dart 3.9.2 and Flutter 3.35.6.

## 5.0.0

- Added Swift Package Manager (SPM) support for iOS alongside CocoaPods.
- Raised minimum iOS support to 13.0.
- Raised Flutter SDK support to 3.38.0+ and Dart SDK support to >=3.10.0.
- Updated Android Gradle Plugin to 8.13.2 and Gradle wrapper to 8.14.5.
- Applied the Kotlin Android plugin to the Android plugin module and example app for current AGP compatibility.
- Updated Android media saving for scoped storage by using pending MediaStore entries on Android 10 and newer.
- Added legacy write-storage permission support for Android 9 and older.
- Removed obsolete Android manifest package declaration now that AGP uses the Gradle namespace.
- Cleaned up Android plugin Kotlin code by removing unused imports, clamping JPEG quality, and cleaning up failed media writes.
- Fixed the Android unit test to match the current plugin API.
- Removed legacy `fluttertoast` dependency from the example app, replacing it with `ScaffoldMessenger` SnackBar alerts.
- Fixed local file URL crash in `saveImageAtFileUrl` by using `URL(fileURLWithPath:)`.
- Fixed JSON result serialization bug in `SaveResultModel.toDic()`.

## 4.0.1

- Fix: Avoid Double Read Issue and Use copyTo() for Efficient File Copying

## 4.0.0

- Support for the latest Gradle version.
- Compatibility with the latest Flutter version.
- Fixed issues related to deprecated Android APIs.
- Resolved compiling errors due to unused and old Kotlin code.
- Support for the latest Android Studio Ladybug with Flutter 3.29.*.

## 4.0.0-0.alpha

- Support for the latest Gradle version.
- Compatibility with the latest Flutter version.
- Fixed issues related to deprecated Android APIs.
- Resolved compiling errors due to unused and old Kotlin code.
- Support for the latest Android Studio Ladybug with Flutter 3.24.5.

## 3.0.5

- Stable Release: Marked as the stable release version.
- iOS Issue Resolved: Fixed issues affecting the iOS platform.
- Gradle Updated: Updated the Gradle configuration for better compatibility and performance.

## 3.0.4

- Readme doc updated.

## 3.0.3

- Fixed Ios Download Issue.

## 3.0.2

- Compatible with the latest Flutter version.

## 3.0.1

- Compatible with the latest Flutter version.

## 3.0.0

- Compatible with the latest Flutter version.
