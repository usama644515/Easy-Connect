import 'package:easyconnect/home_screen.dart';
import 'package:easyconnect/theme.dart';
import 'package:easyconnect/welcome/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ------variable and conditon for login and onboarding screen------
int? isViewed;

void main() async {
  // -----firebase initialized------
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // -----firebase initialized------
  //--------this is for onboarding screen for first time show-------
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isViewed = await prefs.getInt("OnBoard");
  //-------conditon for direct home screen if user are login already------
  // if (FirebaseAuth.instance.currentUser != null) {
  //   _defaultPage = new Selection_Screen();
  // }
  runApp(
    GetMaterialApp(
      theme: lightTheme,
      themeMode: ThemeMode.system,
      darkTheme: darkTheme,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(isViewed: isViewed),
    ),
  );
}
