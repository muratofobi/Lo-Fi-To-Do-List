import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import '../models/task_item.dart';
import '../widgets/retro_card.dart';
import '../services/notification_service.dart';

class HomeView extends StatefulWidget {
  final List<TaskItem> tasks;
  final String userName;
  final Function(String) onUserNameChanged; // İsim değişikliği callback'i

  const HomeView({
    super.key,
    required this.tasks,
    required this.userName,
    required this.onUserNameChanged,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Timer _realTimeTimer;
  String _currentTime = "";

  Timer? _countdownTimer;
  int _timerDurationInSeconds = 25 * 60;
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  bool _isSoundEnabled = true;

  @override
  void initState() {
    super.initState();
    _updateTime();

    _realTimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    });
  }

  void _startTimer() {
    if (_remainingSeconds <= 0) return;
    if (_countdownTimer != null) _countdownTimer!.cancel();
    setState(() => _isRunning = true);

    if (_isSoundEnabled) {
      NotificationService().scheduleTimerNotification(_remainingSeconds);
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        setState(() => _isRunning = false);
      }
    });
  }

  void _pauseTimer() {
    _countdownTimer?.cancel();
    setState(() => _isRunning = false);
    NotificationService().cancelNotification();
  }

  void _resetTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _timerDurationInSeconds;
    });
    NotificationService().cancelNotification();
  }

  // --- AYARLAR MENÜSÜ (BOTTOM SHEET) ---
  void _showSettingsModal() {
    final TextEditingController nameEditController = TextEditingController(
      text: widget.userName,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF282A45),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Color(0xFFE5A96A), width: 1.5),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "⚙️ Ayarlar",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Courier',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: Color(0xFF535882), thickness: 1),
              const SizedBox(height: 10),
              const Text(
                "Kullanıcı Adını Değiştir",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameEditController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: "Yeni adını gir...",
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
                  onPressed: () {
                    String newName = nameEditController.text.trim();
                    if (newName.isNotEmpty) {
                      widget.onUserNameChanged(newName); // İsmi güncelle
                    }
                    Navigator.pop(context); // Menüyü kapat
                  },
                  child: const Text(
                    "Kaydet",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  void _showSetTimerDialog() {
    int tempSeconds = _timerDurationInSeconds;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF282A45),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "İptal",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                    const Text(
                      "Süreyi Belirle",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Courier',
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _timerDurationInSeconds = tempSeconds;
                          _remainingSeconds = _timerDurationInSeconds;
                          _isRunning = false;
                          _countdownTimer?.cancel();
                        });
                        NotificationService().cancelNotification();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Ayarla",
                        style: TextStyle(
                          color: Color(0xFFE5A96A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFF535882), thickness: 1),
              Expanded(
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      pickerTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontFamily: 'Courier',
                      ),
                    ),
                  ),
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.ms,
                    initialTimerDuration: Duration(
                      seconds: _timerDurationInSeconds,
                    ),
                    onTimerDurationChanged: (Duration newDuration) {
                      tempSeconds = newDuration.inSeconds;
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _realTimeTimer.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int completedTasks = widget.tasks.where((t) => t.isCompleted).length;

    String minutesStr = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    String secondsStr = (_remainingSeconds % 60).toString().padLeft(2, '0');

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          RetroCard(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFE5A96A),
                  radius: 20,
                  child: Icon(Icons.person, color: Color(0xFF282A45)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hoş Geldin, ${widget.userName}!",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.star, color: Color(0xFFE5A96A), size: 14),
                        SizedBox(width: 4),
                        Text(
                          "Seviye 5",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                // AYARLAR BUTONUNA TIKLAMA ÖZELLİĞİ EKLENDİ
                GestureDetector(
                  onTap: _showSettingsModal,
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.settings, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          RetroCard(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              children: [
                Text(
                  _currentTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4.0,
                    shadows: [
                      Shadow(
                        color: Colors.black87,
                        blurRadius: 10,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const Text(
                  "Şu Anki Saat",
                  style: TextStyle(
                    color: Color(0xFFE5A96A),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          RetroCard(
            width: double.infinity,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Zamanlayıcı",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.timer, color: Color(0xFFE5A96A)),
                      onPressed: _isRunning ? null : _showSetTimerDialog,
                      tooltip: "Süreyi Ayarla",
                    ),
                  ],
                ),
                const Divider(color: Color(0xFF535882), thickness: 2),
                const SizedBox(height: 10),
                Text(
                  "$minutesStr:$secondsStr",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _isRunning ? _pauseTimer : _startTimer,
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFFE5A96A),
                        child: Icon(
                          _isRunning ? Icons.pause : Icons.play_arrow,
                          color: const Color(0xFF282A45),
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: _resetTimer,
                      child: const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFF434773),
                        child: Icon(Icons.stop, color: Colors.white, size: 28),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          const SizedBox(height: 16),
          RetroCard(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Görevler Ön İzlenim",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$completedTasks / ${widget.tasks.length} Görev Tamamlandı",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const Divider(color: Color(0xFF535882), thickness: 2),
                ...widget.tasks
                    .take(3)
                    .map(
                      (task) => GestureDetector(
                        onTap: () {
                          setState(() {
                            task.isCompleted = !task.isCompleted;
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            children: [
                              Icon(
                                task.isCompleted
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: task.isCompleted
                                    ? Colors.lightGreen
                                    : const Color(0xFFE5A96A),
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: TextStyle(
                                    color: task.isCompleted
                                        ? Colors.lightGreen
                                        : Colors.white,
                                    fontSize: 14,
                                    decoration: null,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
