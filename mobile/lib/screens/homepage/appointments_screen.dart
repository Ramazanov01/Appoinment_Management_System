import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  // 1. Veri Durumu ve Liste
  bool _isLoading = true;
  List<Map<String, dynamic>> _appointments = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAppointments(); // Ekran açıldığında veriyi çekmeyi başlat
  }

  // 2. Backend'den Randevuları Çekme Fonksiyonu
  Future<void> _fetchAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.getAppointments();

      if (result['success'] == true) {
        final appointmentsData = result['data'];
        List<Map<String, dynamic>> appointments = [];
        
        if (appointmentsData is Map && appointmentsData['appointments'] != null) {
          appointments = List<Map<String, dynamic>>.from(appointmentsData['appointments']);
        } else if (appointmentsData is List) {
          appointments = List<Map<String, dynamic>>.from(appointmentsData);
        }

        if (mounted) {
          setState(() {
            _appointments = appointments;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = result['message'] ?? 'Failed to fetch appointments';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Bağlantı hatası: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Connection error: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  // Format date for display
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Date not set';
    
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = date.difference(now).inDays;
      
      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Tomorrow';
      } else if (difference == -1) {
        return 'Yesterday';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  // Format time for display
  String _formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return '';
    return timeString;
  }

  // Randevu öğesi oluşturan yardımcı widget
  Widget _buildAppointmentItem(Map<String, dynamic> appointment) {
    final status = appointment['status']?.toString() ?? 'Pending';
    final doctor = appointment['doctor']?.toString() ?? 'Doctor not specified';
    final service = appointment['service']?.toString() ?? 'Service not specified';
    final date = appointment['date']?.toString();
    final time = appointment['time']?.toString();
    
    Color statusColor;
    Color containerColor;

    switch (status) {
      case 'Confirmed':
        statusColor = Colors.green;
        containerColor = Colors.green.shade50;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        containerColor = Colors.orange.shade50;
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        containerColor = Colors.red.shade50;
        break;
      default:
        statusColor = Colors.grey;
        containerColor = Colors.grey.shade50;
    }

    final dateTimeString = '${_formatDate(date)}${time != null ? ', ${_formatTime(time)}' : ''}';

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: containerColor,
      child: ListTile(
        leading: Icon(Icons.calendar_month, color: statusColor),
        title: Text(
          '$doctor ($service)',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(dateTimeString),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Randevularım'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAppointments,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchAppointments,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _appointments.isEmpty
          ? const Center(child: Text('Henüz planlanmış bir randevunuz yok.'))
          : RefreshIndicator(
              onRefresh: _fetchAppointments,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _appointments.length,
                itemBuilder: (context, index) {
                  return _buildAppointmentItem(_appointments[index]);
                },
              ),
            ),
    );
  }
}
