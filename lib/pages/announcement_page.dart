import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import 'create_announcement_page.dart';
import '../utils/icon_helper.dart';

class AnnouncementsPage extends StatefulWidget {
  @override
  _AnnouncementsPageState createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage>
    with TickerProviderStateMixin {
  List<dynamic> notifications = [];
  List<dynamic> myAssignments = [];
  List<dynamic> allAssignments = [];
  String? currentEmployeeId;
  bool isLoading = true;
  final ApiService apiService = ApiService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _getCurrentEmployee();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentEmployee() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentEmployeeId = prefs.getString('employee_id');

    if (currentEmployeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด: ไม่พบรหัสพนักงาน")),
      );
      return;
    }

    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);

    var responseAnnouncements = await apiService.getAnnouncements();
    var responseMyAssignments =
        await apiService.getUserNotifications(currentEmployeeId!);
    var responseAllAssignments = await apiService.getAllAssignments();

    setState(() {
      notifications = responseAnnouncements["announcements"]
              ?.where((item) => item["type"] != "มอบหมายงาน")
              .toList() ??
          [];
      myAssignments = responseMyAssignments["notifications"] ?? [];
      allAssignments = responseAllAssignments["assignments"] ?? [];
    });

    setState(() => isLoading = false);
  }

  Future<bool> _checkAcknowledgementStatus(String announcementId) async {
    if (currentEmployeeId == null) return false;

    var response = await apiService.checkAcknowledgementStatus(
      announcementId,
      currentEmployeeId!,
    );

    return response["alreadyAccepted"] ?? false;
  }

  Future<void> _acknowledgeAssignment(String announcementId) async {
    if (currentEmployeeId == null) return;

    var response = await apiService.acknowledgeAnnouncement(
      announcementId,
      currentEmployeeId!,
    );

    if (response["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"] ?? "ยอมรับงานสำเร็จ")),
      );
      fetchData();
    }
  }

  Widget _buildAssignmentList(List<dynamic> assignments) {
    return RefreshIndicator(
      onRefresh: () async {
        await fetchData(); // ✅ โหลดข้อมูลใหม่เมื่อรูดลง
      },
      child: assignments.isEmpty
          ? Center(
              child:
                  Text("📭 ไม่มีข้อมูล", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                var item = assignments[index];

                return FutureBuilder<bool>(
                  future: _checkAcknowledgementStatus(item['id']),
                  builder: (context, snapshot) {
                    bool alreadyAcknowledged = snapshot.data ?? false;

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor:
                              Colors.blueAccent.withOpacity(0.2),
                          child: Icon(getIconForType(item['type'] ?? "อื่นๆ"),
                              color: const Color.fromARGB(255, 43, 54, 150)),
                        ),
                        title: Text(item['title'] ?? 'ไม่มีหัวข้อ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['description']?.replaceAll(r'\n', '\n') ?? 'ไม่มีรายละเอียด',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black54),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            Row(
                              children: [
                                Icon(Icons.person, size: 16, color: Colors.grey),
                                SizedBox(width: 5),
                                Text("โดย: ${item['created_by_name'] ?? item['name'] ?? 'ไม่ระบุ'}",
                                    style: TextStyle(fontSize: 13, color: Colors.grey)),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 16, color: Colors.grey),
                                SizedBox(width: 5),
                                Text("วันที่สร้าง: ${item['created_at'] ?? 'ไม่ระบุ'}",
                                    style: TextStyle(fontSize: 13, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),

                        onTap: () => _showAnnouncementModal(item),

                        trailing: IconButton(
                          icon: Icon(
                            alreadyAcknowledged
                                ? Icons.check_circle
                                : Icons.check_circle,
                            size: 30,
                            color: alreadyAcknowledged
                                ? Colors.grey
                                : Colors.green,
                          ),
                          tooltip: "รับทราบ",
                          splashRadius: 24,
                          onPressed: alreadyAcknowledged
                              ? null
                              : () => _acknowledgeAssignment(item['id']),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  void _showAnnouncementModal(Map<String, dynamic> announcement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(12),
          height: MediaQuery.of(context).size.height * 0.6,
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  labelColor: Colors.black,
                  indicatorColor: const Color.fromARGB(255, 3, 1, 3),
                  tabs: [
                    Tab(icon: Icon(Icons.description), text: "รายละเอียด"),
                    Tab(icon: Icon(Icons.check_circle), text: "สถานะรับทราบ"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildDetailsTab(announcement),
                      _buildAcknowledgementTab(announcement['id']),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildAcknowledgementTab(String announcementId) {
  return FutureBuilder<Map<String, dynamic>>(
    future: apiService.checkAcknowledgementStatus(
        announcementId, currentEmployeeId!),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }

      final data = snapshot.data ?? {};
      if (!data.containsKey("success") || data["success"] != true) {
        return Center(child: Text("ไม่สามารถโหลดข้อมูลได้"));
      }

      List<dynamic> acknowledgedUsers = data["acknowledged"] ?? [];
      List<dynamic> unacknowledgedUsers = data["unacknowledged"] ?? [];
      bool alreadyAccepted = data["alreadyAccepted"] ?? false;

      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ แสดงสถานะผู้ที่รับทราบแล้ว
              Text("ผู้ที่รับทราบ (${acknowledgedUsers.length})",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ...acknowledgedUsers.map((user) => ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text(user["name"] ?? "ไม่ระบุชื่อ"),
                  )),

              Divider(),

              // ✅ แสดงสถานะผู้ที่ยังไม่รับทราบ
              Text("ผู้ที่ยังไม่ได้รับทราบ (${unacknowledgedUsers.length})",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ...unacknowledgedUsers.map((user) => ListTile(
                    leading: Icon(Icons.cancel, color: Colors.red),
                    title: Text(user["name"] ?? "ไม่ระบุชื่อ"),
                  )),

              SizedBox(height: 20),

              // ✅ ปุ่มรับทราบ (ถ้าผู้ใช้ยังไม่กดรับทราบ)
              if (!alreadyAccepted)
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      await _acknowledgeAssignment(announcementId);
                      setState(() {}); // ✅ อัปเดตสถานะปุ่ม
                    },
                    icon: Icon(Icons.check, color: Colors.white),
                    label: Text("รับทราบ",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

 Widget _buildDetailsTab(Map<String, dynamic> announcement) {
  return SingleChildScrollView(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ หัวข้อ (Title)
          Text(
            announcement['title'] ?? 'ไม่มีหัวข้อ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: 10),

          // ✅ วันที่สร้าง
          Row(
            children: [
              Icon(Icons.access_time, size: 18, color: Colors.grey),
              SizedBox(width: 5),
              Text(
                "วันที่สร้าง: ${announcement['created_at'] ?? 'ไม่ระบุ'}",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 10),

        

          // ✅ เนื้อหาแจ้งเตือนแบบเว้นบรรทัด
          Container(
            padding: EdgeInsets.all(12),
            
            child: Text(
              announcement['description']?.replaceAll(r'\n', '\n') ?? 'ไม่มีรายละเอียด',
              textAlign: TextAlign.start, // ✅ ให้ข้อความขึ้นบรรทัดใหม่อัตโนมัติ
              softWrap: true, // ✅ รองรับข้อความที่ยาวขึ้น
              style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
            ),
          ),

          SizedBox(height: 20),

          // ✅ ปุ่มรับทราบ (เฉพาะกรณีที่เป็นมอบหมายงาน)
          if (announcement["type"] == "มอบหมายงาน")
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _acknowledgeAssignment(announcement['id']),
                icon: Icon(Icons.check, color: Colors.white),
                label: Text("รับทราบ", style: TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text('Work Krubb',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
         actions: [
        IconButton(
          icon: Icon(Icons.add_alert, color: const Color.fromARGB(255, 5, 5, 30)),
          tooltip: "สร้างแจ้งเตือน",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateAnnouncementPage()),
            );
          },
        ),
      ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color.fromARGB(255, 14, 0, 5),
          labelColor: Colors.black,
          tabs: [
            Tab(icon: Icon(Icons.notifications), text: 'แจ้งเตือน'),
            Tab(icon: Icon(Icons.list_alt), text: 'งานทั้งหมด'),
            Tab(icon: Icon(Icons.assignment_turned_in), text: 'งานของฉัน'),
           
          ],
        ),
      ),
     
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAssignmentList(notifications),
          _buildAssignmentList(myAssignments),
          _buildAssignmentList(allAssignments),
        ],
      ),
    );
  }
}