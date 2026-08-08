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
  final int userXp;

  const MainWrapper({
    super.key,
    required this.userName,
    required this.userAvatar,
    required this.userXp,
  });

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;
  late String _currentUserName;
  late String _currentUserAvatar;
  late int _currentUserXp;

  @override
  void initState() {
    super.initState();
    _currentUserName = widget.userName;
    _currentUserAvatar = widget.userAvatar;
    _currentUserXp = widget.userXp;
  }

  Future<void> _updateUserPrefs(String newName, String newAvatar) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newName);
    await prefs.setString('user_avatar', newAvatar);
    setState(() {
      _currentUserName = newName;
      _currentUserAvatar = newAvatar;
    });
  }

  // === XP GÜNCELLEME VE HAFIZAYA KAYDETME FONKSİYONU ===
  Future<void> _updateUserXp(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    int newXp = _currentUserXp + amount;

    if (newXp < 0) newXp = 0; // Eksi level olmasını engeller

    await prefs.setInt('user_xp', newXp);
    setState(() {
      _currentUserXp = newXp; // Arayüzü tetikler
    });
  }

  // === TÜM UYGULAMANIN GÖREV VE XP KONTROL MERKEZİ ===
  void _toggleTask(String taskId) {
    final taskIndex = globalTasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      bool wasCompleted = globalTasks[taskIndex].isCompleted;

      setState(() {
        globalTasks[taskIndex].isCompleted = !wasCompleted;
      });

      // XP'yi LevelSystem sınıfındaki kurallara göre ekle veya çıkar
      if (!wasCompleted) {
        _updateUserXp(LevelSystem.taskCompletedXp);
      } else {
        _updateUserXp(-LevelSystem.taskCompletedXp);
      }
    }
  }

  List<TaskItem> globalTasks = [
    TaskItem(id: '1', title: "Flutter arayüzünü bitir", date: DateTime.now()),
    TaskItem(
      id: '2',
      title: "İtme (Push) antrenmanı yap",
      date: DateTime.now().add(const Duration(days: 1)),
    ),
    TaskItem(
      id: '3',
      title: "Espresso demle",
      date: DateTime.now().subtract(const Duration(days: 1)),
      isCompleted: true,
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
        onUserPrefsChanged: _updateUserPrefs,
        onUserXpGained: _updateUserXp,
        onTaskToggled: _toggleTask,
      ),
      TasksView(
        tasks: globalTasks,
        onTasksUpdated: () => setState(() {}),
        onTaskToggled: _toggleTask, // TasksView'a XP tetikleyicisini yolladık
      ),
      JournalView(
        onUserXpGained:
            _updateUserXp, // JournalView'a XP tetikleyicisini yolladık
      ),
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
            child: IndexedStack(index: _selectedIndex, children: pages),
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
            setState(() {
              _selectedIndex = index;
            });
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
