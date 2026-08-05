import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_item.dart';
import 'home_view.dart';
import 'tasks_view.dart';
import 'journal_view.dart';

class MainWrapper extends StatefulWidget {
  final String userName;
  const MainWrapper({super.key, required this.userName});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;
  late String _currentUserName;

  @override
  void initState() {
    super.initState();
    _currentUserName = widget.userName;
  }

  // İsmi güncelleyen ve hafızaya kaydeden fonksiyon
  Future<void> _updateUserName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newName);
    setState(() {
      _currentUserName = newName;
    });
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
        onUserNameChanged:
            _updateUserName, // Ayarlar için fonksiyonu iletiyoruz
      ),
      TasksView(tasks: globalTasks, onTasksUpdated: () => setState(() {})),
      const JournalView(),
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
