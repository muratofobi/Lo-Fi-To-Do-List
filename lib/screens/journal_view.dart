import 'package:flutter/material.dart';
import '../widgets/retro_card.dart';
import '../utils/level_system.dart'; // Algoritmayı çağırdık

class JournalView extends StatefulWidget {
  final Function(int) onUserXpGained; // XP tetikleyicisi eklendi

  const JournalView({super.key, required this.onUserXpGained});

  @override
  State<JournalView> createState() => _JournalViewState();
}

class _JournalViewState extends State<JournalView> {
  DateTime _selectedDate = DateTime.now();
  bool _isEditMode = false;

  final List<Map<String, dynamic>> _globalHabits = [
    {"id": "1", "title": "Hedeflerim Doğrultusunda çalıştım"},
    {"id": "2", "title": "Beslenme düzenime uydum"},
    {"id": "3", "title": "2+ Litre su içttim"},
    {"id": "4", "title": "Günlük yazdım"},
    {"id": "5", "title": "Spor yaptım"},
  ];

  final Map<String, Map<String, dynamic>> _dailyDatabase = {};
  int _selectedMood = 2;
  final TextEditingController _journalController = TextEditingController();

  Map<String, bool> _currentHabitStatus = {};

  // XP FARM'INI ENGELLEMEK İÇİN GEREKLİ: O gün için önceden kaydedilmiş metnin XP değerini tutar
  int _previouslySavedJournalXp = 0;

  @override
  void initState() {
    super.initState();
    _loadDataForDate(_selectedDate);
  }

  String _getDateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void _saveCurrentData() {
    String key = _getDateKey(_selectedDate);

    // === METİN (JOURNAL) XP HESAPLAMASI ===
    // Metin için kazanılması gereken yeni XP miktarını algoritmaya soruyoruz
    int newJournalXp = LevelSystem.calculateJournalXp(_journalController.text);

    // Yalnızca aradaki farkı Ana Beyne gönderiyoruz (Eğer sildiyse negatif XP gider)
    int xpDifference = newJournalXp - _previouslySavedJournalXp;
    if (xpDifference != 0) {
      widget.onUserXpGained(xpDifference);
      _previouslySavedJournalXp =
          newJournalXp; // Kaydedilen durumu güncelliyoruz
    }

    _dailyDatabase[key] = {
      'mood': _selectedMood,
      'journal': _journalController.text,
      'habitStatus': Map<String, bool>.from(_currentHabitStatus),
      'savedJournalXp':
          _previouslySavedJournalXp, // O günün XP'sini de veritabanına ekliyoruz
    };
  }

