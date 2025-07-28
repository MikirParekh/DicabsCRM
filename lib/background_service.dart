import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:dicabs/core/show_log.dart';
import 'package:dicabs/screen/mainpage/repo/main_page_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'SharedPreference.dart';
import 'global_location.dart';

// Notification Plugin
final FlutterLocalNotificationsPlugin _notifications =
    FlutterLocalNotificationsPlugin();

//MARK: Initialize Service
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await _initNotificationPlugin();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      notificationChannelId: 'location_tracking',
      initialNotificationTitle: 'Location Service',
      initialNotificationContent: 'Tracking location in background',
      foregroundServiceNotificationId: 888,
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: (_) {},
      onBackground: (_) async => true,
    ),
  );

  await service.startService();

  if (Platform.isIOS) {
    showLog(msg: 'Running on iOS');
    _startiOSLocationTracking();
  }

  logGreen(msg: "Background Service started");
}

Future<void> _initNotificationPlugin() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  await _notifications.initialize(const InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  ));

  await _notifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
        'location_tracking',
        'Location Tracking',
        description: 'Used for location tracking in foreground',
        importance: Importance.low,
        playSound: false,
      ));

  await _notifications
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true, sound: false);
}

//MARK: Request Location Permission
// Future<void> requestLocationPermissions() async {
//   LocationPermission permission = await Geolocator.checkPermission();
//   showLog(msg: "Permission: $permission");

//   if (permission == LocationPermission.denied ||
//       permission == LocationPermission.deniedForever) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.deniedForever) {
//       Fluttertoast.showToast(msg: "Please enable location in settings");
//       return;
//     }
//   }

//   final serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     // Fluttertoast.showToast(msg: "GPS Disabled");
//     Fluttertoast.showToast(
//       msg: "Please enable location & GPS from settings.",
//       toastLength: Toast.LENGTH_LONG,
//     );
//   }

//   showLog(msg: "GPS Service Enabled: $serviceEnabled");
// }

//MARK: Android Service Entry
@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();

    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }

  Timer.periodic(
      const Duration(minutes: 10), (_) async => await _trackLocationAndSend());
}

//MARK: iOS Tracking
@pragma('vm:entry-point')
void _startiOSLocationTracking() {
  Timer.periodic(
      const Duration(minutes: 10), (_) async => await _trackLocationAndSend());
}

Future<void> stopLocationService() async {
  final service = FlutterBackgroundService();
  service.invoke('stopService');
}

//MARK: Location + API Logic
Future<void> _trackLocationAndSend() async {
  try {
    final userCode = await StorageManager.readData('userCode');
    if (userCode == null) return;

    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.requestPermission();
      return;
    }

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    globalLatitude = position.latitude.toStringAsFixed(5);
    globalLongitude = position.longitude.toStringAsFixed(5);

    final now = DateTime.now().toLocal();
    globalDate = "${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}";
    globalTime =
        "${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}";

    final result = await MainPageRepository.postLocation(
      userCode: userCode,
      latitude: globalLatitude ?? '',
      longitude: globalLongitude ?? '',
    );

    showLog(
        msg: result?.completed == true
            ? "✅ Sent: ${result!.message}"
            : "❌ Failed to send location");

    await _showLocationNotification();
  } catch (e) {
    debugPrint('Error in location tracking: $e');
  }
}

//MARK: Show Notification
Future<void> _showLocationNotification() async {
  await _notifications.show(
    888,
    "Dicabs Location tracking is on",
    "",
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'location_tracking',
        'Location Tracking',
        channelDescription: 'Used for live location updates in foreground',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        playSound: false,
        styleInformation: BigTextStyleInformation(''),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: false,
        presentList: true,
        presentBanner: true,
      ),
    ),
  );
}

//MARK: Helpers
String _twoDigits(int n) => n.toString().padLeft(2, '0');
