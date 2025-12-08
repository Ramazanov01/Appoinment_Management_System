import 'package:flutter/material.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

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
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Emma Wilson', // TODO: Buraya Backend'den gelen adı yazın
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Patient ID: #12345',
                              style: TextStyle(
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
                      onTap: () {
                        print('Profil Düzenle tıklandı');
                        // TODO: Profil Düzenleme sayfasına yönlendirme
                      },
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
