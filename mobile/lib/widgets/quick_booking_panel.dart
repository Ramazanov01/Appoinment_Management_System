// import 'package:flutter/material.dart';

// // Eğer HTTP paketini kullanacaksanız yorumları kaldırın ve bunları ekleyin:
// // import 'dart:convert';
// // import 'package:http/http.dart' as http;

// class QuickBookingPanel extends StatefulWidget {
//   const QuickBookingPanel({super.key});

//   @override
//   State<QuickBookingPanel> createState() => _QuickBookingPanelState();
// }

// class _QuickBookingPanelState extends State<QuickBookingPanel> {
//   // 1. Durum Değişkenleri
//   String? _selectedServiceType;
//   DateTime _selectedDate = DateTime.now();

//   // Başlangıç verisi (Backend'den çekilecek verilerin yer tutucusu)
//   List<String> _serviceTypes = ['Consultation', 'Check-up', 'Therapy'];

//   // Backend'den geldiği varsayılan dolu günler (örnek olarak 2. ve 5. günler dolu)
//   List<DateTime> _busyDates = [
//     DateTime.now().add(const Duration(days: 2)),
//     DateTime.now().add(const Duration(days: 5)),
//   ];

//   // Seçilen gün için backend'den gelen müsait saatler
//   List<String> _availableTimes = [];

//   // Bu ayın ilk gününü ve son gününü bulur
//   DateTime get _firstDayOfMonth =>
//       DateTime(_selectedDate.year, _selectedDate.month, 1);
//   DateTime get _lastDayOfMonth =>
//       DateTime(_selectedDate.year, _selectedDate.month + 1, 0);

//   // -------------------------------------------------------------------------
//   // Backend'den Veri Çekme Fonksiyonları (Yoruma Alınmış)
//   // -------------------------------------------------------------------------

//   /*
//   Future<void> _fetchServiceTypes() async {
//     // Servis Türlerini Çekme mantığı buraya gelecek
//   }
  
//   Future<void> _fetchAvailableTimes(DateTime date) async {
//     // Müsait Saatleri Çekme mantığı buraya gelecek
//     // Aşağıdaki gibi bir simülasyon yapabilirsiniz:
    
//     // Simülasyon: 1 saniye bekleyip saatleri yüklüyoruz
//     // await Future.delayed(const Duration(seconds: 1)); 
//     // setState(() {
//     //   _availableTimes = ['10:00', '11:30', '14:00', '16:30']; 
//     // });
//   }
//   */

//   // -------------------------------------------------------------------------
//   // Arayüz (UI) Yapısı
//   // -------------------------------------------------------------------------

//   // Belirli bir günün dolu olup olmadığını kontrol eder
//   bool _isDateBusy(DateTime date) {
//     return _busyDates.any(
//       (busyDate) =>
//           busyDate.year == date.year &&
//           busyDate.month == date.month &&
//           busyDate.day == date.day,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             // Başlık
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Quick Booking',
//                   style: Theme.of(context).textTheme.headlineSmall,
//                 ),
//                 const Icon(Icons.calendar_month, color: Colors.blue),
//               ],
//             ),
//             const Divider(),

//             // 1. Servis Türü Seçimi
//             const Text(
//               'Service Type',
//               style: TextStyle(color: Colors.grey, fontSize: 14),
//             ),
//             DropdownButtonFormField<String>(
//               decoration: const InputDecoration(border: OutlineInputBorder()),
//               value: _selectedServiceType,
//               hint: const Text('Consultation'),
//               items: _serviceTypes.map((String service) {
//                 return DropdownMenuItem<String>(
//                   value: service,
//                   child: Text(service),
//                 );
//               }).toList(),
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _selectedServiceType = newValue;
//                 });
//               },
//             ),
//             const SizedBox(height: 20),

//             // 2. Takvim Başlık ve Ay Kontrolü
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Preferred Date',
//                   style: TextStyle(color: Colors.grey, fontSize: 14),
//                 ),
//                 Text(
//                   '${_firstDayOfMonth.month.toString().padLeft(2, '0')}.${_firstDayOfMonth.year}',
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),

