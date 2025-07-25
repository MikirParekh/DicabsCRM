import 'package:dicabs/SharedPreference.dart';
import 'package:dicabs/screen/login/ui/login_page.dart';
import 'package:flutter/material.dart';

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
            StorageManager.saveData('isLoggedIn', false),
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            ),
          },
          child: const Text("Logout"),
        ),
      ],
    );
  }
}
