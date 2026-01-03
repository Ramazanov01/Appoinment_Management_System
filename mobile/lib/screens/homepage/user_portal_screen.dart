import 'package:flutter/material.dart';
import '../../widgets/quick_booking_panel.dart';
import 'profile_settings_screen.dart';
import 'appointments_screen.dart';
import 'provider_list_screen.dart'; // ⭐️ Yeni ekranı buraya ekledik
import '../../services/storage_service.dart';

class UserPortalScreen extends StatefulWidget {
  const UserPortalScreen({super.key});

  @override
  State<UserPortalScreen> createState() => _UserPortalScreenState();
}

class _UserPortalScreenState extends State<UserPortalScreen> {
  bool _isSidebarOpen = false;
  final double _sidebarWidth = 250.0;

  Map<String, dynamic>? _userData;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await StorageService.getUserData();
      if (mounted) {
        setState(() {
          _userData = userData;
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  
  String _getUserName() {
    if (_userData == null) return 'Loading...';
    final firstName = _userData!['firstName'] ?? '';
    final lastName = _userData!['lastName'] ?? '';
    if (firstName.isEmpty && lastName.isEmpty) {
      return _userData!['email'] ?? 'User';
    }
    return '$firstName $lastName'.trim();
  }

  String _getUserId() {
    if (_userData == null) return '';
    final id = _userData!['id']?.toString() ?? '';
    return id.isNotEmpty ? '#$id' : '';
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade700),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () async {
        // async ekledik çünkü logout işlemi beklemeli olabilir
        print('$title tıklandı');

        setState(() {
          _isSidebarOpen = false;
        });

        if (title == 'My Appointments') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AppointmentsScreen()),
          );
        } else if (title == 'Find Providers') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProviderListScreen()),
          );
        }
        // ⭐️ Logout Kontrolü Eklendi
        else if (title == 'Logout') {
          // 1. Hafızadaki tüm verileri (token, user info) temizle
          await StorageService.clearAll();

          // 2. Kullanıcıyı en başa (root) gönder ve geçmişi sil
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/', // main.dart'taki başlangıç rotası
              (route) => false,
            );
          }
        }
      },
    );
  }

  Widget _buildPanel(BuildContext context, String title, Color color) {
    final bool isProfilePanel = title == 'Profile & Settings';
    final bool isAppointmentsPanel = title == 'My Appointments';

    return GestureDetector(
      onTap: isProfilePanel || isAppointmentsPanel
          ? () {
              final Widget targetScreen = isAppointmentsPanel
                  ? const AppointmentsScreen()
                  : const ProfileSettingsScreen();

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => targetScreen),
              );
            }
          : null,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isProfilePanel)
                    Icon(Icons.settings, color: Colors.blue.shade700),
                  if (isAppointmentsPanel)
                    Icon(Icons.access_time_filled, color: Colors.blue.shade700),
                ],
              ),
              if (isProfilePanel) ...[
                const SizedBox(height: 10),
                Text(
                  _isLoadingUser
                      ? 'Loading...'
                      : '${_getUserName()}${_getUserId().isNotEmpty ? ", Patient ID: ${_getUserId()}" : ""}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Management System'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            setState(() {
              _isSidebarOpen = !_isSidebarOpen;
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: screenWidth,
            color: Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const QuickBookingPanel(),
                          const SizedBox(height: 20),
                          _buildPanel(
                            context,
                            'My Appointments',
                            Colors.green.shade50,
                          ),
                          const SizedBox(height: 20),
                          _buildPanel(
                            context,
                            'Profile & Settings',
                            Colors.orange.shade50,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            left: _isSidebarOpen ? 0.0 : -_sidebarWidth,
            top: 0,
            bottom: 0,
            width: _sidebarWidth,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 40,
                            color: Colors.blue,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'AppointPro',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Management Suite',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Text(
                        'USER PORTAL',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      Icons.calendar_today_outlined,
                      'Book Appointment',
                    ),
                    _buildMenuItem(Icons.access_time_filled, 'My Appointments'),
                    _buildMenuItem(
                      Icons.person_search_outlined,
                      'Find Providers', // ⭐️ Navigasyon eklendi
                    ),
                    _buildMenuItem(
                      Icons.description_outlined,
                      'Medical Records',
                    ),
                    _buildMenuItem(Icons.logout, 'Logout'),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
