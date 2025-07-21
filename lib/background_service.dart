import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:dicabs/core/show_log.dart';
import 'package:dicabs/screen/mainpage/repo/main_page_repo.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  final iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    onDidReceiveLocalNotification: (id, title, body, payload) async {
      // Optional: Handle iOS foreground notifications
    },
  );
  final initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Step 2: CREATE the notification channel BEFORE using it
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(
          'location_tracking', // MUST match the channel ID used below
          'Location Tracking',
          description: 'Used for location tracking in foreground',
          importance: Importance.high,
        ),
      );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: false,
      );

  // Step 3: Configure the background service
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      notificationChannelId: 'location_tracking', // Same as above
      initialNotificationTitle: 'Location Service',
      initialNotificationContent: 'Tracking location in background',
      foregroundServiceNotificationId: 888,
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: (_) {},
      onBackground: (service) async => true,
    ),
  );

  // Step 4: Start service
  await service.startService();

  if (Platform.isIOS) {
    showLog(msg: 'platform  iOS ----->> ${Platform.isIOS}');
    startiOSLocationTracking();
  }
}

Future<void> requestLocationPermissions() async {
  // Check and request location permission
  LocationPermission permission = await Geolocator.checkPermission();

  showLog(msg: "Permission -----> $permission");

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.deniedForever) {
    permission = await Geolocator.requestPermission();
    Fluttertoast.showToast(msg: "Please enable location in settings");
    return;
  }

  // Check if GPS is enabled
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    permission = await Geolocator.requestPermission();
    Fluttertoast.showToast(msg: "GPS Disabled");
  }

  showLog(msg: "serviceEnabled ---> $serviceEnabled");
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

  Timer.periodic(const Duration(seconds: 5), (timer) async {
    try {
      // 1️⃣ Read user code
      String? userCode = await StorageManager.readData('userCode');
      showLog(msg: 'User Code in on start android: $userCode');

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      late final Position position;

      if (serviceEnabled) {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );
      } else {
        await Geolocator.requestPermission();
      }

      // 2️⃣ Get location
      // final position = await Geolocator.getCurrentPosition(
      //   desiredAccuracy: LocationAccuracy.best,
      // );

      showLog(msg: "Position ----> latitude --> ${position.latitude}");
      showLog(msg: "Position ----> longitude --> ${position.longitude}");

      globalLatitude = position.latitude.toStringAsFixed(5);
      globalLongitude = position.longitude.toStringAsFixed(5);

      // ✅ 3️⃣ Get and store date & time
      final now = DateTime.now().toLocal();
      globalDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      globalTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

      if (userCode != null) {
        final result = await MainPageRepository.postLocation(
          userCode: userCode,
          latitude: globalLatitude ?? '',
          longitude: globalLongitude ?? '',
        );

        showLog(msg: "android result ---> $result");

        if (result != null && result.completed) {
          showLog(msg: '✅ Sent: ${result.message}');
        } else {
          showLog(msg: '❌ Failed to send location');
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
              channelDescription:
                  'Used for live location updates in foreground',
              importance: Importance.high,
              priority: Priority.high,
              ongoing: true,
              styleInformation: BigTextStyleInformation(''),
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            )),
      );
    } catch (e) {
      debugPrint('Error in background task:-----> $e');
    }
  });
}

@pragma('vm:entry-point')
void startiOSLocationTracking() {
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final now = DateTime.now().toLocal();
      final userCode = await StorageManager.readData('userCode');
      final latitude = position.latitude.toStringAsFixed(5);
      final longitude = position.longitude.toStringAsFixed(5);
      final date =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final time =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

      if (userCode != null) {
        await MainPageRepository.postLocation(
          userCode: userCode,
          latitude: latitude,
          longitude: longitude,
        );
      }

      await flutterLocalNotificationsPlugin.show(
        888,
        '📍 iOS Location Update',
        '🗓️ $date 🕒 $time\n👤 Code: ${userCode ?? "N/A"}\n🌐 Lat: $latitude | Long: $longitude',
        const NotificationDetails(
          iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              presentList: true,
              presentBanner: true),
        ),
      );
    } catch (e) {
      showLog(msg: "startiOSLocationTracking error -------> $e");
    }
  });
}
