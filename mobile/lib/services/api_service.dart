import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_service.dart';

class ApiService {
  // Get headers with authentication token

  static Future<Map<String, String>> _getHeaders({bool includeAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    
    if (includeAuth) {
      final token = await StorageService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }
  
  // Login
  /// POST /api/auth/login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        // Save token and user data
        final token = responseData['data']['token'];
        final user = responseData['data']['user'];
        
        await StorageService.saveToken(token);
        await StorageService.saveUserData(user);
        
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }
  
  // Signup
  /// POST /api/auth/signup
  static Future<Map<String, dynamic>> signup(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.signup}'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
        }),
      );
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 201 && responseData['success'] == true) {
        // Save token and user data
        final token = responseData['data']['token'];
        final user = responseData['data']['user'];
        
        await StorageService.saveToken(token);
        await StorageService.saveUserData(user);
        
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Signup failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }
  
  // Get appointments
  /// GET /api/appointments
  static Future<Map<String, dynamic>> getAppointments() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.appointments}'),
        headers: await _getHeaders(includeAuth: true),
      );
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'data': responseData['data'] ?? {'appointments': []},
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch appointments',
          'data': {'appointments': []},
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
        'data': [],
      };
    }
  }
  
  // Create appointment
  /// POST /api/appointments
  static Future<Map<String, dynamic>> createAppointment(Map<String, dynamic> appointmentData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.appointments}'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode(appointmentData),
      );
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 201 && responseData['success'] == true) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to create appointment',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }
  
  // Get current user (me)
  /// GET /api/user/profile
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getMe}'),
        headers: await _getHeaders(includeAuth: true),
      );
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        // Update stored user data
        final user = responseData['data']['user'];
        await StorageService.saveUserData(user);
        
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch user',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  // Get all providers (doctors)
  /// GET /api/appointments/doctors/all
static Future<List<Map<String, dynamic>>> getAllProviders() async {
  try {
    // Query parameter göndermeden istek atıyoruz ki tüm listeyi versin
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/appointments/doctors/all'), 
      headers: await _getHeaders(includeAuth: true),
    );

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200 && responseData['success'] == true) {
      // Backend'in List<Map> dönmesi gerekir: [{"full_name": "...", "specialization": "..."}]
      return List<Map<String, dynamic>>.from(responseData['data']);
    }
    return [];
  } catch (e) {
    print('Providers error: $e');
    return [];
  }
}

  // Get doctors by service type
  /// GET /api/appointments/doctors?service=ServiceType
