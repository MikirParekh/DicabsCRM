import 'dart:async';
import 'dart:ui';
import 'package:dicabs/screen/mainpage/repo/main_page_repo.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'SharedPreference.dart';
import 'global_location.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // Step 1: Initialize Notification Plugin
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Step 2: CREATE the notification channel BEFORE using it
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
    const AndroidNotificationChannel(
      'location_tracking', // MUST match the channel ID used below
      'Location Tracking',
      description: 'Used for location tracking in foreground',
      importance: Importance.low,
    ),
  );

  // Step 3: Configure the background service
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      notificationChannelId: 'location_tracking', // Same as above
      initialNotificationTitle: 'Location Service',
      initialNotificationContent: 'Tracking location in background...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: (_) {},
      onBackground: (service) async => true,
    ),
  );

  // Step 4: Start service
  await service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();

    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }

  Timer.periodic(const Duration(seconds: 15), (timer) async {
    try {
      // 1️⃣ Read user code
      String? userCode = await StorageManager.readData('userCode');
      print('User Code: $userCode');

      // 2️⃣ Get location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      globalLatitude = position.latitude.toStringAsFixed(5);
      globalLongitude = position.longitude.toStringAsFixed(5);

      // ✅ 3️⃣ Get and store date & time
      final now = DateTime.now().toLocal();
      globalDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      globalTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

      if (userCode != null) {
        final result = await MainPageRepository.postLocation(
          userCode: userCode,
          latitude: globalLatitude ?? '',
          longitude: globalLongitude ?? '',
        );

        if (result != null && result.completed) {
          print('✅ Sent: ${result.message}');
        } else {
          print('❌ Failed to send location');
        }
      }
      // 4️⃣ Show notification
      await flutterLocalNotificationsPlugin.show(
        888,
        '📍 Location Update',
        '🗓️ $globalDate 🕒 $globalTime\n👤 Code: ${userCode ?? "N/A"}\n🌐 Lat: $globalLatitude | Long: $globalLongitude',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'location_tracking',
            'Location Tracking',
            channelDescription: 'Used for live location updates in foreground',
            importance: Importance.high,
            priority: Priority.high,
            ongoing: true,
            styleInformation: BigTextStyleInformation(''),
          ),
        ),
      );
    } catch (e) {
      print('Error in background task: $e');
    }
  });

}


// import 'dart:async';
// import 'dart:ui';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
// import 'package:geolocator/geolocator.dart';
// import 'global_location.dart';
//
// Future<void> initializeService() async {
//   final service = FlutterBackgroundService();
//
//   // Step 1: Configure the background service WITHOUT notification
//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       isForegroundMode: false, // <--- ❌ No foreground service
//       autoStart: true,
//     ),
//     iosConfiguration: IosConfiguration(
//       autoStart: true,
//       onForeground: (_) {},
//       onBackground: (_) async => true,
//     ),
//   );
//
//   // Step 2: Start the service
//   await service.startService();
// }
//
// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) {
//   DartPluginRegistrant.ensureInitialized();
//   print("✅ Background service started");
//
//   service.on('stopService').listen((event) {
//     print("🛑 Service stopped");
//     service.stopSelf();
//   });
//
//   Timer.periodic(const Duration(minutes: 2), (timer) async {
//     try {
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//
//       globalLatitude = position.latitude.toStringAsFixed(5);
//       globalLongitude = position.longitude.toStringAsFixed(5);
//
//       print("📍 Updated location: $globalLatitude, $globalLongitude");
//     } catch (e) {
//       print("❌ Location error: $e");
//     }
//   });
// }

