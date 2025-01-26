import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:military_admin/views/map/sqlite.dart';
import 'package:military_admin/views/profile/usercontroller.dart';
import 'package:military_admin/views/splash_screen/splash.dart'; // Import SplashScreen
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final UserController userController = Get.put(UserController());
  await userController.loadUserFromPreferences();
  await DatabaseHelper().initHive(); // Initialize Hive
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
