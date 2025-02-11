import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../api_service.dart';
import '../widgets/date_picker_widget.dart';

class CreateAnnouncementPage extends StatefulWidget {
  @override
  _CreateAnnouncementPageState createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends State<CreateAnnouncementPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<dynamic> users = [];
  Set<String> departments = {};
  Set<String> divisions = {};
  Set<String> sections = {};
  List<String> selectedUserIds = [];
  List<String> selectedDepartments = [];
  List<String> selectedDivisions = [];
  List<String> selectedSections = [];

  String _selectedType = "ทั่วไป";
  DateTime? _selectedNotifyDate;
  DateTime? _selectedDeadline;
  String? _currentUserId;
  bool _isLoading = false;
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _getCurrentUserId();
  }

  Future<void> _getCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('employee_id');
    });
  }

  Future<void> _fetchData() async {
    try {
      ApiService apiService = ApiService();
      var departmentData = await apiService.getDepartmentsDivisionsSections();
      var userData = await apiService.getUsers2();

      setState(() {
        if (departmentData["success"] == true) {
          departments = Set<String>.from(departmentData["departments"]);
          divisions = Set<String>.from(departmentData["divisions"]);
          sections = Set<String>.from(departmentData["sections"]);
        }
        if (userData["success"] == true) {
          users = userData["users"];
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('โหลดข้อมูลล้มเหลว')),
      );
    }
  }

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitAnnouncement() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        (_selectedNotifyDate == null) ||
        _currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
      return;
    }

    setState(() => _isLoading = true);

    Map<String, dynamic> postData = {
      "title": _titleController.text,
      "description": _descriptionController.text,
      "type": _selectedType,
      "notify_date": _selectedNotifyDate?.toIso8601String(),
      "deadline": _selectedDeadline?.toIso8601String(),
      "created_by": _currentUserId,
      "recipients": selectedUserIds,
      "departments": selectedDepartments,
      "divisions": selectedDivisions,
      "sections": selectedSections,
      "file": _selectedFile ,
    };

    print("📤 ส่งข้อมูลไปที่ API: $postData");

    ApiService apiService = ApiService();
    var response = await apiService.createAnnouncement(postData);

    setState(() => _isLoading = false);

    print("📥 ตอบกลับจาก API: $response");

    if (response["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"] ?? "บันทึกสำเร็จ!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"] ?? "เกิดข้อผิดพลาด!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('📢 สร้างแจ้งเตือน', style: TextStyle(fontWeight: FontWeight.w600))),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildCard(
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'หัวข้อแจ้งเตือน',
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 15),
              _buildCard(
                child: TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'รายละเอียดแจ้งเตือน',
                    border: InputBorder.none,
                  ),
                  maxLines: 3,
                ),
              ),
              SizedBox(height: 15),
              _buildCard(
                child: DropdownButtonFormField<String>(
                  value: _selectedType,
                  onChanged: (value) => setState(() => _selectedType = value!),
                  items: ["มอบหมายงาน", "ประชุม", "ทั่วไป", "เร่งด่วน", "สำคัญ", "อบรม", "อุบัติเหตุ","อื่นๆ"]
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  decoration: InputDecoration(
                    labelText: "ประเภทการแจ้งเตือน",
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 15),
              _buildCard(child: DatePickerWidget(title: "📅 วันที่แจ้งเตือน", selectedDate: _selectedNotifyDate, onDatePicked: (date) => setState(() => _selectedNotifyDate = date))),
              _buildCard(child: DatePickerWidget(title: "⏳ เดดไลน์", selectedDate: _selectedDeadline, onDatePicked: (date) => setState(() => _selectedDeadline = date))),
              SizedBox(height: 20),
               _buildFileUploadSection(),
              _buildExpandableCheckboxList("แจ้งเตือนทั้งฝ่าย (Department)", departments, selectedDepartments),
              _buildExpandableCheckboxList("แจ้งเตือนทั้งกอง (Division)", divisions, selectedDivisions),
              _buildExpandableCheckboxList("แจ้งเตือนทั้งแผนก (Section)", sections, selectedSections),
              _buildExpandableCheckboxList("เลือกพนักงานเฉพาะบุคคล", users.map((u) => u["name"].toString()).toSet(), selectedUserIds),
              SizedBox(height: 20),
             
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        onPressed: _isLoading ? null : _submitAnnouncement,
        icon: _isLoading ? CircularProgressIndicator(color: Colors.white) : Icon(Icons.check, color: Colors.white),
        label: Text(_isLoading ? "กำลังบันทึก..." : "บันทึกแจ้งเตือน", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10), child: child),
    );
  }

  Widget _buildExpandableCheckboxList(String title, Set<String> items, List<String> selectedItems) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        children: items.map((item) {
          return CheckboxListTile(
            title: Text(item),
            value: selectedItems.contains(item),
            onChanged: (bool? selected) {
              setState(() {
                if (selected!) {
                  selectedItems.add(item);
                } else {
                  selectedItems.remove(item);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFileUploadSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("อัปโหลดไฟล์แนบ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 10),

          /// 🖼 ปุ่มเลือกไฟล์ PDF
          ElevatedButton.icon(
            icon: Icon(Icons.picture_as_pdf, color: Colors.red),
            label: Text("เลือกไฟล์ PDF"),
            onPressed: _pickFile,
          ),
          SizedBox(height: 10),

          /// 📂 ปุ่มเลือกภาพจากอัลบั้ม
          ElevatedButton.icon(
            icon: Icon(Icons.image, color: Colors.blue),
            label: Text("เลือกรูปภาพจากอัลบั้ม"),
            onPressed: _pickImageFromGallery,
          ),

          /// ✅ แสดงไฟล์ที่เลือก
          if (_selectedFile != null) ...[
            SizedBox(height: 10),
            Text("📁 ไฟล์ที่เลือก: ${_selectedFile!.path.split('/').last}"),
          ],
        ],
      ),
    );
  }
}