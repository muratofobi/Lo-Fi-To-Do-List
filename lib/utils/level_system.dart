import 'dart:math';

class LevelSystem {
  // --- TEMEL XP AYARLARI ---
  static const int xpPerLevel = 100; // 1 Seviye atlamak için gereken XP
  static const int maxLevel = 100; // YENİ: Maksimum seviye sınırı (Level Cap)

  static const int taskCompletedXp = 25; // 1 Görev = 10 XP
  static const int routineCompletedXp = 10; // 1 Rutin = 5 XP
  static const int timerXpPerMinute = 2; // 1 Dakika Sayaç = 2 XP

  // --- HESAPLAMA YARDIMCILARI ---

  // Toplam XP'den kaçıncı seviyede olduğunu hesaplar
  static int getLevel(int totalXp) {
    // YENİ: Artık +1 eklemiyoruz (Seviye 0'dan başlıyor).
    // Ve min() fonksiyonu ile seviyenin 100'ü geçmesini engelliyoruz.
    return min(maxLevel, totalXp ~/ xpPerLevel);
  }

  // O anki seviyede kaç XP'si olduğunu hesaplar
  static int getCurrentLevelXp(int totalXp) {
    // Eğer oyuncu maksimum seviyeye (100) ulaştıysa barı hep tam dolu (100/100) gösterir
    if (getLevel(totalXp) >= maxLevel) return xpPerLevel;

    return totalXp % xpPerLevel;
  }

  // Sayaç için XP hesaplar
  static int calculateTimerXp(int secondsCompleted) {
    int minutes = secondsCompleted ~/ 60;
    return minutes * timerXpPerMinute;
  }

  // Günlük notları için XP hesaplar (Her 10 kelime için 1 XP)
  static int calculateJournalXp(String text) {
    if (text.trim().isEmpty) return 0;
    int wordCount = text.trim().split(RegExp(r'\s+')).length;
    return wordCount ~/ 10;
  }
}