//             // 3. Takvim (Sadece Bu Ayı Gösteren Sadeleştirilmiş Görünüm)
//             Container(
//               height: 70, // Yüksekliği sabit tutar
//               alignment: Alignment.center,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: _lastDayOfMonth.day,
//                 itemBuilder: (context, index) {
//                   final day = index + 1;
//                   final currentDate = DateTime(
//                     _selectedDate.year,
//                     _selectedDate.month,
//                     day,
//                   );
//                   final isBusy = _isDateBusy(currentDate);
//                   final isSelected = currentDate.day == _selectedDate.day;

//                   return GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _selectedDate = currentDate;
//                         _availableTimes = [];
//                         // _fetchAvailableTimes(currentDate); // ⭐️ Backend'den saatleri çekme komutu (Yoruma Alınmış)
//                         print(
//                           'Seçilen Tarih: $currentDate. Saatler backend\'den bekleniyor.',
//                         );
//                         // Simülasyon için:
//                         // _availableTimes = ['10:00', '11:30', '14:00'];
//                       });
//                     },
//                     child: Container(
//                       width: 50,
//                       margin: const EdgeInsets.symmetric(horizontal: 4),
//                       decoration: BoxDecoration(
//                         // Dolu: Kırmızı, Seçili: Mavi, Müsait: Yeşil
//                         color: isBusy
//                             ? Colors.red.shade400
//                             : (isSelected
//                                   ? Colors.blue
//                                   : Colors.green.shade400),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             currentDate.day.toString(),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Text(
//                             [
//                               'Mon',
//                               'Tue',
//                               'Wed',
//                               'Thu',
//                               'Fri',
//                               'Sat',
//                               'Sun',
//                             ][currentDate.weekday - 1],
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 20),

//             // 4. Müsait Saatleri Gösterme
//             const Text(
//               'Available Times',
//               style: TextStyle(color: Colors.grey, fontSize: 14),
//             ),
//             _availableTimes.isEmpty && _selectedDate != null
//                 ? const Text(
//                     'Lütfen müsait saatleri görmek için bir gün seçin.',
//                     style: TextStyle(
//                       fontStyle: FontStyle.italic,
//                       color: Colors.grey,
//                     ),
//                   )
//                 : Wrap(
//                     spacing: 8.0,
//                     runSpacing: 8.0,
//                     children: _availableTimes.map((time) {
//                       return Chip(
//                         label: Text(time),
//                         backgroundColor: Colors.blue.shade100,
//                       );
//                     }).toList(),
//                   ),

//             const SizedBox(height: 30),

