import 'package:flutter/material.dart';
import 'signup_screen.dart';
import '../homepage/user_portal_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //  1. Durum Değişkeni: Şifrenin gizli (true) veya açık (false) olduğunu tutar.
  bool _isPasswordVisible = false;

  //  Önemli: Controller'ları widget yok edildiğinde temizlemeliyiz.
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  Future<void> _login() async {
    // 1. Controller'lardan veriyi alın
    final String email = _emailController.text;
    final String password = _passwordController.text;

    // Kullanıcının girdiği veriler
    print('Giriş Yapılmaya Çalışılıyor...');
    print('E-posta: $email');
    print('Şifre: $password');

    Navigator.pushReplacement(
      // ⭐️ pushReplacement kullanın
      context,
      MaterialPageRoute(builder: (context) => const UserPortalScreen()),
    );
    // 2. HTTP İsteği (Backend'e Gönderme) - Örnek Kod
    /*
  // Bu kısım için 'http' paketini pubspec.yaml'a eklemelisiniz.
  
  try {
    final response = await http.post(
      Uri.parse('https://sizin-api-adresiniz.com/api/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Başarılı giriş: Ana sayfaya yönlendir
      print('Giriş Başarılı!');
      // _clearFormFields();
    } else {
      // Başarısız giriş: Hata mesajı göster
      print('Giriş Başarısız! Hata Kodu: ${response.statusCode}');
      // _clearFormFields();
    }
  } catch (e) {
    print('İstek hatası: $e');
    // _clearFormFields();
  }
  */
  }

  void _clearFormFields() {
    // setState kullanmaya gerek yok, çünkü controller'lar metodu çağırdığında
    // Flutter ilgili TextFormField'u otomatik olarak günceller.
    _emailController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    // Ekran boyutunu alarak duyarlı tasarım için kullanabiliriz
    //final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        // Uygulamanın adını başlıkta gösterebiliriz
        title: const Text('Welcome'),
        backgroundColor: const Color.fromARGB(255, 169, 213, 106),
        centerTitle: true,
        elevation: 1, // AppBar gölgesini kaldırır
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            //1. Başlık ve Açıklama
            Text(
              "Enter to Your Account",
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.normal),
            ),

            const SizedBox(height: 30),

            // 2. Form Alanları (E-posta ve Şifre)
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'G-mail Adres',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              //obscureText: true, // Şifreyi gizler
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
                //suffixIcon: Icon(Icons.visibility_off),
                suffixIcon: IconButton(
                  icon: Icon(
                    // Duruma göre ikon değiştirme
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    // İkonun rengini de duruma göre değiştirebiliriz
                    color: _isPasswordVisible ? Colors.blue : Colors.grey,
                  ),
                  onPressed: () {
                    //  4. Tıklandığında Durumu Tersine Çevirme ve Ekranı Yenileme
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 8),

            // 3. Şifremi Unuttum Butonu
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Şifremi Unuttum Sayfasına yönlendirme eklenecek
                  //print('Şifremi Unuttum Tıklandı');
                },
                child: const Text(
                  'Şifremi Unuttum?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 4. Giriş Butonu
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              //onPressed: _login,
              onPressed: () {
                // ⭐️ 1. İşlem: Giriş (Login) işlemini başlat
                _login();

                // ⭐️ 2. İşlem: Formu temizle (login fonksiyonu içinde yapılması daha temizdir,
                //             ama test için buraya ekleyebiliriz)
                _clearFormFields();
              },
              child: const Text('Giriş Yap', style: TextStyle(fontSize: 18)),
            ),

            const SizedBox(height: 30),

            // 5. VEYA Ayracı
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'VEYA',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: 30),

            // 6. Google ile Giriş
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide(color: Colors.grey.shade400),
              ),
              onPressed: () {
                /* TODO: Google ile Giriş Mantığı buraya eklenecek */
                //print('Google ile Giriş Tıklandı');
              },
              icon: Image.asset(
                'assets/google_logo.png', // Buraya kendi Google logo resminizi ekleyin
                height: 24,
              ),
              label: const Text(
                'Google ile Devam Et',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),

            const SizedBox(height: 80),

            // 7. Kayıt Ol (Sign Up) Linki
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Bir hesabın yok mu?",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                TextButton(
                  onPressed: () {
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SignUpScreen(), // Yönlendirilecek sayfa
                      ),
                    );

                    //print('Kayıt Ol Tıklandı');
                  },
                  child: const Text(
                    'Kayıt Ol',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
