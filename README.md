# Firebase Crashlytics Legacy for Flutter

## This is a forked legacy version which fixes the issue [[firebase_crashlytics] 'Flutter/Flutter.h' file not found #5440](https://github.com/FirebaseExtended/flutterfire/issues/5440). ##

The fix: add ```s.dependency 'Flutter'``` under:

```
Pod::Spec.new do |s|
...
  s.dependency 'Flutter'
  s.dependency 'firebase_core'
  s.dependency 'Firebase/Crashlytics', firebase_sdk_version
...
```

... in the file ```ios/firebase_crashlytics.podspec```.

The version of the last legacy release of Firebase Crashlytics was 0.4.0+1, which did not include the fix.  The fix was included in a later null-safe version (v2.0.0).

However, using that version may cause unresolvable conflicts with other dependencies.  This fork is to provide the fix in a legacy compatible version.  This forked version is 0.4.0+2 for consistency.

A Flutter plugin to use the [Firebase Crashlytics API](https://firebase.google.com/docs/crashlytics/).

To learn more about Crashlytics, please visit the [Firebase website](https://firebase.google.com/products/crashlytics)

## Getting Started

To get started with Crashlytics for Flutter, please [see the documentation](https://firebase.flutter.dev/docs/crashlytics/overview)
available at [https://firebase.flutter.dev](https://firebase.flutter.dev/docs/overview)

## Usage

To use this plugin, please visit the [Crashlytics Usage documentation](https://firebase.flutter.dev/docs/crashlytics/usage)

## Issues and feedback

Please file FlutterFire specific issues, bugs, or feature requests in our [issue tracker](https://github.com/FirebaseExtended/flutterfire/issues/new).

Plugin issues that are not specific to Flutterfire can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

To contribute a change to this plugin,
please review our [contribution guide](https://github.com/FirebaseExtended/flutterfire/blob/master/CONTRIBUTING.md)
and open a [pull request](https://github.com/FirebaseExtended/flutterfire/pulls).
