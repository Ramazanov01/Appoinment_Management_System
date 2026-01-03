import 'package:flutter/material.dart';

// Import screens
import 'screens/authentication/login_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uygulama Adı',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),

      // Change this to test different screens:
      // const LoginScreen() - for login screen
      // const AdminScreen() - for admin screen
      // const DashboardScreen() - for manager screen
      home: const LoginScreen(), // Start with login screen
    );
  }
}

// lib/main.dart (GEÇİCİ BASİT SÜRÜM)
// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: Scaffold(
//         body: Center(
//           child: Text('Uygulama Çalışıyor mu?'), // Bu yazıyı görmeliyiz.
//         ),
//       ),
//     );
//   }
// }
// ------------------------------------