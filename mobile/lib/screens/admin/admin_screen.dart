import 'package:flutter/material.dart';
import 'create_manager_screen.dart';
import 'manager_management_screen.dart'; // Yeni oluşturduğumuz ekran
import '../../services/api_service.dart';
import 'dart:async'; // Timer için gerekli
import '../../services/storage_service.dart';

// ... initState içine ekle:
Timer? _timer;

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // İstatistik Değişkenleri
  int totalUsers = 0;
  int totalManagers = 0;
  int activeToday = 0;
  int newThisWeek = 0;
  bool _isLoading = true;

  // Email Kontrolcüleri
  final TextEditingController _emailContentController = TextEditingController();
  bool _isSendingEmail = false;

  // @override
  // void initState() {
  //   super.initState();
  //   _fetchAdminStats();
  // }
  
  @override
  void initState() {
    super.initState();
    _fetchAdminStats();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchAdminStats();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Sayfadan çıkınca zamanlayıcıyı durdur
    super.dispose();
  }
  // İstatistikleri Backend'den Çekme
  Future<void> _fetchAdminStats() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getAdminStats();
      if (result['success']) {
        final stats = result['data'];
        setState(() {
          totalUsers = stats['totalUsers'] ?? 0;
          totalManagers = stats['totalManagers'] ?? 0;
          activeToday = stats['activeToday'] ?? 0;
          newThisWeek = stats['newThisWeek'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    // 1. Kullanıcıdan onay al
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // 2. StorageService üzerinden tüm verileri temizle
      await StorageService.clearAll();

      // 3. Login ekranına yönlendir ve geri dönüşü engelle
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    }
  }

  // Tüm Kullanıcılara Mail Gönderimi
  Future<void> _sendBulkEmail() async {
    final content = _emailContentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSendingEmail = true);
    try {
      final result = await ApiService.sendBulkEmail(content);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
      if (result['success']) _emailContentController.clear();
    } finally {
      if (mounted) setState(() => _isSendingEmail = false);
    }
  }

  // Sadece Managerlara Mail Gönderimi
  Future<void> _sendManagerEmail() async {
    final content = _emailContentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSendingEmail = true);
    try {
      final result = await ApiService.sendManagerBulkEmail(content);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.purple : Colors.red,
        ),
      );
      if (result['success']) _emailContentController.clear();
    } finally {
      if (mounted) setState(() => _isSendingEmail = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Admin Management Panel',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              // İstatistikleri yenilemek için aşağı kaydırma
              onRefresh: _fetchAdminStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(children: [_buildMainContent()]),
              ),
            ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          const SizedBox(height: 60),
          const Text(
            'ADMIN TOOLS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const Divider(),
          _buildDrawerItem(Icons.shield, 'User Roles', () {}),
          // SİSTEM YÖNETİMİ BURADA:
          _buildDrawerItem(Icons.storage, 'Data Management', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManagerManagementScreen(),
              ),
            );
          }),
          _buildDrawerItem(Icons.notifications, 'Notification Logs', () {}),
          _buildDrawerItem(Icons.logout, 'Logout', _handleLogout),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF9C27B0)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.pop(context); // Drawer'ı kapat
        onTap();
      },
    );
  }

  Widget _buildMainContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: _buildUserManagementCard()),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildEmailNotificationCard()),
            ],
          );
        } else {
          return Column(
            children: [
              _buildUserManagementCard(),
              const SizedBox(height: 16),
              _buildEmailNotificationCard(),
            ],
          );
        }
      },
    );
  }

  Widget _buildUserManagementCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Statistics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildStatRow('Total Users', totalUsers.toString(), Colors.grey),
            const SizedBox(height: 12),
            _buildStatRow(
              'Total Managers',
              totalManagers.toString(),
              Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildStatRow('Active Today', activeToday.toString(), Colors.green),
            const SizedBox(height: 12),
            _buildStatRow('New This Week', newThisWeek.toString(), Colors.blue),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateManagerScreen(),
                  ),
                ),
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Create Manager'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailNotificationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.mail_outline, color: Colors.blue),
                SizedBox(width: 10),
                Text(
                  'Email Notification',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailContentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Type your message here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 20),
            // BUTONLAR ALT ALTA (Taşmayı önlemek için)
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isSendingEmail ? null : _sendManagerEmail,
                    icon: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.purple,
                    ),
                    label: Text(
                      _isSendingEmail ? 'Sending...' : 'Send to Managers Only',
                      style: const TextStyle(color: Colors.purple),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.purple),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSendingEmail ? null : _sendBulkEmail,
                    icon: const Icon(Icons.send),
                    label: Text(
                      _isSendingEmail ? 'Sending...' : 'Send to All Users',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
