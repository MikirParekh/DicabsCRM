import 'package:dicabs/approute/routes.dart';
import 'package:dicabs/core/media.dart';
import 'package:dicabs/core/text.dart';
import 'package:dicabs/customewidget/global_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionPage extends StatelessWidget {
  const PermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Image.asset(DMedia.locationPermission),
                  const Gap(32),
                  Text(DText.permissionTextTitle,style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 24),textAlign: TextAlign.center,),
                  const Gap(32),
                  Text(DText.permissionText,style: Theme.of(context).textTheme.labelMedium,textAlign: TextAlign.center,),
                  const Gap(32),
                  Text(DText.permissionAlwaysAllowText,style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.redAccent),textAlign: TextAlign.center,),
                ],
              ),
              GlobalButton(text: DText.enableLocationText,onPressed: () async {
                _requestLocationPermission(context);
              },),
            ],
          ),
        ),
      ),
    );
  }

/*  Future<void> _requestLocationPermission(BuildContext context) async {
    while (true) {
      var status = await Permission.location.status;

      if (status.isGranted) {
        if (await Permission.locationAlways.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission is granted')),
          );
          break;
        } else {
          // Request "Always Allow" permission
          var result = await Permission.locationAlways.request();
          if (result.isGranted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission granted')),
            );
            // Navigate to the next screen or feature
            Navigator.of(context).pushReplacementNamed('/nextPage');
            break;
          } else if (result.isPermanentlyDenied) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Location permission is permanently denied. Please enable it in settings.'),
                action: SnackBarAction(
                  label: 'Settings',
                  onPressed: () {
                    openAppSettings();
                  },
                ),
              ),
            );
            // Optionally navigate to a screen explaining the need for permission
            Navigator.of(context).pushReplacementNamed('/permissionRequired');
            break; // Exit the loop
          }
        }
      } else if (status.isDenied) {
        // Request "When In Use" permission first
        var result = await Permission.location.request();
        if (result.isGranted) {
          // Request "Always Allow" permission
          var alwaysResult = await Permission.locationAlways.request();
          if (alwaysResult.isGranted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission granted')),
            );
            // Navigate to the next screen or feature
            Navigator.of(context).pushReplacementNamed('/nextPage');
            break;
          } else if (alwaysResult.isPermanentlyDenied) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Location permission is permanently denied. Please enable it in settings.'),
                action: SnackBarAction(
                  label: 'Settings',
                  onPressed: () {
                    openAppSettings();
                  },
                ),
              ),
            );
            break; // Exit the loop
          }
        }
      } else if (status.isRestricted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission is restricted')),
        );
        Navigator.of(context).pushReplacementNamed('/permissionRequired');
        break; // Exit the loop
      }
      else if (status.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location permission is permanently denied. Please enable it in settings.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () {
                openAppSettings();
              },
            ),
          ),
        );
        break; // Exit the loop
      }
    }
  }*/

  Future<void> _requestLocationPermission(BuildContext context) async {
    var status = await Permission.location.status;

    if (status.isGranted) {
      if (await Permission.locationAlways.isGranted) {
        context.go(AppRoutes.dashboard);
      } else {
        openAppSettings();
      }
    } else {
      var result = await Permission.location.request();
      if(result.isGranted){
        var always = await Permission.locationAlways.request();
        if(always.isGranted){
          context.go(AppRoutes.dashboard);
        }else{
          openAppSettings();
        }
      }else{
        openAppSettings();
      }
    }
  }

/*  Future<void> _requestLocationPermission(BuildContext context) async {
    var status = await Permission.locationWhenInUse.status;
    if(!status.isGranted){
      var status = await Permission.locationWhenInUse.request();
      if(status.isGranted){
        var status = await Permission.locationAlways.request();
        if(status.isGranted){
          //Do some stuff
        }else{
          //Do another stuff
        }
      }else{
        //The user deny the permission
      }
      if(status.isPermanentlyDenied){
        //When the user previously rejected the permission and select never ask again
        //Open the screen of settings
        bool res = await openAppSettings();
      }
    }else{
      //In use is available, check the always in use
      var status = await Permission.locationAlways.status;
      if(!status.isGranted){
        var status = await Permission.locationAlways.request();
        if(status.isGranted){
          //Do some stuff
        }else{
          //Do another stuff
        }
      }else{
        //previously available, do some stuff or nothing
      }
    }
  }*/




}
