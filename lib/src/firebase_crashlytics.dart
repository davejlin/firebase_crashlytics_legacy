// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
part of firebase_crashlytics;

/// The entry point for accessing a [FirebaseCrashlytics].
///
/// You can get an instance by calling [FirebaseCrashlytics.instance].
class FirebaseCrashlytics extends FirebasePluginPlatform {
  /// Cached instance of [FirebaseCrashlytics];
  static /*late*/ FirebaseCrashlytics _instance;

  // Cached and lazily loaded instance of [FirebaseCrashlyticsPlatform] to avoid
  // creating a [MethodChannelFirebaseCrashlytics] when not needed or creating an
  // instance with the default app before a user specifies an app.
  FirebaseCrashlyticsPlatform _delegatePackingProperty;

  FirebaseCrashlyticsPlatform get _delegate {
    return _delegatePackingProperty ??= FirebaseCrashlyticsPlatform.instanceFor(
        app: app, pluginConstants: pluginConstants);
  }

  /// The [FirebaseApp] for this current [FirebaseCrashlytics] instance.
  FirebaseApp app;

  FirebaseCrashlytics._({this.app})
      : super(app.name, 'plugins.flutter.io/firebase_crashlytics');

  /// Returns an instance using the default [FirebaseApp].
  static FirebaseCrashlytics get instance {
    return _instance ??= FirebaseCrashlytics._(app: Firebase.app());
  }

  /// Whether the current Crashlytics instance is collecting reports. If false,
  /// then no crash reporting data is sent to Firebase.
  ///
  /// See [setCrashlyticsCollectionEnabled] for toggling collection status.
  bool get isCrashlyticsCollectionEnabled {
    return _delegate.isCrashlyticsCollectionEnabled;
  }

  /// Checks a device for any fatal or non-fatal crash reports that haven't yet
  /// been sent to Crashlytics.
  ///
  /// If automatic data collection is enabled, then reports are uploaded
  /// automatically and this always returns false. If automatic data collection
  /// is disabled, this method can be used to check whether the user opts-in to
  /// send crash reports from their device.
  Future<bool> checkForUnsentReports() {
    return _delegate.checkForUnsentReports();
  }

  /// Causes the app to crash (natively).
  ///
  /// This should only be used for testing purposes in cases where you wish to
  /// simulate a native crash to view the results on the Firebase Console.
  ///
  /// Note: crash reports will not include a stack trace.
  void crash() {
    return _delegate.crash();
  }

  /// If automatic data collection is disabled, this method queues up all the
  /// reports on a device for deletion. Otherwise, this method is a no-op.
  Future<void> deleteUnsentReports() {
    return _delegate.deleteUnsentReports();
  }

  /// Checks whether the app crashed on its previous run.
  Future<bool> didCrashOnPreviousExecution() {
    return _delegate.didCrashOnPreviousExecution();
  }

  /// Submits a Crashlytics report of a caught error.
  Future<void> recordError(dynamic exception, StackTrace stack,
      {dynamic reason,
      Iterable<DiagnosticsNode> information,
      bool /*?*/ printDetails}) async {
    // If [null] is provided, use the debug flag instead.
    printDetails ??= kDebugMode;

    final String _information = (information == null || information.isEmpty)
        ? ''
        : (StringBuffer()..writeAll(information, '\n')).toString();

    if (printDetails) {
      print('----------------FIREBASE CRASHLYTICS----------------');

      // If available, give a reason to the exception.
      if (reason != null) {
        print('The following exception was thrown $reason:');
      }

      // Need to print the exception to explain why the exception was thrown.
      print(exception);

      // Print information provided by the Flutter framework about the exception.
      if (_information.isNotEmpty) print('\n$_information');

      // Not using Trace.format here to stick to the default stack trace format
      // that Flutter developers are used to seeing.
      if (stack != null) print('\n$stack');
      print('----------------------------------------------------');
    }

    // The stack trace can be null. To avoid the following exception:
    // Invalid argument(s): Cannot create a Trace from null.
    // We can check for null and provide an empty stack trace.
    stack ??= StackTrace.current ?? StackTrace.fromString('');

    // Report error.
    final List<String> stackTraceLines =
        Trace.format(stack).trimRight().split('\n');
    final List<Map<String, String>> stackTraceElements =
        getStackTraceElements(stackTraceLines);

    return _delegate.recordError(
      exception: exception.toString(),
      reason: reason?.toString(),
      information: _information,
      stackTraceElements: stackTraceElements,
    );
  }

