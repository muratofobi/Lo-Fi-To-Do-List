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

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Kullanıcıdan bildirim izni isteme (Uygulama ilk açıldığında çalışacak)
  Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }

  // Timer bittiğinde çalacak alarmı kurma
  Future<void> scheduleTimerNotification(int durationInSeconds) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'timer_channel_id',
          'Focus Timer Alarmları',
          channelDescription: 'Timer süresi bittiğinde çalan bildirimler',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    // Şu anki zamana timer süresini ekleyerek alarmı kur
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Bildirim ID'si
      'Süre Doldu!',
      'Odaklanma seansın başarıyla tamamlandı.',
      tz.TZDateTime.now(tz.local).add(Duration(seconds: durationInSeconds)),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode
          .exactAllowWhileIdle, // Arka planda bile tam zamanında çalışır
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Timer iptal edilirse veya durdurulursa alarmı silme
  Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }
}