//             // 5. Randevu Butonu
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               onPressed: () {
//                 print(
//                   'Randevu Oluşturuldu: $_selectedServiceType, ${_selectedDate.toIso8601String()}',
//                 );
//                 // TODO: Randevu oluşturma isteği backend'e gönderilecek.
//               },
//               child: const Text(
//                 'Book Appointment',
//                 style: TextStyle(fontSize: 18),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

// Eğer HTTP paketini kullanacaksanız yorumları kaldırın ve bunları ekleyin:
// import 'dart:convert';
// import 'package:http/http.dart' as http;

class QuickBookingPanel extends StatefulWidget {
  const QuickBookingPanel({super.key});

  @override
  State<QuickBookingPanel> createState() => _QuickBookingPanelState();
}

class _QuickBookingPanelState extends State<QuickBookingPanel> {
  // 1. Durum Değişkenleri
  String? _selectedServiceType;
  DateTime _selectedDate = DateTime.now(); // Seçilen Tarih (ve Saat)
  List<String> _serviceTypes = ['Consultation', 'Check-up', 'Therapy'];

  // Backend'den geldiği varsayılan dolu günler
  List<DateTime> _busyDates = [
    DateTime.now().add(const Duration(days: 2)),
    DateTime.now().add(const Duration(days: 5)),
  ];

  // Seçilen gün için backend'den gelen müsait saatler
  List<String> _availableTimes = [];

  // -------------------------------------------------------------------------
  // Yardımcı Fonksiyonlar ve Backend Simülasyonu
  // -------------------------------------------------------------------------

  bool _isDateBusy(DateTime date) {
    // Sadece yıl, ay ve gün kontrol edilir
    return _busyDates.any(
      (busyDate) =>
          busyDate.year == date.year &&
          busyDate.month == date.month &&
          busyDate.day == date.day,
    );
  }

  // Müsait Saatleri Çekme Simülasyonu
  Future<void> _fetchAvailableTimes(DateTime date) async {
    // Backend'den saatleri çekme kısmı yoruma alındı.
    // print('Backend\'den müsait saatler çekiliyor: ${date.toIso8601String()}');

    // Simülasyon: 1 saniye bekleyip saatleri yüklüyoruz
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      // Örnek müsait saatler yüklüyoruz
      _availableTimes = [
        '10:00 AM',
        '11:00 AM',
        '11:30 AM',
        '12:00 PM',
        '1:00 PM',
        '1:30 PM',
        '2:00 PM',
      ];
    });
  }

  // -------------------------------------------------------------------------
  // Özel Tarih/Saat Seçim Diyaloğu (Görsele Benzer Yapı)
  // -------------------------------------------------------------------------

  Future<void> _showDateTimeDialog(BuildContext context) async {
    // Diyalog içinde durumu yönetmek için yerel değişkenler
    DateTime tempDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    String? tempTime;

    // Şu anki ayı temsil eden takvim yapısı
    Widget _buildMonthCalendar() {
      // Sadece bu ayın günlerini içeren sadeleştirilmiş takvim
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7, // 7 gün
          childAspectRatio: 1.0,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: 30, // Basitlik için 30 gün varsayalım
        itemBuilder: (context, index) {
          final day = index + 1;
          final currentDate = DateTime(tempDate.year, tempDate.month, day);

          // Ayın dışındaki günler için kontrol
          if (currentDate.month != tempDate.month ||
              currentDate.isAfter(
                DateTime.now().add(const Duration(days: 30)),
              )) {
            return const SizedBox.shrink();
          }

          final isBusy = _isDateBusy(currentDate);
          final isSelected = currentDate.day == tempDate.day;

          return InkWell(
            onTap: () {
              // setState çağırmak için diyalog içindeki builder'ı kullanmalıyız.
              // Şimdilik sadece tempDate'i güncelleyelim.
              tempDate = currentDate;
              // Diyaloğu kapatıp tekrar açmak yerine, ana sayfadan güncelleyeceğiz
              Navigator.of(
                context,
              ).pop(true); // Değişiklik oldu, ana widget'a bildir
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue
                    : isBusy
                    ? Colors.red.shade400
                    : Colors.green.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: isSelected || isBusy ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        },
      );
    }

    // Saat seçim diyalogunu açar ve sonucu bekler
    final result = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          titlePadding: EdgeInsets.zero,
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          content: Container(
            width: 500, // Görsele benzeyen genişlik
            height: 400, // Görsele benzeyen yükseklik
            child: Row(
              children: [
                // 1. Takvim Paneli
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.blue, // Başlık rengi
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.arrow_left, color: Colors.white),
                              Text(
                                '${tempDate.month.toString().padLeft(2, '0')} / ${tempDate.year}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_right,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        // Gün isimleri
                        const Row(
                          children: [
                            Expanded(
                              child: Text('Sun', textAlign: TextAlign.center),
                            ),
                            Expanded(
                              child: Text('Mon', textAlign: TextAlign.center),
                            ),
                            Expanded(
                              child: Text('Tue', textAlign: TextAlign.center),
                            ),
                            Expanded(
                              child: Text('Wed', textAlign: TextAlign.center),
                            ),
                            Expanded(
                              child: Text('Thu', textAlign: TextAlign.center),
                            ),
                            Expanded(
                              child: Text('Fri', textAlign: TextAlign.center),
                            ),
                            Expanded(
                              child: Text('Sat', textAlign: TextAlign.center),
                            ),
                          ],
                        ),
                        _buildMonthCalendar(), // Takvim Gridi
                      ],
                    ),
                  ),
                ),

                // 2. Saat Paneli
                Expanded(
                  flex: 1,
                  child: Container(
                    color:
                        Colors.blue.shade700, // Görseldeki gibi koyu arka plan
                    child: ListView.builder(
                      itemCount: _availableTimes
                          .length, // Simülasyonda çektiğimiz saatleri kullan
                      itemBuilder: (context, index) {
                        final time = _availableTimes[index];
                        final isSelected = tempTime == time;

                        return ListTile(
                          title: Text(
                            time,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                            ),
                          ),
                          tileColor: isSelected
                              ? Colors.white
                              : Colors.blue.shade700,
                          selected: isSelected,
                          onTap: () {
                            // setState kullanmak için diyalog içindeki builder'ı kullanmalıyız.
                            // Ancak biz sonucu "Done" butonuna bırakıyoruz.
                            tempTime = time;
                            Navigator.of(
                              dialogContext,
                            ).pop(true); // Saati seçti, ana widget'a bildir.
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Bugün'),
              onPressed: () => Navigator.of(dialogContext).pop(DateTime.now()),
            ),
            TextButton(
              child: const Text('Şimdi'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
            ElevatedButton(
              child: const Text('Bitti'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ), // Sonucu geri gönder
          ],
        );
      },
    );

    // Ana widget'ta durumu güncelleme
    if (result is bool && result == true) {
      // Diyalog kapatıldı, durumu güncelle
      setState(() {
        _selectedDate = tempDate; // Yeni tarihi kaydet
        _availableTimes = []; // Saatleri temizle (yeni çekim için)
        // _fetchAvailableTimes(_selectedDate); // ⭐️ Backend çağrısını başlat
      });
    } else if (result is DateTime) {
      // Bugün seçildi
      setState(() {
        _selectedDate = result;
        _availableTimes = [];
        // _fetchAvailableTimes(_selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... [QuickBookingPanel] UI yapısı ...
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // ... (Başlık ve Servis Tipi Seçimi)

            // 1. Servis Türü Seçimi
            const Text(
              'Service Type',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            DropdownButtonFormField<String>(
              // ... (DropdownButton kodu)
              decoration: const InputDecoration(border: OutlineInputBorder()),
              value: _selectedServiceType,
              hint: const Text('Consultation'),
              items: _serviceTypes.map((String service) {
                return DropdownMenuItem<String>(
                  value: service,
                  child: Text(service),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedServiceType = newValue;
                });
              },
            ),
            const SizedBox(height: 20),

            // 2. Tarih Alanı (Yeni Tıklanabilir Alan)
            const Text(
              'Preferred Date',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            GestureDetector(
              onTap: () =>
                  _showDateTimeDialog(context), // ⭐️ Özel diyalogu açar
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 15,
                  ),
                ),
                child: Text(
                  // Seçilen tarihi gösterir
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} ${_selectedDate.hour}:${_selectedDate.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 3. Müsait Saatleri Gösterme (Bu kısım artık sadece bilgi için kaldı)
            const Text(
              'Available Times',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            _availableTimes.isEmpty && _selectedDate != null
                ? const Text(
                    'Lütfen müsait saatleri görmek için bir gün seçin.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  )
                : Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _availableTimes.map((time) {
                      return Chip(
                        label: Text(time),
                        backgroundColor: Colors.blue.shade100,
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 30),

            // 4. Randevu Butonu
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                print(
                  'Randevu Oluşturuldu: $_selectedServiceType, ${_selectedDate.toIso8601String()}',
                );
                // TODO: Randevu oluşturma isteği backend'e gönderilecek.
              },
              child: const Text(
                'Book Appointment',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
