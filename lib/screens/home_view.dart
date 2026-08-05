import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import '../models/task_item.dart';
import '../widgets/retro_card.dart';
import '../services/notification_service.dart';

class HomeView extends StatefulWidget {
  final List<TaskItem> tasks;
  const HomeView({super.key, required this.tasks});

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

  // GLOBAL SES KONTROLÜ (Master Switch)
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
    if (_remainingSeconds <= 0) return; // 0 saniyeye alarm kurulmaz!

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

    // Timer durdurulduğunda arka plandaki bildirimi iptal et
    NotificationService().cancelNotification();
  }

  void _resetTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _timerDurationInSeconds;
    });

    // Timer sıfırlandığında arka plandaki bildirimi iptal et
    NotificationService().cancelNotification();
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
                    mode: CupertinoTimerPickerMode
                        .ms, // Dakika ve Saniye İnce Ayarı
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

  void _toggleSound() {
    setState(() {
      _isSoundEnabled = !_isSoundEnabled;
    });
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hoş Geldin, Murat!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
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
                Visibility(
                  visible: false,
                  child: GestureDetector(
                    onTap: _toggleSound,
                    child: Icon(
                      _isSoundEnabled ? Icons.volume_up : Icons.volume_off,
                      color: _isSoundEnabled ? Colors.white : Colors.redAccent,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.settings, color: Colors.white, size: 24),
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
                      "Focus Timer",
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
                  "To-Do Özet",
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
