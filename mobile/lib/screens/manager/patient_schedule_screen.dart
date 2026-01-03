import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class PatientScheduleScreen extends StatefulWidget {
  const PatientScheduleScreen({Key? key}) : super(key: key);

  @override
  State<PatientScheduleScreen> createState() => _PatientScheduleScreenState();
}

class _PatientScheduleScreenState extends State<PatientScheduleScreen> {
  List<dynamic> _allAppointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchExtendedSchedule();
  }

  // 10 günlük genişletilmiş programı çeker
  Future<void> _fetchExtendedSchedule() async {
    setState(() => _isLoading = true);
    try {
      // Backend'de tüm randevuları çeken metodu kullanıyoruz
      final result = await ApiService.getDoctorSchedule();
      if (result['success']) {
        final List<dynamic> fetched = result['data'];

        // Sadece bugünden itibaren önümüzdeki 10 günü filtrele
        final now = DateTime.now();
        final tenDaysLater = now.add(const Duration(days: 10));

        setState(() {
          _allAppointments = fetched.where((ap) {
            final date = DateTime.parse(ap['date']);
            return date.isAfter(now.subtract(const Duration(days: 1))) &&
                date.isBefore(tenDaysLater);
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Randevu durumunu güncelleyen fonksiyon
  Future<void> _updateStatus(String id, String newStatus) async {
    final success = await ApiService.updateAppointmentStatus(id, newStatus);
    if (success['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Randevu durumu $newStatus olarak güncellendi.'),
        ),
      );
      _fetchExtendedSchedule(); // Listeyi yenile
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('10-Day Patient Schedule'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allAppointments.isEmpty
          ? const Center(
              child: Text("Önümüzdeki 10 gün için randevu bulunamadı."),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _allAppointments.length,
              itemBuilder: (context, index) {
                final ap = _allAppointments[index];
                final date = DateTime.parse(ap['date']);
                final formattedDate = DateFormat('EEE, d MMM').format(date);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue.shade50,
                              child: const Icon(
                                Icons.person,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ap['user_name'] ?? 'Bilinmeyen Hasta',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "${ap['service']} - $formattedDate @ ${ap['time']}",
                                  ),
                                ],
                              ),
                            ),
                            _buildStatusBadge(ap['status']),
                          ],
                        ),
                        const Divider(height: 24),
                        if (ap['status'] == 'Confirmed')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(
                                  Icons.cancel_outlined,
                                  color: Colors.red,
                                ),
                                label: const Text(
                                  "İptal Et",
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () =>
                                    _updateStatus(ap['id'], 'Cancelled'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text("Tamamla"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () =>
                                    _updateStatus(ap['id'], 'Completed'),
                              ),
                            ],
                          )
                        else
                          const Text(
                            "Bu randevu için işlem yapılamaz.",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.orange;
    if (status == 'Completed') color = Colors.green;
    if (status == 'Cancelled') color = Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
