class ApiConfig {
  // For Android emulator, use 10.0.2.2 instead of localhost
  // For physical device, use your computer's IP address (e.g., 192.168.1.100)
  // For iOS simulator, use localhost
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  
  // Alternative URLs (uncomment the one you need):
  // static const String baseUrl = 'http://localhost:5000/api'; // iOS Simulator
  // static const String baseUrl = 'http://192.168.1.100:5000/api'; // Physical device (replace with your IP)
  
  // API Endpoints
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String getMe = '/auth/me';
  static const String userProfile = '/user/profile';
  static const String appointments = '/appointments';
  static const String appointmentById = '/appointments';
  static const String doctors = '/appointments/doctors';
}

