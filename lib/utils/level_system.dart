// lib/utils/level_system.dart

class LevelSystem {
  // --- TEMEL XP AYARLARI ---
  static const int xpPerLevel = 100; // 1 Seviye atlamak için gereken XP

  static const int taskCompletedXp = 10; // 1 Görev = 10 XP
  static const int routineCompletedXp = 5; // 1 Rutin = 5 XP
  static const int timerXpPerMinute = 2; // 1 Dakika Sayaç = 2 XP

  // --- HESAPLAMA YARDIMCILARI ---

  // Toplam XP'den kaçıncı seviyede olduğunu hesaplar
  static int getLevel(int totalXp) {
    return (totalXp ~/ xpPerLevel) + 1;
  }

  // O anki seviyede kaç XP'si olduğunu hesaplar (Örn: 250 XP -> 50/100 ilerleme)
  static int getCurrentLevelXp(int totalXp) {
    return totalXp % xpPerLevel;
  }

  // Sayaç için XP hesaplar (Saniyeyi dakikaya çevirip 2 ile çarpar)
  static int calculateTimerXp(int secondsCompleted) {
    int minutes = secondsCompleted ~/ 60;
    return minutes * timerXpPerMinute;
  }

  // Günlük notları için XP hesaplar (Her 10 kelime için 1 XP)
  static int calculateJournalXp(String text) {
    if (text.trim().isEmpty) return 0;

    // Metni boşluklardan bölerek kelime sayısını buluyoruz
    int wordCount = text.trim().split(RegExp(r'\s+')).length;

    // 10'a bölümünden çıkan tam sayıyı döndürüyoruz
    return wordCount ~/ 10;
  }
}