  /// Submits a Crashlytics report of a non-fatal error caught by the Flutter framework.
  Future<void> recordFlutterError(FlutterErrorDetails flutterErrorDetails) {
    assert(flutterErrorDetails != null);
    FlutterError.dumpErrorToConsole(flutterErrorDetails, forceReport: true);
    return recordError(
        flutterErrorDetails.exceptionAsString(), flutterErrorDetails.stack,
        reason: flutterErrorDetails.context,
        printDetails: false,
        information: flutterErrorDetails.informationCollector == null
            ? null
            : flutterErrorDetails.informationCollector());
  }

  /// Logs a message that's included in the next fatal or non-fatal report.
  ///
  /// Logs are visible in the session view on the Firebase Crashlytics console.
  ///
  /// Newline characters are stripped and extremely long messages are truncated.
  /// The maximum log size is 64k. If exceeded, the log rolls such that messages
  /// are removed, starting from the oldest.
  Future<void> log(String message) async {
    assert(message != null);
    return _delegate.log(message);
  }

  /// If automatic data collection is disabled, this method queues up all the
  /// reports on a device to send to Crashlytics. Otherwise, this method is a no-op.
  Future<void> sendUnsentReports() {
    return _delegate.sendUnsentReports();
  }

  /// Enables/disables automatic data collection by Crashlytics.
  ///
  /// If this is set, it overrides the data collection settings provided by the
  /// Android Manifest, iOS Plist settings, as well as any Firebase-wide automatic
  /// data collection settings.
  ///
  /// If automatic data collection is disabled for Crashlytics, crash reports are
  /// stored on the device. To check for reports, use the [checkForUnsentReports]
  /// method. Use [sendUnsentReports] to upload existing reports even when automatic
  /// data collection is disabled. Use [deleteUnsentReports] to delete any reports
  /// stored on the device without sending them to Crashlytics.
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) {
    assert(enabled != null);
    return _delegate.setCrashlyticsCollectionEnabled(enabled);
  }

  /// Records a user ID (identifier) that's associated with subsequent fatal and
  /// non-fatal reports.
  ///
  /// The user ID is visible in the session view on the Firebase Crashlytics console.
  /// Identifiers longer than 1024 characters will be truncated.
  ///
  /// Ensure you have collected permission to store any personal identifiable information
  /// from the user if required.
  Future<void> setUserIdentifier(String identifier) {
    assert(identifier != null);
    return _delegate.setUserIdentifier(identifier);
  }

  /// Sets a custom key and value that are associated with subsequent fatal and
  /// non-fatal reports.
  ///
  /// Multiple calls to this method with the same key update the value for that key.
  /// The value of any key at the time of a fatal or non-fatal event is associated
  /// with that event. Keys and associated values are visible in the session view
  /// on the Firebase Crashlytics console.
  ///
  /// Accepts a maximum of 64 key/value pairs. New keys beyond that limit are
  /// ignored. Keys or values that exceed 1024 characters are truncated.
  ///
  /// The value can only be a type [int], [num], [String] or [bool].
  Future<void> setCustomKey(String key, dynamic value) async {
    assert(key != null);
    assert(value != null);
    assert(value is int || value is num || value is String || value is bool);
    return _delegate.setCustomKey(key, value.toString());
  }
}
