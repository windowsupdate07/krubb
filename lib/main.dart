import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login_page.dart';
import 'pages/passcode_page.dart';
import 'pages/announcement_page.dart';
import 'pages/passcode_setup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
  bool hasPasscode = prefs.getString("passcode") != null;

  runApp(MyApp(isLoggedIn: isLoggedIn, hasPasscode: hasPasscode));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool hasPasscode;

  MyApp({required this.isLoggedIn, required this.hasPasscode});

  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: isLoggedIn
          ? (hasPasscode ? PasscodePage() : PasscodeSetupPage()) // ✅ เช็คว่าเคยตั้ง Passcode ไหม
          : LoginPage(),
    );
  }
}