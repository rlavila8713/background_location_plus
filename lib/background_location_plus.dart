import 'dart:async';

import 'package:flutter/services.dart';

part 'src/background_location_plus_method_channel.dart';

/// Main entry for the plugin
class BackgroundLocationPlus {
  static final _impl = MethodChannelBackgroundLocationPlus();

  /// Initialize the native parts (optional config map)
  static Future<void> initialize({Map<String, dynamic>? config}) =>
      _impl.initialize(config ?? {});

  /// configure
  static Future<void> configure({
    String? accuracy,
    int? timeInterval,
    double? distanceFilter,
  }) => _impl.configure(
    accuracy: accuracy,
    timeInterval: timeInterval,
    distanceFilter: distanceFilter,
  );

  /// Start tracking (returns true if started)
  static Future<bool> start() => _impl.start();

  /// Stop tracking
  static Future<bool> stop() => _impl.stop();

  /// Stream of location events (latitude, longitude, timestamp, accuracy, speed)
  static Stream<Map<String, dynamic>> get onLocation => _impl.onLocation;

  /// Check if tracking is active
  static Future<bool> isRunning() => _impl.isRunning();

  /// Request necessary permissions (returns true if granted)
  static Future<bool> requestPermissions() => _impl.requestPermissions();

  /// Opens app settings
  static Future<void> openAppSettings() => _impl.openAppSettings();
}
