import Flutter
import UIKit
import CoreLocation

public class BackgroundLocationPlusPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

    private var methodChannel: FlutterMethodChannel
    private var eventChannel: FlutterEventChannel
    private var eventSink: FlutterEventSink?

    // MARK: - Init
    init(methodChannel: FlutterMethodChannel, eventChannel: FlutterEventChannel) {
        self.methodChannel = methodChannel
        self.eventChannel = eventChannel
        super.init()
    }

    // MARK: - Register Plugin
    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(
            name: "background_location_plus/methods",
            binaryMessenger: registrar.messenger()
        )

        let eventChannel = FlutterEventChannel(
            name: "background_location_plus/events",
            binaryMessenger: registrar.messenger()
        )

        let instance = BackgroundLocationPlusPlugin(
            methodChannel: methodChannel,
            eventChannel: eventChannel
        )

        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }

    // MARK: - Handle Platform Calls From Flutter
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {

        case "initialize":
            result(true)

        case "configure":
            if let args = call.arguments as? [String: Any] {
                BackgroundLocationManager.shared.configure(with: args)
            }
            result(nil)

        case "requestPermissions":
            BackgroundLocationManager.shared.requestPermissions { granted in
                result(granted)
            }

        case "start":
            BackgroundLocationManager.shared.start()
            result(true)

        case "stop":
            BackgroundLocationManager.shared.stop()
            result(true)

        case "isRunning":
            result(BackgroundLocationManager.shared.isRunning)

        case "openAppSettings":
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
            result(true)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - FlutterStreamHandler
    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        BackgroundLocationManager.shared.eventSink = eventSink
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        BackgroundLocationManager.shared.eventSink = nil
        return nil
    }
}
