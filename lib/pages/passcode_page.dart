import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'announcement_page.dart';
import 'passcode_setup_page.dart';

class PasscodePage extends StatefulWidget {
  @override
  _PasscodePageState createState() => _PasscodePageState();
}

class _PasscodePageState extends State<PasscodePage> {
  List<String> passcode = [];
  String? savedPasscode;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPasscode();
  }

  /// ✅ โหลด Passcode ที่บันทึกไว้
  Future<void> loadPasscode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    savedPasscode = prefs.getString("passcode");
    setState(() {
      isLoading = false;
    });
  }

  /// ✅ ตรวจสอบรหัสผ่าน
  void verifyPasscode() {
    if (passcode.join() == savedPasscode) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AnnouncementsPage()),
      );
    } else {
      setState(() {
        passcode.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("รหัสผ่านไม่ถูกต้อง!")),
      );
    }
  }

  /// ✅ เพิ่มตัวเลขใน Passcode
  void addNumber(String number) {
    if (passcode.length < 6) {
      setState(() {
        passcode.add(number);
      });
      if (passcode.length == 6) {
        Future.delayed(Duration(milliseconds: 200), verifyPasscode);
      }
    }
  }

  /// ✅ ลบตัวเลขสุดท้าย
  void deleteNumber() {
    if (passcode.isNotEmpty) {
      setState(() {
        passcode.removeLast();
      });
    }
  }

  /// ✅ รีเซ็ต Passcode
  Future<void> resetPasscode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("passcode");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PasscodeSetupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "กรุณากรอกรหัสผ่าน",
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
                SizedBox(height: 20),

                /// 🔵 แสดงจุดแทนตัวเลขที่ป้อน
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    6,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: index < passcode.length ? Colors.white : Colors.white30,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),

                /// 🔢 แป้นพิมพ์ตัวเลข (PIN Pad)
                buildNumberPad(),

                SizedBox(height: 20),

                /// ❌ ปุ่มล้าง / 🔄 รีเซ็ตรหัสผ่าน
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: deleteNumber,
                      child: Text("❌ ลบ", style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                    TextButton(
                      onPressed: resetPasscode,
                      child: Text("🔄 ลืมรหัสผ่าน?", style: TextStyle(color: Colors.redAccent, fontSize: 18)),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  /// 🔢 สร้างแป้นพิมพ์ตัวเลข (PIN Pad)
  Widget buildNumberPad() {
    return Column(
      children: [
        for (var row in [
          ["1", "2", "3"],
          ["4", "5", "6"],
          ["7", "8", "9"],
          ["", "0", "⌫"]
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((num) {
              return num.isEmpty
                  ? SizedBox(width: 70, height: 70)
                  : GestureDetector(
                      onTap: () => num == "⌫" ? deleteNumber() : addNumber(num),
                      child: Container(
                        margin: EdgeInsets.all(10),
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: num == "⌫" ? Colors.redAccent : Colors.blueGrey.shade700,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            num,
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
            }).toList(),
          ),
      ],
    );
  }
}