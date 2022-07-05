import 'dart:async';

import 'package:easyconnect/app_color.dart';
import 'package:easyconnect/home/chat_page.dart';
import 'package:easyconnect/home_screen.dart';
import 'package:easyconnect/welcome/login_page.dart';
import 'package:easyconnect/welcome/onboarding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final isViewed;
  const SplashScreen({Key? key, this.isViewed}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Widget _defaultPage = const ChatPage();
  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    Timer(const Duration(seconds: 4), () {
      NextScreen();
    });
    if (_auth.currentUser == null) {
      _defaultPage = const LoginScreen();
    } else {
      _defaultPage = const ChatPage();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ImageIcon(
              AssetImage("assets/images/home.png"),
              color: Colors.white,
              size: 60.0,
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Easy',
                  style: TextStyle(
                    fontSize: 30.0,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Connect',
                  style: TextStyle(
                    fontSize: 30.0,
                    color: Colors.white30,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  void NextScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        // ------conditon for login screen and onboarding screen-----
        builder: (context) {
          return widget.isViewed != 0 ? Onbording() : _defaultPage;
        },
      ),
    );
  }
}
