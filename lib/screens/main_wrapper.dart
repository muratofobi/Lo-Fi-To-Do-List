import 'package:flutter/material.dart';
import '../models/task_item.dart';
import 'home_view.dart';
import 'tasks_view.dart';
import 'journal_view.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

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
    // Sayfaları bir kez oluşturuyoruz
    final List<Widget> pages = [
      HomeView(tasks: globalTasks),
      TasksView(tasks: globalTasks, onTasksUpdated: () => setState(() {})),
      const JournalView(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Arka plan resmi
          Positioned.fill(
            child: Image.asset(
              'img/background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: const Color(0xFF141526)),
            ),
          ),
          // Karartma katmanı
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          // ÇÖZÜM BURADA: IndexedStack sayesinde sayfalar arka planda hayatta kalır!
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
