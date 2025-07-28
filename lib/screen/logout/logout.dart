import 'package:dicabs/SharedPreference.dart';
import 'package:dicabs/core/show_log.dart';
import 'package:dicabs/screen/login/ui/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:go_router/go_router.dart';

class LogOutBox extends StatelessWidget {
  const LogOutBox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirm Logout"),
      content: const Text("Are you sure you want to log out?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // Close the dialog
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async => {
            await StorageManager.deleteData("userCode"),
            await StorageManager.deleteData("salesCode"),
            // await StorageManager.deleteData("isLoggedIn"),
            StorageManager.saveData('isLoggedIn', false),

            // Background Service stop on logout
            await stopLocationService(),

            context.go("/"),
            // context.go("splashPage"),

            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => const LoginPage()),
            // ),
          },
          child: const Text("Logout"),
        ),
      ],
    );
  }
}

Future<void> stopLocationService() async {
  final service = FlutterBackgroundService();
  service.invoke('stopService');
  logRed(msg: "Background Service stoped");
}