static Future<List<String>> getDoctorsByService(String serviceType) async {
    try {
      // API URL'ine query parameter ekliyoruz (Örn: /doctors?service=Therapy)
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/appointments/doctors?service=$serviceType'),
        headers: await _getHeaders(includeAuth: true),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Backend'den gelen verinin List<String> olduğunu varsayıyoruz
        // Eğer backend tam obje dönüyorsa: responseData['data'].map((doc) => doc['name']).toList() şeklinde güncellenmeli
        return List<String>.from(responseData['data']);
      } else {
        // Hata durumunda boş liste dönüyoruz
        return [];
      }
    } catch (e) {
      print('Error fetching doctors: $e');
      return [];
    }
  }
  
  // Get user profile
  /// GET /api/user/profile
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userProfile}'),
        headers: await _getHeaders(includeAuth: true),
      );
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }
  
  // Update user profile
  /// PUT /api/user/profile
  static Future<Map<String, dynamic>> updateProfile(
    String firstName,
    String lastName,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userProfile}'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
        }),
      );
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  /// Doktorun bugünkü randevularını ve sayılarını getirir
  /// GET /api/appointments/doctor/today
  static Future<Map<String, dynamic>> getTodaysDoctorAppointments() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/appointments/doctor/today'),
        headers: await _getHeaders(includeAuth: true),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'appointments': responseData['appointments'] ?? [],
          'count': responseData['count'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch today\'s appointments',
          'appointments': [],
        };
      }
    } catch (e) {
      print('Error fetching doctor dashboard: $e');
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
        'appointments': [],
      };
    }
  }

  /// Doktorun tüm randevularını (Takvim yönetimi için) getirir
  /// GET /api/appointments/doctor/all
  static Future<Map<String, dynamic>> getDoctorSchedule() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/appointments/doctor/all'),
        headers: await _getHeaders(includeAuth: true),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch schedule',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }
  /// Doktorun katılım oranını getirir
  /// GET /api/appointments/doctor/attendance-rate
  static Future<double> getAttendanceRate() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/appointments/doctor/attendance-rate'),
        headers: await _getHeaders(includeAuth: true),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        // Backend'den string veya double gelebilir, güvenli dönüşüm yapıyoruz
        return double.parse(responseData['attendanceRate'].toString());
      }
      return 0.0;
    } catch (e) {
      print('Attendance Rate error: $e');
      return 0.0;
    }
  }

  /// Yeni bir yönetici (doktor) oluşturur
  /// POST /api/admin/create-manager
  static Future<Map<String, dynamic>> createManager(
    Map<String, dynamic> managerData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}/admin/create-manager',
        ), // Route adınızı kontrol edin
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode(managerData),
      );

      final responseData = jsonDecode(response.body);

      // Backend 201 Created döndürüyor
      if (response.statusCode == 201 && responseData['success'] == true) {
        return {'success': true, 'data': responseData['data']};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to create manager',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }
  /// Admin paneli için istatistikleri getirir
  /// GET /api/admin/stats
  static Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/stats'),
        headers: await _getHeaders(includeAuth: true), // JWT Token içerir
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Backend'den gelen 'data' objesini (totalUsers, totalManagers vb.) doğrudan dönüyoruz
        return {'success': true, 'data': responseData['data']};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'İstatistikler alınamadı',
        };
      }
    } catch (e) {
      print('Admin Stats Error: $e');
      return {'success': false, 'message': 'Bağlantı hatası oluştu'};
    }
  }

  /// Tüm Kullanıcılara Toplu Mail Gönder
  /// POST /api/admin/send-bulk-email
  static Future<Map<String, dynamic>> sendBulkEmail(String message) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/send-bulk-email'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode({'message': message}),
      );

      final responseData = jsonDecode(response.body);
      return {
        'success':
            response.statusCode == 200 && responseData['success'] == true,
        'message': responseData['message'] ?? 'Mesaj gönderilemedi',
      };
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  /// Tüm Yöneticilere (Doktorlara) Toplu Mail Gönder
  /// POST /api/admin/send-manager-email
  static Future<Map<String, dynamic>> sendManagerBulkEmail(
    String message,
  ) async {
    try {
      // final response = await http.post(
      //   Uri.parse('${ApiConfig.baseUrl}/admin/send-manager-email'),
      //   headers: await _getHeaders(includeAuth: true),
      // );
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/send-manager-email'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode({'message': message}),
      );
      final responseData = jsonDecode(response.body);
      return {
        'success':
            response.statusCode == 200 && responseData['success'] == true,
        'message': responseData['message'] ?? 'Mesaj gönderilemedi',
      };
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  /// Tüm yöneticileri (doktorları) getirir
  /// GET /api/admin/managers
  static Future<Map<String, dynamic>> getAllManagers() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/managers'),
        headers: await _getHeaders(includeAuth: true),
      );
      final responseData = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'data': responseData['data'] ?? [],
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Belirli bir yöneticiyi (doktoru) siler
  /// DELETE /api/admin/managers/:id
  static Future<bool> deleteManager(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/admin/managers/$id'),
        headers: await _getHeaders(includeAuth: true),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Randevu durumunu günceller (örneğin: "completed", "canceled")
  /// PUT /api/appointments/doctor/:appointmentId
  static Future<Map<String, dynamic>> updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/appointments/doctor/$appointmentId'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode({'status': status}),
      );

      final responseData = jsonDecode(response.body);
      return {
        'success':
            response.statusCode == 200 && responseData['success'] == true,
        'message': responseData['message'] ?? 'İşlem başarısız',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}


