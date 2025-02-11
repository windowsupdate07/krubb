import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'announcement_page.dart';

class PasscodeSetupPage extends StatefulWidget {
  @override
  _PasscodeSetupPageState createState() => _PasscodeSetupPageState();
}

class _PasscodeSetupPageState extends State<PasscodeSetupPage> {
  TextEditingController passcodeController = TextEditingController();
  TextEditingController confirmPasscodeController = TextEditingController();

  Future<void> savePasscode() async {
    if (passcodeController.text.isEmpty || confirmPasscodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("โปรดกรอกรหัสผ่าน")),
      );
      return;
    }

    if (passcodeController.text != confirmPasscodeController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("รหัสผ่านไม่ตรงกัน!")),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("passcode", passcodeController.text);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AnnouncementsPage()), // ✅ ไปที่ AnnouncementsPage()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ตั้งค่ารหัสผ่าน")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: passcodeController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "สร้างรหัสผ่าน",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: confirmPasscodeController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "ยืนยันรหัสผ่าน",
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: savePasscode,
              child: Text("บันทึกรหัสผ่าน"),
            ),
          ],
        ),
      ),
    );
  }
}