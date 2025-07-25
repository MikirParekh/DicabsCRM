import 'dart:async';

import 'package:dicabs/SharedPreference.dart';
import 'package:dicabs/approute/routes.dart';
import 'package:dicabs/core/media.dart';
import 'package:dicabs/service/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Future<void> initState() async {
    super.initState();
    await StorageManager.readData("isLoggedIn");
    navigateToNextScreen();
  }

  // Future navigateToNextScreen() async {
  //   var isUserLoggedIn = await _storageService.readData(DText.userId);
  //   if (isUserLoggedIn != null && isUserLoggedIn.isNotEmpty) {
  //     if (!mounted) return;
  //     _requestLocationPermission(context);
  //   } else {
  //     Timer(const Duration(seconds: 2), () {
  //       context.go(AppRoutes.loginPage);
  //     });
  //   }
  // }

  Future navigateToNextScreen() async {
    bool isUserLoggedIn = await StorageManager.readData("isLoggedIn") ?? false;
    if (isUserLoggedIn == true) {
      if (!mounted) return;
      // _requestLocationPermission(context);
      context.go(AppRoutes.dashboard);
    } else {
      Timer(const Duration(seconds: 2), () {
        context.go(AppRoutes.loginPage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(DMedia.logo),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _requestLocationPermission(BuildContext context) async {
  var status = await Permission.location.status;

  if (status.isGranted) {
    if (await Permission.locationAlways.isGranted) {
      context.go(AppRoutes.dashboard);
    } else {
      context.go(AppRoutes.permissionPage);
    }
  } else {
    context.go(AppRoutes.permissionPage);
  }
}
