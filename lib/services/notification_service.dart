import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

// TOP-LEVEL / BACKGROUND HANDLER (Harus berada di luar kelas)
// Dipanggil saat aplikasi di-kill atau berjalan di background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("Handling background message: ${message.messageId}");
    print("Title: ${message.notification?.title}");
    print("Body: ${message.notification?.body}");
  }
}

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Inisialisasi Layanan Notifikasi
  static Future<void> initialize() async {
    // 1. Panggil Permintaan Izin (Skenario N01) secara otomatis saat inisialisasi
    await requestNotificationPermission();

    // 2. Register Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Setup Local Notification Settings (Android & iOS)
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Handle ketika notifikasi lokal diklik oleh pengguna
        if (kDebugMode) {
          print('Local notification clicked with payload: ${details.payload}');
        }
      },
    );

    // 4. Buat High Importance Channel di Android (Abaikan jika berjalan di Web)
    if (!kIsWeb) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'Notifikasi Darurat & Loker', // name
        description: 'Digunakan untuk peringatan bahaya dan status loker.',
        importance: Importance.high,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // 5. Setup FCM Foreground Handler (Ketika app sedang terbuka)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && (android != null || kIsWeb)) {
        _showLocalNotification(
          id: notification.hashCode,
          title: notification.title ?? '',
          body: notification.body ?? '',
          payload: message.data.toString(),
        );
      }
    });

    // 6. Cetak FCM Token untuk Keperluan Pengujian / Console
    String? token = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print("==============================================");
      print("FCM REGISTRATION TOKEN:");
      print(token);
      print("==============================================");
    }
  }

  // Permintaan Izin Notifikasi Resmi (Kondisi Skenario N01)
  // Ini akan memicu pop-up native browser (misal: Chrome "localhost wants to send notifications")
  // atau pop-up izin POST_NOTIFICATIONS di Android 13+.
  static Future<bool> requestNotificationPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) print('Izin notifikasi diberikan oleh pengguna.');
      return true;
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) print('Izin sementara (provisional) diberikan.');
      return true;
    } else {
      if (kDebugMode) print('Izin notifikasi ditolak oleh pengguna.');
      return false;
    }
  }

  // Tampilkan Local Notification (Untuk Foreground App atau In-App Alert)
  static Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'Notifikasi Darurat & Loker',
      channelDescription: 'Digunakan untuk peringatan bahaya dan status loker.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  // Fungsi Helper untuk memicu Notifikasi Lokal secara manual dari App (Opsional)
  static Future<void> triggerManualNotification({
    required String title,
    required String body,
  }) async {
    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
    );
  }
}
