package com.uniqtech.dicabs;

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.os.Looper
import androidx.core.content.ContextCompat
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine
import android.util.Log
import android.content.Context
import android.os.Build
import android.os.PowerManager

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.uniqtech.dicabs/AndroidChannel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startTracking" -> {
                    Log.d("MainActivity", "startTracking method called")
                    startTracking()
                    result.success(null)
                }
                "stopTracking" -> {
                    Log.d("MainActivity", "stopTracking method called")
                    stopTracking()
                    result.success(null)
                }
                "isBatteryOptimized" -> {
                    Log.d("MainActivity", "Checking battery optimization")
                    val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                    val packageName = applicationContext.packageName
                    val isOptimized = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        !pm.isIgnoringBatteryOptimizations(packageName)
                    } else {
                        false
                    }
                    result.success(isOptimized)
                }
                else -> {
                    Log.d("MainActivity", "Method not implemented: ${call.method}")
                    result.notImplemented()
                }
            }
        }
    }

    private fun startTracking() {
        // Start location tracking (start your service or use a similar approach)
        Log.d("MainActivity", "Starting location tracking")
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)
                == PackageManager.PERMISSION_GRANTED) {
            val intent = Intent(this, MyLocationService::class.java).apply {
                action = "START_TRACKING"
            }
            ContextCompat.startForegroundService(this, intent)
        }
    }

    private fun stopTracking() {
        Log.d("MainActivity", "Stopping location tracking")
        val intent = Intent(this, MyLocationService::class.java).apply {
            action = "STOP_TRACKING"
        }
        startService(intent)
    }
}
