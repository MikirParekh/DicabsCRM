//LOCAL

import 'dart:ui';
import 'dart:io' show Platform;
import 'package:dicabs/core/show_log.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dicabs/customewidget/global_button.dart';
import 'package:dicabs/customewidget/global_text_field.dart';
import 'package:dicabs/screen/login/controller/login_controller.dart';
import 'package:dicabs/validator/validator.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final controller = Get.put(LoginController());
  bool showError = false;

  @override
  void initState() {
    super.initState();
    controller.userCodeController.clear();
    controller.passwordController.clear();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller.userCodeController.clear();
    controller.passwordController.clear();
  }

  Future<bool> _checkAndRequestPermissions() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Please enable location services');
      return false;
    }

    // Request location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permission denied');
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg:
              'Location permission permanently denied. Please enable in settings.');
      await openAppSettings();
      return false;
    }

    // Request background location permission (Android)
    if (Platform.isAndroid) {
      final backgroundStatus = await Permission.locationAlways.request();
      if (backgroundStatus.isDenied || backgroundStatus.isPermanentlyDenied) {
        Fluttertoast.showToast(
            msg:
                'Background location permission required. Please enable in settings.');
        await openAppSettings();
        return false;
      }
    }

    return true;
  }

  Future<void> _requestBatteryOptimizationExemption() async {
    if (Platform.isAndroid) {
      const channel = MethodChannel('com.uniqtech.dicabs/battery_optimization');
      final isBatteryOptimized =
          await channel.invokeMethod<bool>('isBatteryOptimized');

      showLog(msg: "isBatteryOptimized ----> $isBatteryOptimized");

      if (isBatteryOptimized == true) {
        try {
          const intent = AndroidIntent(
            action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
          );
          await intent.launch();
        } catch (e) {
          Fluttertoast.showToast(msg: 'Failed to open battery settings: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/image/logo.jpeg"),
                      const Gap(40),
                      GlobalTextFormField(
                        prefixIcon: const Icon(Iconsax.direct_right),
                        labelText: 'UserCode',
                        controller: controller.userCodeController,
                        keyboardType: TextInputType.emailAddress,
                        validator: validateUserCode,
                        onChanged: (value) {
                          controller.validateForm();
                        },
                      ),
                      Obx(
                        () => GlobalTextFormField(
                          prefixIcon: const Icon(Iconsax.password_check),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordVisible.value
                                  ? Iconsax.eye_slash
                                  : Iconsax.eye,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                          labelText: 'Password',
                          controller: controller.passwordController,
                          obscureText: !controller.isPasswordVisible.value,
                          validator: validatePassword,
                        ),
                      ),
                      const Gap(20),
                      if (showError)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.redAccent),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: Colors.redAccent),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Invalid credentials. Please try again.",
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Gap(20),
                    ],
                  ),
                ),
                GlobalButton(
                    fontSize: 18,
                    text: "Login",
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final success = await controller.loginUser();

                        if (success) {
                          setState(() => showError = false);

                          // Check and request permissions
                          final permissionsGranted =
                              await _checkAndRequestPermissions();
                          if (!permissionsGranted) return;

                          // ✅ Request notification permission (REQUIRED for foreground service)
                          if (Platform.isAndroid) {
                            await Permission.notification.request();
                          }

                          // Start background service
                          try {
                            // await initializeService();
                            Fluttertoast.showToast(
                                msg: 'Location tracking started');
                          } catch (e) {
                            Fluttertoast.showToast(
                                msg: 'Failed to start location tracking: $e');
                            return;
                          }

                          // Request battery optimization exemption
                          await _requestBatteryOptimizationExemption();

                          // ✅ Navigate to dashboard
                          context.goNamed(
                            'dashboard',
                            extra: {
                              'userCode': controller.userCodeController.text,
                              'salesCode': controller
                                  .passwordController.text, // Adjust if needed
                            },
                          );
                        } else {
                          setState(() => showError = true);
                          Future.delayed(const Duration(seconds: 2), () {
                            if (mounted) setState(() => showError = false);
                          });
                        }
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}





