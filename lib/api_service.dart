import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://110.164.146.94/krub_api"; // URL หลักของ API

  /// **1️⃣ ตรวจสอบพนักงานจาก employee_id**
  Future<dynamic> checkEmployee(String employeeId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/get_users.php'),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"employee_id": employeeId},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // แปลง JSON เป็น Dart Object
      } else {
        return {"success": false, "message": "Invalid response"};
      }
    } catch (e) {
      return {"success": false, "message": "Failed to connect to server"};
    }
  }

  // /// **2️⃣ Create Announcement - สร้างประกาศใหม่**
  // Future<dynamic> createAnnouncement(Map<String, dynamic> announcementData) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/create_announcement.php'),
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode(announcementData),
  //     );

  //     return jsonDecode(response.body);
  //   } catch (e) {
  //     return {"error": "Failed to create announcement"};
  //   }
  // }

  /// **3️⃣ Get Announcements - ดึงรายการประกาศทั้งหมด**
  Future<dynamic> getAnnouncements() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_announcements.php'));

      return jsonDecode(response.body);
    } catch (e) {
      return {"error": "Failed to fetch announcements"};
    }
  }

  /// **4️⃣ Get User By ID - ดึงข้อมูลผู้ใช้จาก ID**
  Future<dynamic> getUserById(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_user_by_id.php?user_id=$userId'),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"error": "Failed to fetch user"};
    }
  }

  /// **5️⃣ Get All Users - ดึงข้อมูลผู้ใช้ทั้งหมด**
  Future<dynamic> getUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_users.php'));

      return jsonDecode(response.body);
    } catch (e) {
      return {"error": "Failed to fetch users"};
    }
  }

  /// **6️⃣ Search Users - ค้นหาผู้ใช้จากคำค้นหา**
  Future<dynamic> searchUsers(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search_users.php?query=$query'),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"error": "Failed to search users"};
    }
  }

  /// ✅ **ดึงข้อมูลแผนก, กอง, แผนกย่อยจากฐานข้อมูล**
  Future<dynamic> getDepartmentsDivisionsSections() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_departments_divisions_sections.php'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "ไม่สามารถดึงข้อมูลแผนก/กอง/แผนกย่อย"};
      }
    } catch (e) {
      return {"success": false, "message": "เชื่อมต่อเซิร์ฟเวอร์ไม่ได้"};
    }
  }

  /// ✅ **ดึงรายชื่อพนักงานทั้งหมด**
  Future<dynamic> getUsers2() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_users2.php'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "ไม่สามารถดึงข้อมูลพนักงาน"};
      }
    } catch (e) {
      return {"success": false, "message": "เชื่อมต่อเซิร์ฟเวอร์ไม่ได้"};
    }
  }

  /// ✅ **บันทึกประกาศใหม่**
  Future<dynamic> createAnnouncement(Map<String, dynamic> announcementData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create_announcement.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(announcementData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "ไม่สามารถสร้างประกาศได้"};
      }
    } catch (e) {
      return {"success": false, "message": "เชื่อมต่อเซิร์ฟเวอร์ไม่ได้"};
    }
  }

  Future<dynamic> acceptAssignment(Map<String, dynamic> requestData) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/accept_assignment.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestData),
    );

    return jsonDecode(response.body);
  } catch (e) {
    return {"error": "เชื่อมต่อเซิร์ฟเวอร์ไม่ได้"};
  }
}

Future<dynamic> getUserNotifications(String employeeId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/get_user_notifications.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"employee_id": employeeId}), // ✅ ใช้ employee_id
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          return data;
        } else {
          return {"error": data["error"] ?? "เกิดข้อผิดพลาด"};
        }
      } else {
        return {"error": "เซิร์ฟเวอร์ตอบกลับด้วยรหัสผิดพลาด ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": "❌ ไม่สามารถเชื่อมต่อกับ API: $e"};
    }
  }
/// ✅ **ฟังก์ชันรับทราบงาน**
  Future<dynamic> acknowledgeAnnouncement(String announcementId, String employeeId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/acknowledge_announcement.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"announcement_id": announcementId, "employee_id": employeeId}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"error": "Failed to acknowledge announcement"};
    }
  }

  /// ✅ ฟังก์ชันดึงข้อมูลพนักงานที่กดรับทราบ และยังไม่กด
  Future<dynamic> getAcknowledgementStatus(String announcementId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/get_acknowledgement_status.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"announcement_id": announcementId}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "error": "Failed to fetch acknowledgement status"};
    }
  }
  Future<dynamic> getAllAssignments() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/getAllAssignments.php'));

    return jsonDecode(response.body);
  } catch (e) {
    return {"success": false, "error": "Failed to fetch assignments"};
  }
}

Future<Map<String, dynamic>> checkAcknowledgementStatus(
    String announcementId, String userId) async {
  final response = await http.post(
    Uri.parse('$baseUrl/checkAcknowledgementStatus.php'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"announcement_id": announcementId, "user_id": userId}),
  );

  return jsonDecode(response.body);
}


}