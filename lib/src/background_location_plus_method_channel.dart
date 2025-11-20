part of '../background_location_plus.dart';

/// An implementation of [BackgroundLocationPlusPlatform] that uses method channels.
class MethodChannelBackgroundLocationPlus {
  static const MethodChannel _method = MethodChannel(
    'background_location_plus/methods',
  );
  static const EventChannel _event = EventChannel(
    'background_location_plus/events',
  );

  StreamController<Map<String, dynamic>>? _locController;

  Future<void> configure({
    double? distanceFilter,
    int? timeInterval,
    String? accuracy, // "best", "balanced", "low"
  }) async {
    await _method.invokeMethod("configure", {
      "distanceFilter": distanceFilter,
      "timeInterval": timeInterval,
      "accuracy": accuracy,
    });
  }

  Future<void> initialize(Map<String, dynamic> config) async {
    await _method.invokeMethod('initialize', config);
    // setup event stream
    _locController ??= StreamController<Map<String, dynamic>>.broadcast();
    _event.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event is Map) {
          _locController?.add(Map<String, dynamic>.from(event));
        }
      },
      onError: (err) {
        _locController?.addError(err);
      },
    );
  }

  Future<bool> start() async {
    final res = await _method.invokeMethod('start');
    return res == true;
  }

  Future<bool> stop() async {
    final res = await _method.invokeMethod('stop');
    return res == true;
  }

  Stream<Map<String, dynamic>> get onLocation {
    _locController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _locController!.stream;
  }

  Future<bool> isRunning() async {
    final res = await _method.invokeMethod('isRunning');
    return res == true;
  }

  Future<bool> requestPermissions() async {
    final res = await _method.invokeMethod('requestPermissions');
    return res == true;
  }

  Future<void> openAppSettings() async {
    await _method.invokeMethod('openAppSettings');
  }
}
