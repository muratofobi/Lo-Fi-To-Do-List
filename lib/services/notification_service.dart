import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Singleton pattern (Uygulama boyunca tek bir instance çalışsın)
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Zaman dilimi ayarlarını başlat
    tz.initializeTimeZones();

    // Android için bildirim ikonu (varsayılan flutter ikonu)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // ==========================================
    // YENİ: iOS (Apple) UYUMLULUĞU EKLENDİ
    // ==========================================
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS, // iOS ayarlarını sisteme dahil ettik
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Kullanıcıdan bildirim izni isteme (Uygulama ilk açıldığında çalışacak)
  Future<void> requestPermissions() async {
    // Android izinleri
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();

    // iOS İzinleri (Sadece Apple cihazlarda otomatik tetiklenir)
    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
    await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // Timer bittiğinde çalacak alarmı kurma
  Future<void> scheduleTimerNotification(int durationInSeconds) async {
    const AndroidNotificationDetails
    androidNotificationDetails = AndroidNotificationDetails(
      'focus_timer_safe_channel_v2', // Kanalı v2 yaptık (eski sessiz önbelleği ezmek için)
      'Odaklanma Bildirimleri',
      channelDescription: 'Timer süresi bittiğinde gelen bildirim',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    // iOS için bildirim detayları
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails, // iOS ayarları eklendi
    );

    // DÜZELTME 1: tz.UTC yerine yerel saate (tz.local) döndük.
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Bildirim ID'si
      'Süre Doldu!',
      'Odaklanma seansın başarıyla tamamlandı.',
      tz.TZDateTime.now(tz.local).add(Duration(seconds: durationInSeconds)),
      notificationDetails,
      // DÜZELTME 2: inexact yerine exact moduna geri döndük (saniye saniyesine çalması için).
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Timer iptal edilirse veya durdurulursa alarmı silme
  Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }
}
