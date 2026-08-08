import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_wrapper.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  // Hafızada daha önce kayıtlı isim, avatar ve XP var mı kontrol et
  final prefs = await SharedPreferences.getInstance();
  final String? savedName = prefs.getString('user_name');
  final String? savedAvatar = prefs.getString('user_avatar');
  final int? savedXp = prefs.getInt('user_xp'); // XP verisini çekiyoruz

  runApp(
    LoFiToDoApp(
      initialUserName: savedName,
      initialUserAvatar: savedAvatar ?? 'Icon1',
      initialUserXp: savedXp ?? 0, // Eğer kayıtlı XP yoksa 0'dan başlar
    ),
  );
}

class LoFiToDoApp extends StatelessWidget {
  final String? initialUserName;
  final String initialUserAvatar;
  final int initialUserXp; // XP değişkeni eklendi

  const LoFiToDoApp({
    super.key,
    this.initialUserName,
    required this.initialUserAvatar,
    required this.initialUserXp,
  });

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
      home: initialUserName == null
          ? const NamePromptScreen()
          : MainWrapper(
              userName: initialUserName!,
              userAvatar: initialUserAvatar,
              userXp: initialUserXp, // Veriyi Wrapper'a iletiyoruz
            ),
    );
  }
}

// --- İLK AÇILIŞTA İSİM VE AVATAR SORMA EKRANI ---
class NamePromptScreen extends StatefulWidget {
  const NamePromptScreen({super.key});

  @override
  State<NamePromptScreen> createState() => _NamePromptScreenState();
}

class _NamePromptScreenState extends State<NamePromptScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  String _selectedAvatar = 'Icon1';

  Future<void> _saveNameAndProceed() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    String name = _nameController.text.trim();
    if (name.isEmpty) name = "Gezgin";

    try {
      FocusScope.of(context).unfocus();

      // İsim, Avatar ve 0 XP'yi başlangıç olarak kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);
      await prefs.setString('user_avatar', _selectedAvatar);
      await prefs.setInt('user_xp', 0); // Başlangıç seviyesi için 0 XP

      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainWrapper(
            userName: name,
            userAvatar: _selectedAvatar,
            userXp: 0,
          ),
        ),
      );
    } catch (e) {
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
                      "Selam!",
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
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      maxLength: 16,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      decoration: const InputDecoration(
                        hintText: "İsmini gir...",
                        hintStyle: TextStyle(color: Colors.white38),
                        counterText: "",
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF535882)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE5A96A)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Avatarını Seç",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 160,
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: 48,
                        itemBuilder: (context, index) {
                          String iconName = 'Icon${index + 1}';
                          bool isSelected = _selectedAvatar == iconName;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedAvatar = iconName;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFE5A96A)
                                    : const Color(0xFF141526),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF535882),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.asset(
                                  'img/Icons/$iconName.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        Icons.person,
                                        color: isSelected
                                            ? const Color(0xFF282A45)
                                            : Colors.white54,
                                        size: 20,
                                      ),
                                ),
                              ),
                            ),
                          );
                        },
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