//LIVE

// import 'dart:ui';
// import 'dart:io' show Platform;
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:go_router/go_router.dart';
// import 'package:gap/gap.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:geolocator/geolocator.dart';
//
// import 'package:dicabs/customewidget/global_button.dart';
// import 'package:dicabs/customewidget/global_text_field.dart';
// import 'package:dicabs/screen/login/controller/login_controller.dart';
// import 'package:dicabs/validator/validator.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   final _formKey = GlobalKey<FormState>();
//   final controller = Get.put(LoginController());
//   bool showError = false;
//
//   @override
//   void initState() {
//     super.initState();
//     controller.userCodeController.clear();
//     controller.passwordController.clear();
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     controller.userCodeController.clear();
//     controller.passwordController.clear();
//   }
//
//   Future<bool> _checkAndRequestPermissions() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       Fluttertoast.showToast(msg: 'Please enable location services');
//       return false;
//     }
//
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         Fluttertoast.showToast(msg: 'Location permission denied');
//         return false;
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       Fluttertoast.showToast(
//           msg: 'Location permission permanently denied. Please enable in settings.');
//       await openAppSettings();
//       return false;
//     }
//
//     return true;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SafeArea(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 Expanded(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Image.asset("assets/image/logo.jpeg"),
//                       const Gap(40),
//                       GlobalTextFormField(
//                         prefixIcon: const Icon(Iconsax.direct_right),
//                         labelText: 'UserCode',
//                         controller: controller.userCodeController,
//                         keyboardType: TextInputType.emailAddress,
//                         validator: validateUserCode,
//                         onChanged: (value) => controller.validateForm(),
//                       ),
//                       Obx(
//                             () => GlobalTextFormField(
//                           prefixIcon: const Icon(Iconsax.password_check),
//                           suffixIcon: IconButton(
//                             icon: Icon(
//                               controller.isPasswordVisible.value
//                                   ? Iconsax.eye_slash
//                                   : Iconsax.eye,
//                             ),
//                             onPressed: controller.togglePasswordVisibility,
//                           ),
//                           labelText: 'Password',
//                           controller: controller.passwordController,
//                           obscureText: !controller.isPasswordVisible.value,
//                           validator: validatePassword,
//                         ),
//                       ),
//                       const Gap(20),
//                       if (showError)
//                         Container(
//                           margin: const EdgeInsets.symmetric(horizontal: 8.0),
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.red.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: Colors.redAccent),
//                           ),
//                           child: const Row(
//                             children: [
//                               Icon(Icons.error_outline, color: Colors.redAccent),
//                               SizedBox(width: 10),
//                               Expanded(
//                                 child: Text(
//                                   "Invalid credentials. Please try again.",
//                                   style: TextStyle(
//                                     color: Colors.redAccent,
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       const Gap(20),
//                     ],
//                   ),
//                 ),
//                 GlobalButton(
//                   fontSize: 18,
//                   text: "Login",
//                     onPressed: () async {
//                       if (_formKey.currentState!.validate()) {
//                         final success = await controller.loginUser();
//
//                         if (success) {
//                           setState(() => showError = false);
//
//                           final granted = await _checkAndRequestPermissions();
//                           if (!granted) return;
//
//                           // Show toast only on first successful permission grant
//                           final prefs = await SharedPreferences.getInstance();
//                           final hasShownLocationToast = prefs.getBool('hasShownLocationPermission') ?? false;
//
//                           if (!hasShownLocationToast) {
//                             Fluttertoast.showToast(msg: 'Location permission granted');
//                             await prefs.setBool('hasShownLocationPermission', true);
//                           }
//
//                           context.goNamed(
//                             'dashboard',
//                             extra: {
//                               'userCode': controller.userCodeController.text,
//                               'salesCode': controller.passwordController.text,
//                             },
//                           );
//                         } else {
//                           setState(() => showError = true);
//                           Future.delayed(const Duration(seconds: 2), () {
//                             if (mounted) setState(() => showError = false);
//                           });
//                         }
//                       }
//                     }
//
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

