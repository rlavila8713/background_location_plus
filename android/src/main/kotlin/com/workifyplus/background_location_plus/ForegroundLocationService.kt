package com.workifyplus.background_location_plus

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.os.Build
import android.os.Looper
import androidx.core.app.NotificationCompat
import com.google.android.gms.location.*
import io.flutter.plugin.common.EventChannel
import android.util.Log
import com.google.android.gms.location.Priority


class ForegroundLocationService : Service() {

  companion object {
    private const val CHANNEL_ID = "bg_loc_channel"
    private const val NOTIF_ID = 888
    private var sink: EventChannel.EventSink? = null

    fun setEventSink(s: EventChannel.EventSink?) { sink = s }

    private var running = false
    fun isRunning(): Boolean = running

    // 🔥 CONFIG DINÁMICA DESDE "configure"
    var updateInterval: Long = 5000L
    var minDistance: Float = 10f
    var priority: Int = Priority.PRIORITY_HIGH_ACCURACY

    fun applyConfig(interval: Int, distance: Float, prio: Int) {
        updateInterval = interval.toLong()
        minDistance = distance
        priority = prio
    }
  }

  private lateinit var fusedClient: FusedLocationProviderClient
  private lateinit var locationCallback: LocationCallback

  override fun onCreate() {
    super.onCreate()
    createNotificationChannel()
    fusedClient = LocationServices.getFusedLocationProviderClient(this)

    locationCallback = object: LocationCallback() {
      override fun onLocationResult(result: LocationResult) {
        try {
          result.locations.forEach { loc ->
            val map = hashMapOf<String, Any?>(
              "latitude" to loc.latitude,
              "longitude" to loc.longitude,
              "accuracy" to loc.accuracy.toDouble(),
              "speed" to loc.speed.toDouble(),
              "timestamp" to loc.time
            )
            sink?.success(map)
          }
        } catch (e: Exception) {
          Log.e("BGLocationService", "Error sending location event: ${e.message}")
        }
      }

      override fun onLocationAvailability(availability: LocationAvailability) {
        val av = hashMapOf<String, Any?>("availability" to availability.isLocationAvailable)
        sink?.success(av)
      }
    }
  }

  override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
    running = true
    startForeground(NOTIF_ID, buildNotification("Tracking active"))
    startLocationUpdates()
    return START_STICKY
  }

  override fun onDestroy() {
    stopLocationUpdates()
    running = false
    super.onDestroy()
  }

  override fun onBind(intent: Intent?): IBinder? = null

  private fun startLocationUpdates() {
    // 🔥 USAR CONFIGURACIÓN REAL DESDE configure()
    val request = LocationRequest.Builder(updateInterval)
      .setPriority(priority)
      .setMinUpdateDistanceMeters(minDistance)
      .setMinUpdateIntervalMillis(updateInterval)
      .build()

    try {
      fusedClient.requestLocationUpdates(request, locationCallback, Looper.getMainLooper())
    } catch (sec: SecurityException) {
      sink?.success(mapOf("error" to "Missing location permission"))
    } catch (e: Exception) {
      sink?.success(mapOf("error" to e.message))
    }
  }

  private fun stopLocationUpdates() {
    try {
      fusedClient.removeLocationUpdates(locationCallback)
    } catch (e: Exception) {
      // ignore
    }
  }

  private fun buildNotification(text: String): Notification {
    val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
    val openIntent = packageManager.getLaunchIntentForPackage(packageName)
    val pendingIntent = PendingIntent.getActivity(
      this, 0, openIntent,
      PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
    )

    val builder = NotificationCompat.Builder(this, CHANNEL_ID)
      .setContentTitle("Trip tracking")
      .setContentText(text)
      .setSmallIcon(android.R.drawable.ic_menu_mylocation)
      .setContentIntent(pendingIntent)
      .setOngoing(true)
      .setPriority(NotificationCompat.PRIORITY_LOW)

    return builder.build()
  }

  private fun createNotificationChannel() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
      val channel = NotificationChannel(CHANNEL_ID, "Background Location", NotificationManager.IMPORTANCE_LOW)
      channel.setSound(null, null)
      nm.createNotificationChannel(channel)
    }
  }
}
