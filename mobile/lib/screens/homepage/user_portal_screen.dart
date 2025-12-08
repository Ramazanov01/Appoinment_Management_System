import 'package:flutter/material.dart';
import '../../widgets/quick_booking_panel.dart';
import 'profile_settings_screen.dart';

class UserPortalScreen extends StatefulWidget {
  const UserPortalScreen({super.key});

  @override
  State<UserPortalScreen> createState() => _UserPortalScreenState();
}

class _UserPortalScreenState extends State<UserPortalScreen> {
  // Menünün açık/kapalı durumunu tutan değişken
  bool _isSidebarOpen = false;

  // ⭐️ Menünün sabit genişliği
  final double _sidebarWidth = 250.0;

  // Menü öğesi oluşturan yardımcı fonksiyon
  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade700),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        print('$title tıklandı');
        // Menüyü kapama mantığı eklenebilir
        setState(() {
          _isSidebarOpen = false;
        });
      },
    );
  }

  // Diğer paneller için yer tutucu widget
  Widget _buildPanel(String title, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ekranın tam genişliğini alıyoruz
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Management System'),

        // Menü İkonu: Tıklandığında yan paneli açıp kapatır
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            setState(() {
              _isSidebarOpen = !_isSidebarOpen;
            });
          },
        ),
        actions: [
          // Sağ üstteki kişi/ayarlar ikonu
          IconButton(
            icon: const Icon(Icons.person), // Görseldeki gibi bir ikon
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

      // ⭐️ Ana içerik: Stack kullanarak menüyü üzerine bindiriyoruz
      body: Stack(
        children: [
          // 1. Ana İçerik Katmanı (KAYMAYAN VE TAM EKRAN)
          Container(
            width: screenWidth,
            color: Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'User Portal Examples',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Panelleri içeren kaydırılabilir alan
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Quick Booking Paneli (Ayrı dosyadan geliyor)
                          const QuickBookingPanel(),
                          const SizedBox(height: 20),

                          // Diğer Paneller
                          _buildPanel('My Appointments', Colors.green.shade50),
                          const SizedBox(height: 20),
                          _buildPanel(
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

          // 2. Yan Panel (Üst Üste Binen Katman)
          AnimatedPositioned(
            // duration: const Duration(milliseconds: 300),
            // curve: Curves.easeOut,
            // // Açık: 0.0, Kapalı: -250.0 (ekranın solunda gizli)
            // left: _isSidebarOpen ? 0.0 : -_sidebarWidth,
            // top: 0,
            // bottom: 0,
            // width: _sidebarWidth,

            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            left: _isSidebarOpen ? 0.0 : -_sidebarWidth,
            top: 0,
            bottom: 0,
            width: _sidebarWidth,

              child: Container(
                // ⭐️ Container'ın rengini doğrudan buraya ekleyelim (En güvenilir yöntem)
                //color: Colors.white, 
                
                // Decoration kullanmaya devam etmek için rengi buradan SİLİN.
                decoration: BoxDecoration(
                  // color: Colors.white, // ❌ Eğer color'ı burada tutuyorsanız silin.
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 204, 212, 219),  //.withOpacity(0.15),
                      blurRadius: 10,
                    ),
                  ],
                ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo ve Uygulama Adı
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

                    // Menü Öğeleri Başlığı
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

                    // Menü Öğeleri
                    _buildMenuItem(
                      Icons.calendar_today_outlined,
                      'Book Appointment',
                    ),
                    _buildMenuItem(Icons.access_time_filled, 'My Appointments'),
                    _buildMenuItem(
                      Icons.person_search_outlined,
                      'Find Providers',
                    ),
                    _buildMenuItem(
                      Icons.description_outlined,
                      'Medical Records',
                    ),
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