  void _loadDataForDate(DateTime date) {
    String key = _getDateKey(date);

    if (_dailyDatabase.containsKey(key)) {
      var data = _dailyDatabase[key]!;
      setState(() {
        _selectedMood = data['mood'];
        _journalController.text = data['journal'];
        _currentHabitStatus = Map<String, bool>.from(data['habitStatus']);
        _previouslySavedJournalXp = data['savedJournalXp'] ?? 0;
      });
    } else {
      setState(() {
        _selectedMood = 1;
        _journalController.text = "";
        _currentHabitStatus = {};
        _previouslySavedJournalXp = 0;
      });
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFE5A96A),
              onPrimary: Color(0xFF282A45),
              surface: Color(0xFF282A45),
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: const Color(0xFF1E1F36),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      _saveCurrentData();
      setState(() {
        _selectedDate = picked;
        _isEditMode = false;
      });
      _loadDataForDate(picked);
    }
  }

  void _showAddHabitDialog() {
    TextEditingController titleController = TextEditingController();
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
            "Yeni Rutin Ekle",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          content: TextField(
            controller: titleController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Örn: Kitap okundu",
              hintStyle: TextStyle(color: Colors.white38),
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
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    _globalHabits.add({
                      "id": DateTime.now().millisecondsSinceEpoch.toString(),
                      "title": titleController.text,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "Ekle",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isToday = _getDateKey(_selectedDate) == _getDateKey(DateTime.now());

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Günlük",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!isToday)
                TextButton.icon(
                  onPressed: () {
                    _saveCurrentData();
                    setState(() {
                      _selectedDate = DateTime.now();
                    });
                    _loadDataForDate(_selectedDate);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 16,
                    color: Color(0xFFE5A96A),
                  ),
                  label: const Text(
                    "Bugüne Dön",
                    style: TextStyle(color: Color(0xFFE5A96A), fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          RetroCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: Color(0xFFE5A96A),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "${_selectedDate.day.toString().padLeft(2, '0')} / ${_selectedDate.month.toString().padLeft(2, '0')} / ${_selectedDate.year}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _pickDate(context),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1F36),
                    side: const BorderSide(color: Color(0xFFE5A96A), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Tarih Seç",
                    style: TextStyle(color: Color(0xFFE5A96A)),
                  ),
                ),
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
                  "Bugün Nasıl Hissediyorsun?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMoodIcon(1, "😊", "Mutlu"),
                    _buildMoodIcon(2, "💻", "Odaklı"),
                    _buildMoodIcon(3, "⚡", "Enerjik"),
                    _buildMoodIcon(4, "☕", "Sakin"),
                    _buildMoodIcon(5, "🌙", "Yorgun"),
                    _buildMoodIcon(6, "☹️", "Üzgün"),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          RetroCard(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Günlük Rutinler",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _isEditMode ? Icons.check : Icons.edit,
                            color: const Color(0xFFE5A96A),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _isEditMode = !_isEditMode;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Color(0xFFE5A96A),
                            size: 22,
                          ),
                          onPressed: _showAddHabitDialog,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(
                  color: Color(0xFF535882),
                  thickness: 1.5,
                  height: 0,
                ),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _globalHabits.length,
                  itemBuilder: (context, index) {
                    final habit = _globalHabits[index];
                    final habitId = habit["id"];

                    bool isChecked = _currentHabitStatus[habitId] ?? false;

                    return ListTile(
                      key: ValueKey(habitId),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: Checkbox(
                        value: isChecked,
                        activeColor: const Color(0xFFE5A96A),
                        checkColor: const Color(0xFF282A45),
                        onChanged: (val) {
                          setState(() {
                            _currentHabitStatus[habitId] = val ?? false;
                          });

                          // === RUTİNLER İÇİN XP TETİKLEYİCİ ===
                          if (val == true) {
                            widget.onUserXpGained(
                              LevelSystem.routineCompletedXp,
                            );
                          } else {
                            widget.onUserXpGained(
                              -LevelSystem.routineCompletedXp,
                            );
                          }
                        },
                      ),
                      title: Text(
                        habit["title"],
                        style: TextStyle(
                          color: isChecked ? Colors.lightGreen : Colors.white,
                          fontSize: 13,
                          decoration: null,
                        ),
                      ),
                      trailing: _isEditMode
                          ? SizedBox(
                              width: 70,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _globalHabits.removeAt(index);
                                      });
                                    },
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: index > 0
                                            ? () {
                                                setState(() {
                                                  final item = _globalHabits
                                                      .removeAt(index);
                                                  _globalHabits.insert(
                                                    index - 1,
                                                    item,
                                                  );
                                                });
                                              }
                                            : null,
                                        child: Icon(
                                          Icons.keyboard_arrow_up,
                                          color: index > 0
                                              ? Colors.white70
                                              : Colors.transparent,
                                          size: 22,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: index < _globalHabits.length - 1
                                            ? () {
                                                setState(() {
                                                  final item = _globalHabits
                                                      .removeAt(index);
                                                  _globalHabits.insert(
                                                    index + 1,
                                                    item,
                                                  );
                                                });
                                              }
                                            : null,
                                        child: Icon(
                                          Icons.keyboard_arrow_down,
                                          color:
                                              index < _globalHabits.length - 1
                                              ? Colors.white70
                                              : Colors.transparent,
                                          size: 22,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : null,
                    );
                  },
                ),
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
                  "Günlük Notlar & Düşünceler",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1F36),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF535882).withOpacity(0.5),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: _journalController,
                    maxLines: null,
                    expands: true,
                    keyboardType: TextInputType.multiline,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: "Bugün neler yaptın, nasıl bir gündü?",
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      _saveCurrentData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Günlük başarıyla kaydedildi! XP'niz hesaplandı.",
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE5A96A),
                      foregroundColor: const Color(0xFF282A45),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      "Kaydet",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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

  Widget _buildMoodIcon(int index, String emoji, String label) {
    bool isSelected = _selectedMood == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMood = index),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFE5A96A)
                  : const Color(0xFF1E1F36),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
              ),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? const Color(0xFFE5A96A) : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
