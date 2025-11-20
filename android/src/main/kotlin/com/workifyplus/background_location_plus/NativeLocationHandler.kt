package com.workifyplus.background_location_plus

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import com.google.android.gms.location.Priority

class NativeLocationHandler(
    private val context: Context,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

  private var events: EventChannel.EventSink? = null


  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {

      "configure" -> {
        val interval = call.argument<Int>("timeInterval") ?: 10000
        val distance = call.argument<Double>("distanceFilter")?.toFloat() ?: 0f
        val accuracyStr = call.argument<String>("accuracy") ?: "balanced"

        val priority = when (accuracyStr) {
          "best" -> Priority.PRIORITY_HIGH_ACCURACY
          "balanced" -> Priority.PRIORITY_BALANCED_POWER_ACCURACY
          "low" -> Priority.PRIORITY_LOW_POWER
          else -> Priority.PRIORITY_BALANCED_POWER_ACCURACY
        }

        // 🔥 APLICAR CONFIG GLOBAL AL SERVICIO
        ForegroundLocationService.applyConfig(
          interval,
          distance,
          priority
        )

        result.success(true)
      }

      "initialize" -> {
        result.success(null)
      }

      "start" -> {
        startForegroundService()
        result.success(true)
      }

      "stop" -> {
        stopForegroundService()
        result.success(true)
      }

      "isRunning" -> {
        result.success(ForegroundLocationService.isRunning())
      }

      "requestPermissions" -> {
        result.success(false) // La app debe pedir permisos con permission_handler
      }

      "openAppSettings" -> {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        intent.data = Uri.parse("package:${context.packageName}")
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
        result.success(null)
      }

      else -> result.notImplemented()
    }
  }

  // --- Foreground Service controls ---
  private fun startForegroundService() {
    val intent = Intent(context, ForegroundLocationService::class.java)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      context.startForegroundService(intent)
    } else {
      context.startService(intent)
    }
  }

  private fun stopForegroundService() {
    val intent = Intent(context, ForegroundLocationService::class.java)
    context.stopService(intent)
  }

  // --- Event Channel handlers ---
  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    this.events = events
    ForegroundLocationService.setEventSink(events)
  }

  override fun onCancel(arguments: Any?) {
    this.events = null
    ForegroundLocationService.setEventSink(null)
  }
}
