import 'package:flutter/material.dart';

// 1. Giriş ekranı dosyanızı buraya import edin
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

      // 2. Uygulamanın başlayacağı ana ekranı (Giriş Ekranı) buraya koyun
      home: const LoginScreen(),
    );
  }
}
