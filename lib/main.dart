import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_wrapper.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  // Hafızada daha önce kayıtlı bir isim var mı kontrol et
  final prefs = await SharedPreferences.getInstance();
  final String? savedName = prefs.getString('user_name');

  runApp(LoFiToDoApp(initialUserName: savedName));
}

class LoFiToDoApp extends StatelessWidget {
  final String? initialUserName;
  const LoFiToDoApp({super.key, this.initialUserName});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chill To-Do',
      theme: ThemeData(
        fontFamily: 'Courier',
        scaffoldBackgroundColor: const Color(0xFF141526),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE5A96A),
          surface: Color(0xFF282A45),
        ),
      ),
      // Eğer isim kayıtlı değilse NamePromptScreen'e yönlendir, kayıtlıysa MainWrapper'a git
      home: initialUserName == null
          ? const NamePromptScreen()
          : MainWrapper(userName: initialUserName!),
    );
  }
}

// --- İLK AÇILIŞTA İSİM SORMA EKRANI ---
class NamePromptScreen extends StatefulWidget {
  const NamePromptScreen({super.key});

  @override
  State<NamePromptScreen> createState() => _NamePromptScreenState();
}

class _NamePromptScreenState extends State<NamePromptScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading =
      false; // Çift tıklamayı ve donmayı önlemek için yüklenme bayrağı

  Future<void> _saveNameAndProceed() async {
    if (_isLoading) return; // Zaten işlem sürüyorsa tekrar tetiklenme

    setState(() {
      _isLoading = true;
    });

    String name = _nameController.text.trim();
    if (name.isEmpty) name = "Gezgin";

    try {
      // 1. Klavyeyi ekrandan güvenli bir şekilde indir
      FocusScope.of(context).unfocus();

      // 2. SharedPreferences kaydını yap
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);

      // Kısa bir gecikme ekleyerek render motorunun nefes almasını sağla
      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;

      // 3. Ana sayfaya güvenli geçiş
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainWrapper(userName: name)),
      );
    } catch (e) {
      // Hata durumunda buton kilitlenmesini aç
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF282A45),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE5A96A),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Hoş Geldin!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Sana nasıl hitap etmemi istersin?",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      decoration: const InputDecoration(
                        hintText: "...",
                        hintStyle: TextStyle(color: Colors.white38),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF535882)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE5A96A)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE5A96A),
                          foregroundColor: const Color(0xFF282A45),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _isLoading ? null : _saveNameAndProceed,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF282A45),
                                ),
                              )
                            : const Text(
                                "Devam Et",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
