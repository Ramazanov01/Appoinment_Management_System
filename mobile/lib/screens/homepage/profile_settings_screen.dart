import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import 'edit_profile_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

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
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );

    // Reload user data if profile was updated
    if (result == true) {
      _loadUserData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil ve Ayarlar'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Başlık
            Text(
              "Profile & Settings",
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // 2. Profil Kartı (Görseldeki Ana Kutu)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kullanıcı Bilgileri (Resim, İsim, ID)
                    Row(
                      children: [
                        // Profil Resmi
                        const CircleAvatar(
                          radius: 30,
                          // Görseldeki Emma Wilson resmi için yer tutucu:
                          backgroundImage: AssetImage(
                            'assets/profile_placeholder.jpg',
                          ),
                          backgroundColor: Colors.grey,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 15),
                        // İsim ve ID
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isLoading ? 'Loading...' : _getUserName(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _isLoading 
                                ? 'Loading...' 
                                : 'Patient ID: ${_getUserId()}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(), // Boşluğu doldurur
                        // Sağ üstteki Ayarlar İkonu
                        Icon(Icons.settings, color: Colors.blue.shade700),
                      ],
                    ),
                    const Divider(height: 30),

                    // 3. Menü Öğeleri

                    // Profil Düzenle
                    ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('Edit Profile'),
                      onTap: _navigateToEditProfile,
                      contentPadding: EdgeInsets.zero,
                    ),

                    // Bildirim Ayarları
                    ListTile(
                      leading: const Icon(Icons.notifications_none),
                      title: const Text('Notification Settings'),
                      onTap: () {
                        print('Bildirim Ayarları tıklandı');
                        // TODO: Bildirim Ayarları sayfasına yönlendirme
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
