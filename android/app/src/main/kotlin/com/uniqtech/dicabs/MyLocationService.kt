package com.uniqtech.dicabs

import android.Manifest
import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.net.ConnectivityManager
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import android.os.AsyncTask
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL

class MyLocationService : Service() {
    private lateinit var fusedLocationProviderClient: FusedLocationProviderClient
    private lateinit var locationDatabaseHelper: LocationDatabaseHelper
    private var isTracking = false

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onCreate() {
        super.onCreate()
        locationDatabaseHelper = LocationDatabaseHelper(this)
        fusedLocationProviderClient = LocationServices.getFusedLocationProviderClient(this)
        createNotificationChannel() // Create notification channel if needed
    }
    @RequiresApi(Build.VERSION_CODES.O)
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action
        if (action == "START_TRACKING") {
            startForegroundService()
            startLocationUpdates()
        } else if (action == "STOP_TRACKING") {
            stopLocationUpdates()
            stopForeground(true) // Remove notification
            stopSelf() // Stop the service
        }

        return START_STICKY
    }

    private fun startForegroundService() {
        if (!isTracking) {
            isTracking = true
            val notification = createNotification()
            startForeground(1, notification)
        }
    }

    private fun startLocationUpdates() {
        val locationRequest = LocationRequest.create().apply {
            interval = 60000 // 1 minute
            fastestInterval = 5000
            priority = LocationRequest.PRIORITY_HIGH_ACCURACY
        }

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return
        }
        fusedLocationProviderClient.requestLocationUpdates(
                locationRequest,
                locationCallback,
                Looper.getMainLooper()
        )
    }

    private fun stopLocationUpdates() {
        fusedLocationProviderClient.removeLocationUpdates(locationCallback)
    }

    private val locationCallback = object : LocationCallback() {
        override fun onLocationResult(locationResult: LocationResult) { // Remove nullable
            val location = locationResult.lastLocation
            if (location != null) {
                val latitude = location.latitude
                val longitude = location.longitude
                sendLocationToServer(latitude, longitude) // Send location to server
            }
        }
    }

    private fun isNetworkAvailable(): Boolean {
        val connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val activeNetwork = connectivityManager.activeNetworkInfo
        return activeNetwork?.isConnectedOrConnecting == true
    }

    private fun sendLocationToServer(latitude: Double, longitude: Double) {
        if (isNetworkAvailable()) {
            // Send data to server
            // Also check if there is any saved data when offline and sync that
            syncOfflineData()
        } else {
            // Store location data in SQLite for offline use
            val timestamp = System.currentTimeMillis().toString()
            locationDatabaseHelper.insertLocation(latitude, longitude, timestamp)
        }
    }

    private fun syncOfflineData() {
        val offlineLocations = locationDatabaseHelper.getAllLocations()
        for (location in offlineLocations) {
            // Send each stored location to the server
            sendLocationToServer(location.latitude, location.longitude, location.timestamp)
        }
        // Once synced, delete offline data
        locationDatabaseHelper.deleteAllLocations()
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "location_channel"
            val channelName = "Location Tracking"
            val channel = NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_LOW)
            channel.description = "Channel for location tracking service"
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        val channelId = "location_channel"
        return NotificationCompat.Builder(this, channelId)
                .setContentTitle("Location Tracking")
                .setContentText("Tracking your location...")
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .setSmallIcon(R.mipmap.ic_launcher) // Ensure this icon is valid
                .build()
    }

    private fun sendLocationToServer(latitude: Double, longitude: Double, timestamp: String) {
        val urlString = "https://yourapiendpoint.com/location/update" // Replace with your server's endpoint

        AsyncTask.execute {
            var urlConnection: HttpURLConnection? = null

            try {
                val url = URL(urlString)
                urlConnection = url.openConnection() as HttpURLConnection
                urlConnection.requestMethod = "POST"
                urlConnection.setRequestProperty("Content-Type", "application/json")
                urlConnection.doOutput = true

                val jsonInputString = """
                {
                    "latitude": $latitude,
                    "longitude": $longitude,
                    "timestamp": "$timestamp"
                }
            """.trimIndent()

                OutputStreamWriter(urlConnection.outputStream).use { os ->
                    os.write(jsonInputString)
                    os.flush()
                }

                val responseCode = urlConnection.responseCode
                if (responseCode == HttpURLConnection.HTTP_OK) {
                    Log.d("MyLocationService", "$latitude - $longitude : $timestamp")
                } else {
                    Log.e("MyLocationService", "$latitude - $longitude : $timestamp")
                }
            } catch (e: Exception) {
                e.printStackTrace()
                Log.e("MyLocationService", e.printStackTrace().toString())
            } finally {
                urlConnection?.disconnect()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        stopForeground(true) // Remove notification
        stopSelf() // Stop the service
    }
}

class LocationDatabaseHelper(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {
    companion object {
        private const val DATABASE_NAME = "location.db"
        private const val DATABASE_VERSION = 1
        private const val TABLE_NAME = "location"
        private const val COLUMN_ID = "id"
        private const val COLUMN_LATITUDE = "latitude"
        private const val COLUMN_LONGITUDE = "longitude"
        private const val COLUMN_TIMESTAMP = "timestamp"
    }

    override fun onCreate(db: SQLiteDatabase) {
        val createTable = "CREATE TABLE $TABLE_NAME ($COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT, $COLUMN_LATITUDE REAL, $COLUMN_LONGITUDE REAL, $COLUMN_TIMESTAMP TEXT)"
        db.execSQL(createTable)
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        db.execSQL("DROP TABLE IF EXISTS $TABLE_NAME")
        onCreate(db)
    }

    fun insertLocation(latitude: Double, longitude: Double, timestamp: String) {
        val db = writableDatabase
        val values = ContentValues().apply {
            put(COLUMN_LATITUDE, latitude)
            put(COLUMN_LONGITUDE, longitude)
            put(COLUMN_TIMESTAMP, timestamp)
        }
        db.insert(TABLE_NAME, null, values)
    }

    @SuppressLint("Range")
    fun getAllLocations(): List<LocationData> {
        val locationList = mutableListOf<LocationData>()
        val db = readableDatabase
        val cursor = db.rawQuery("SELECT * FROM $TABLE_NAME", null)

        if (cursor.moveToFirst()) {
            do {
                val latitude = cursor.getDouble(cursor.getColumnIndex(COLUMN_LATITUDE))
                val longitude = cursor.getDouble(cursor.getColumnIndex(COLUMN_LONGITUDE))
                val timestamp = cursor.getString(cursor.getColumnIndex(COLUMN_TIMESTAMP))
                locationList.add(LocationData(latitude, longitude, timestamp))
            } while (cursor.moveToNext())
        }
        cursor.close()
        return locationList
    }

    fun deleteAllLocations() {
        val db = writableDatabase
        db.delete(TABLE_NAME, null, null)
    }
}

data class LocationData(val latitude: Double, val longitude: Double, val timestamp: String)
