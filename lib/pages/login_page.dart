import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import 'passcode_page.dart';
import 'passcode_setup_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController employeeIdController = TextEditingController();
  bool isLoading = false;
  ApiService apiService = ApiService();

  Future<void> login() async {
    if (employeeIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter your Employee ID")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var response = await apiService.checkEmployee(employeeIdController.text);

      if (response != null && response["success"] == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("isLoggedIn", true);
        prefs.setString("employee_id", employeeIdController.text);

        // ✅ ไปที่หน้า Setup Passcode ครั้งแรก
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PasscodeSetupPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["message"] ?? "Login failed! Please try again.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server error! Please try again later.")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Employee Login")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: employeeIdController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Employee ID",
              ),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: login,
                    child: Text("Login"),
                  ),
          ],
        ),
      ),
    );
  }
}