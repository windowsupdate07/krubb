import 'package:flutter/material.dart';

/// ฟังก์ชันสำหรับคืนค่าไอคอนที่เหมาะสมตามประเภทของแจ้งเตือน
IconData getIconForType(String type) {
  switch (type) {
    case "มอบหมายงาน":
      return Icons.assignment; // 📋 มอบหมายงาน
    case "ประชุม":
      return Icons.event; // 📅 การประชุม
    case "ทั่วไป":
      return Icons.campaign; // 📣 แจ้งเตือนทั่วไป
    case "เร่งด่วน":
      return Icons.warning_amber; // ⚠️ แจ้งเตือนเร่งด่วน
    case "สำคัญ":
      return Icons.star; // ⭐ แจ้งเตือนสำคัญ
    case "อบรม":
      return Icons.school; // 🎓 การอบรม
    case "อุบัติเหตุ": 
      return Icons.report_problem; // 🚨 อุบัติเหตุ (ใช้ไอคอนแจ้งเตือน)
    default:
      return Icons.info_outline; // ℹ️ แจ้งเตือนอื่นๆ
  }
}