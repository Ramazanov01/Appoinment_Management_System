import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Import'larınızı kontrol edin. Eğer diğer dosyalardan birine yönlendirme yapılacaksa,
// ilgili import'ları eklemelisiniz (örneğin LoginScreen).

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // ⭐️ 1. Controller'lar: Formdaki tüm girdileri yönetmek için
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // ⭐️ 2. Durum Değişkenleri: Şifre gizleme/gösterme için
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // ⭐️ 3. Form Anahtarı (Key): Doğrulama (Validation) için gereklidir.
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() {
    // 1. Tüm form alanlarının geçerli (valid) olup olmadığını kontrol eder
    if (_formKey.currentState!.validate()) {
      // Eğer geçerliyse, formdaki verileri controller'lardan çek
      final name = _nameController.text;
      final surname = _surnameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;

      // ⭐️ 2. Verileri terminalde göster (Başarılı veri toplama)
      print('✅ Form Doğrulandı!');
      print('-----------------------------------------');
      print('Adı: $name');
      print('Soyadı: $surname');
      print('E-posta: $email');
      print('Şifre: $password (Gizlendi)');
      print('-----------------------------------------');

      // ⭐️ 3. Backend'e Gönderme (HTTP İsteği) KISMI YORUMA ALINMIŞTIR!

      /* try {
      final response = await http.post(
        Uri.parse('https://sizin-kayit-api-adresiniz.com/api/signup'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'surname': surname,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) { // 201 Created (Başarılı Kayıt)
        print('Kayıt Başarılı!');
        // TODO: Başarılı Kayıt sonrası Login ekranına yönlendirme
      } else {
        print('Kayıt Başarısız! Hata Kodu: ${response.statusCode}');
      }
    } catch (e) {
      print('İstek hatası veya bağlantı sorunu: $e');
    }
    */

      // İşlem (simülasyon) bittikten sonra formu temizle
      _clearFormFields();
    } else {
      // Doğrulama başarısız olursa
      print('❌ Formda hatalar var. Lütfen gerekli alanları doldurun.');
    }
  }

  void _clearFormFields() {
    _nameController.clear();
    _surnameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  // ⭐️ 5. E-posta Formatı Doğrulama Fonksiyonu
  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen e-posta adresinizi girin.';
    }
    // Basit bir e-posta formatı kontrolü
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Lütfen geçerli bir e-posta adresi girin.';
    }
    return null; // Geçerli (valid)
  }

  // ⭐️ 6. Şifre Tekrarı Doğrulama Fonksiyonu
  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen şifreyi tekrar girin.';
    }
    if (value != _passwordController.text) {
      return 'Şifreler eşleşmiyor.';
    }
    return null; // Geçerli (valid)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          // Form doğrulama için Form widget'ı ile sarmalıyoruz
          key: _formKey, // Form anahtarını bağlıyoruz
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Başlık
              Text(
                "Hesap Oluştur",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // İsim ve Soyisim Alanları (Yatayda yan yana düzenlemek için Row kullanıldı)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'İsim',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'İsim gerekli.' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _surnameController,
                      decoration: const InputDecoration(
                        labelText: 'Soyisim',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Soyisim gerekli.' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // E-posta Alanı (Doğrulama eklendi)
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta Adresi',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _emailValidator, // ⭐️ E-posta formatı kontrolü
              ),
              const SizedBox(height: 16),

              // Şifre Alanı (Gizleme/Gösterme eklendi)
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: _isPasswordVisible ? Colors.blue : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.length < 6 ? 'Şifre en az 6 karakter olmalı.' : null,
              ),
              const SizedBox(height: 16),

              // Şifre Tekrarı Alanı (Gizleme/Gösterme ve Eşleşme Kontrolü eklendi)
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Şifreyi Tekrar Girin',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: _isConfirmPasswordVisible
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator:
                    _confirmPasswordValidator, // ⭐️ Şifre eşleşme kontrolü
              ),
              const SizedBox(height: 30),

              // Kayıt Butonu
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  _signUp();
                  Navigator.pop(context);

                }, // Kayıt ol fonksiyonu
                child: const Text('Kayıt Ol', style: TextStyle(fontSize: 18)),
              ),

              const SizedBox(height: 80),

              // Giriş Sayfasına Dönüş Linki
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Zaten bir hesabın var mı?",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  TextButton(
                    onPressed: () {
                      // Kayıt ekranından çıkıp bir önceki (Login) ekrana döner
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Giriş Yap',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
