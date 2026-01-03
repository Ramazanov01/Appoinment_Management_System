import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

// Basit bir model: Sadece saat ve müsaitlik durumu
class AvailableTime {
  final String time;
  final bool available;

  AvailableTime({required this.time, required this.available});

  factory AvailableTime.fromJson(Map<String, dynamic> json) {
    return AvailableTime(
      time: json['time'] ?? '',
      available: json['available'] ?? false,
    );
  }
}

class TimeSlotsService {
  static String get baseUrl => '${ApiConfig.baseUrl}/time-slots';

  // Yeni mantık: Doktor ve tarihe göre müsait saatleri getirir
  // GET /api/time-slots/available-hours?date=2025-12-28&doctor=Dr. Ahmet
  static Future<List<AvailableTime>> getFilteredAvailableSlots({
    required String date,
    required String doctor,
  }) async {
    try {
      // İstek: api/time-slots/available-hours?date=2025-12-28&doctor=Dr. Ahmet
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/available-hours?date=$date&doctor=${Uri.encodeComponent(doctor)}',
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success']) {
          final List<dynamic> data = json['data'] ?? [];
          return data.map((t) => AvailableTime.fromJson(t)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting available hours: $e');
      return [];
    }
  }
}
