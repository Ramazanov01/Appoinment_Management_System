import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'patient_schedule_screen.dart';
import '../../services/storage_service.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  int todayAppointmentsCount = 0;
  int totalDoctorsCount = 0;
  double attendanceRate = 0.0;
  List<dynamic> todaysPatients = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final appointmentsData = await ApiService.getTodaysDoctorAppointments();
      final allDoctors = await ApiService.getAllProviders();
      final rate = await ApiService.getAttendanceRate();

      setState(() {
        todaysPatients = appointmentsData['appointments'] ?? [];
        todayAppointmentsCount = todaysPatients.length;
        totalDoctorsCount = allDoctors.length;
        attendanceRate = rate;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Doctor Dashboard',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildMetricsGrid(),
                    const SizedBox(height: 24),
                    _buildSchedulePreview(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildMetricCard(
          todayAppointmentsCount.toString(),
          'Today\'s Patients',
          Icons.calendar_today,
          Colors.blue,
        ),
        _buildMetricCard(
          totalDoctorsCount.toString(),
          'Active Staff',
          Icons.people,
          Colors.green,
        ),
        _buildMetricCard(
          '%$attendanceRate',
          'Success Rate',
          Icons.trending_up,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSchedulePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Preview",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PatientScheduleScreen(),
                  ),
                ),
                child: const Text("View Full Schedule"),
              ),
            ],
          ),
          if (todaysPatients.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text("Bugün için randevu yok."),
            )
          else
            ...todaysPatients
                .take(3)
                .map(
                  (ap) => ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(ap['user_name']),
                    subtitle: Text(ap['time']),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                )
                .toList(),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Center(
              child: Text(
                "AppointPro Manager",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Dashboard"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text("Patient Schedule"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PatientScheduleScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              // 1. Storage'daki tüm verileri temizle (Token vb.)
              await StorageService.clearAll();

              // 2. Uygulamayı en başa döndür ve sayfaları temizle
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/', // main.dart'taki başlangıç rotası
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
