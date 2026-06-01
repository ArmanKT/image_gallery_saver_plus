# Changelog

## 5.0.0

- 1. Added Swift Package Manager (SPM) support for iOS alongside CocoaPods.
- 2. Raised minimum iOS to 13.0, Flutter to 3.41.0, and Dart SDK to >=3.11.0.
- 3. Upgraded Android Gradle Plugin to 8.13.0 and Gradle wrapper to 8.14.
- 4. Migrated plugin and example app to Android AGP-native Built-in Kotlin support (removing standalone KGP dependency).
- 5. Removed legacy `fluttertoast` dependency from example app, replacing it with native, non-KGP `ScaffoldMessenger` SnackBar alerts.
- 6. Fixed local file URL crash in saveImageAtFileUrl (URL(string:) → URL(fileURLWithPath:)).
- 7. Fixed JSON result serialisation bug in SaveResultModel.toDic().

## 4.0.1

- 1. Fix: Avoid Double Read Issue and Use copyTo() for Efficient File Copying

## 4.0.0

- 1. Support for the latest Gradle version.
- 2. Compatibility with the latest Flutter version.
- 3. Fixed issues related to deprecated Android APIs.
- 4. Resolved compiling errors due to unused and old Kotlin code.
- 5. Support for the latest Android Studio Ladybug with Flutter 3.29.\*.

## 4.0.0-0.alpha

- 1. Support for the latest Gradle version.
- 2. Compatibility with the latest Flutter version.
- 3. Fixed issues related to deprecated Android APIs.
- 4. Resolved compiling errors due to unused and old Kotlin code.
- 5. Support for the latest Android Studio Ladybug with Flutter 3.24.5.

## 3.0.5

- 1. Stable Release: Marked as the stable release version.
- 2. iOS Issue Resolved: Fixed issues affecting the iOS platform.
- 3. Gradle Updated: Updated the Gradle configuration for better compatibility and performance.

## 3.0.4

- 1. Readme doc updated.

## 3.0.3

- 1. Fixed Ios Download Issue.

## 3.0.2

- 1. Compatible with the latest Flutter version.

## 3.0.1

- 1. Compatible with the latest Flutter version.

## 3.0.0

- 1. Compatible with the latest Flutter version.
