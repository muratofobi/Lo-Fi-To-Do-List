import 'package:flutter/material.dart';
import 'dart:async';
import '../models/task_item.dart';
import '../widgets/retro_card.dart';

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

  bool _isMusicPlaying = true; // Sadece görsel amaçlı tutuyoruz

  @override
  void initState() {
    super.initState();
    _updateTime();

    // Zamanlayıcı
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
    if (_countdownTimer != null) _countdownTimer!.cancel();
    setState(() => _isRunning = true);

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
  }

  void _resetTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _timerDurationInSeconds;
    });
  }

  void _showSetTimerDialog() {
    TextEditingController minController = TextEditingController(
      text: (_timerDurationInSeconds ~/ 60).toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF282A45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE5A96A), width: 1.5),
          ),
          title: const Text(
            "Süreyi Belirle (Dakika)",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          content: TextField(
            controller: minController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF535882)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE5A96A)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "İptal",
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5A96A),
                foregroundColor: const Color(0xFF282A45),
              ),
              onPressed: () {
                setState(() {
                  int minutes = int.tryParse(minController.text) ?? 25;
                  _timerDurationInSeconds = minutes * 60;
                  _remainingSeconds = _timerDurationInSeconds;
                  _isRunning = false;
                  _countdownTimer?.cancel();
                });
                Navigator.pop(context);
              },
              child: const Text(
                "Ayarla",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
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

  // Sadece arayüzdeki ikonun durumunu değiştirir
  void _toggleMusic() {
    setState(() {
      _isMusicPlaying = !_isMusicPlaying;
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
                GestureDetector(
                  onTap: _toggleMusic,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.music_note,
                        color: Colors.white,
                        size: 26,
                      ),
                      if (!_isMusicPlaying)
                        Transform.rotate(
                          angle: -0.785,
                          child: Container(
                            width: 28,
                            height: 2.5,
                            color: Colors.redAccent,
                          ),
                        ),
                    ],
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
