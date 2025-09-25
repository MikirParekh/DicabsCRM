import 'dart:io';
import 'package:dicabs/core/theme.dart';
import 'package:dicabs/service/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'approute/app_go_route.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow legacy TLS if needed
  final context = SecurityContext.defaultContext;
  context.allowLegacyUnsafeRenegotiation = true;

  // Initialize secure storage
  await SecureStorageService().init();

  // Lock orientation and launch app
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Obtain a list of the available cameras on the device.
  // final cameras = await availableCameras();

  // await requestLocationPermissions(); // now asking after login
  // await initializeService();

  // if (Platform.isIOS) {
  //   showLog(msg: 'platform  iOS ----->> ${Platform.isIOS}');
  //   startiOSLocationTracking();
  // }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'DICABS CRM',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      darkTheme: DTheme.darkTheme,
      theme: DTheme.lightTheme,
    );
  }
}
