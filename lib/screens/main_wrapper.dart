import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_item.dart';
import '../utils/level_system.dart';
import 'home_view.dart';
import 'tasks_view.dart';
import 'journal_view.dart';

class MainWrapper extends StatefulWidget {
  final String userName;
  final String userAvatar;
  final Map<String, int> allAvatarXps; // Tüm karakterlerin deposu

  const MainWrapper({
    super.key,
    required this.userName,
    required this.userAvatar,
    required this.allAvatarXps,
  });

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;
  late String _currentUserName;
  late String _currentUserAvatar;

  late Map<String, int> _allAvatarXps; // Ekranda anlık güncellenen depo
  late int _currentUserXp; // Ekranda görünen aktif karakterin XP'si

  // YENİ: Sayfa kaydırma animasyonlarını yönetecek kontrolcü
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentUserName = widget.userName;
    _currentUserAvatar = widget.userAvatar;
    _allAvatarXps = Map.from(widget.allAvatarXps);
    _currentUserXp = _allAvatarXps[_currentUserAvatar] ?? 0;

    // YENİ: Sayfa kontrolcüsünü seçili indeks ile başlatıyoruz
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    // YENİ: Sayfa kapatıldığında hafıza sızıntısı olmaması için controller'ı siliyoruz
    _pageController.dispose();
    super.dispose();
  }

  // === KARAKTER DEĞİŞTİRİLDİĞİNDE ===
  Future<void> _updateUserPrefs(String newName, String newAvatar) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newName);
    await prefs.setString('user_avatar', newAvatar);

    setState(() {
      _currentUserName = newName;
      _currentUserAvatar = newAvatar;
      // Yeni karaktere geçtiğinde o karakterin XP'sini yükler
      _currentUserXp = _allAvatarXps[newAvatar] ?? 0;
    });
  }

  // === AKTİF KARAKTERE XP EKLEME FONKSİYONU ===
  Future<void> _updateUserXp(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    int currentXp = _allAvatarXps[_currentUserAvatar] ?? 0;
    int newXp = currentXp + amount;

    if (newXp < 0) newXp = 0;

    // Sadece aktif olan avatarın hafızasına kaydeder (Örn: xp_Icon12)
    await prefs.setInt('xp_$_currentUserAvatar', newXp);

    setState(() {
      _allAvatarXps[_currentUserAvatar] = newXp;
      _currentUserXp = newXp;
    });
  }

  void _toggleTask(String taskId) {
    final taskIndex = globalTasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      bool wasCompleted = globalTasks[taskIndex].isCompleted;

      setState(() {
        globalTasks[taskIndex].isCompleted = !wasCompleted;
      });

      if (!wasCompleted) {
        _updateUserXp(LevelSystem.taskCompletedXp);
      } else {
        _updateUserXp(-LevelSystem.taskCompletedXp);
      }
    }
  }

  List<TaskItem> globalTasks = [
    TaskItem(
      id: '1',
      title: "Bizi Google Play'de değerlendir",
      date: DateTime.now(),
    ),
    TaskItem(
      id: '2',
      title: "Zamanlayıcımızı kullanarak odaklan",
      date: DateTime.now(),
    ),
    TaskItem(
      id: '3',
      title: "Avatarlarının seviyesini yükselt",
      date: DateTime.now(),
    ),
    TaskItem(
      id: '4',
      title: "Pozitif kal ve sevdiklerine onları sevdiğini söyle :)",
      date: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeView(
        tasks: globalTasks,
        userName: _currentUserName,
        userAvatar: _currentUserAvatar,
        userXp: _currentUserXp,
        allAvatarXps:
            _allAvatarXps, // Arayüzde listelemek için tümünü yolluyoruz
        onUserPrefsChanged: _updateUserPrefs,
        onUserXpGained: _updateUserXp,
        onTaskToggled: _toggleTask,
      ),
      TasksView(
        tasks: globalTasks,
        onTasksUpdated: () => setState(() {}),
        onTaskToggled: _toggleTask,
      ),
      JournalView(onUserXpGained: _updateUserXp),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'img/background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: const Color(0xFF141526)),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          SafeArea(
            // YENİ: IndexedStack silindi, yerine kaydırmalı PageView eklendi
            child: PageView(
              controller: _pageController,
              physics:
                  const BouncingScrollPhysics(), // Ekranın kenarında esneme efekti yapar
              onPageChanged: (index) {
                // Ekran kaydırıldığında alt menünün indeksini de günceller
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF1E1F36),
          elevation: 10,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFE5A96A),
          unselectedItemColor: Colors.white54,
          currentIndex: _selectedIndex,
          onTap: (index) {
            // YENİ: Alt menüden tıklandığında sayfaya yumuşakça kayarak geçiş yapar
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Ev'),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Görevler',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Günlük'),
          ],
        ),
      ),
    );
  }
}
