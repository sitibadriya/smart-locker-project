import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

// TOP-LEVEL / BACKGROUND HANDLER
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
    // 1. Panggil Permintaan Izin (Skenario N01)
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
        if (kDebugMode) {
          print('Local notification clicked with payload: ${details.payload}');
        }
      },
    );

    // 4. Buat 3 Channel Berbeda di Android (Info, Waspada, Bahaya)
    if (!kIsWeb) {
      // Channel 1: Info (Hijau / Normal) - Untuk Santri / Aktivitas Normal
      const AndroidNotificationChannel infoChannel = AndroidNotificationChannel(
        'locker_info_channel',
        'Informasi Aktivitas Loker',
        description: 'Digunakan untuk status normal harian santri.',
        importance: Importance.defaultImportance,
        playSound: true,
      );

      // Channel 2: Waspada (Kuning / Medium) - Untuk Pembina Rayon
      const AndroidNotificationChannel warningChannel =
          AndroidNotificationChannel(
        'locker_warning_channel',
        'Peringatan Waspada Loker',
        description: 'Digunakan saat percobaan akses salah berulang.',
        importance: Importance.high,
        playSound: true,
      );

      // Channel 3: Bahaya (Merah / High Alert) - Untuk Sarpras / Pembongkaran
      const AndroidNotificationChannel dangerChannel =
          AndroidNotificationChannel(
        'locker_danger_channel',
        'Darurat & Bahaya Loker',
        description: 'Digunakan untuk indikasi pembobolan atau suhu panas.',
        importance: Importance.max,
        playSound: true,
      );

      final androidPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.createNotificationChannel(infoChannel);
      await androidPlugin?.createNotificationChannel(warningChannel);
      await androidPlugin?.createNotificationChannel(dangerChannel);
    }

    // 5. Setup FCM Foreground Handler (Ketika app sedang terbuka)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // Ambil tipe channel dari payload data FCM, default ke 'info' jika kosong
      String channelId = message.data['channel_id'] ?? 'locker_info_channel';

      if (notification != null && (android != null || kIsWeb)) {
        _showLocalNotification(
          id: notification.hashCode,
          title: notification.title ?? '',
          body: notification.body ?? '',
          payload: message.data.toString(),
          channelId: channelId,
        );
      }
    });

    // 6. Cetak FCM Token
    String? token = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print("==============================================");
      print("FCM REGISTRATION TOKEN:");
      print(token);
      print("==============================================");
    }
  }

  // Permintaan Izin Notifikasi Resmi menggunakan Permission Handler
  static Future<bool> requestNotificationPermission() async {
    // Meminta izin notifikasi secara eksplisit ke sistem Android
    PermissionStatus status = await Permission.notification.request();

    if (status.isGranted) {
      if (kDebugMode) print('Izin notifikasi sistem diberikan oleh pengguna.');
      return true;
    } else if (status.isDenied) {
      if (kDebugMode) print('Izin notifikasi sistem ditolak oleh pengguna.');
      return false;
    } else if (status.isPermanentlyDenied) {
      // Jika ditolak secara permanen, arahkan ke pengaturan aplikasi
      await openAppSettings();
      return false;
    }
    return false;
  }

  // Tampilkan Local Notification Berdasarkan Channel
  static Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    required String channelId,
  }) async {
    // Tentukan parameter visual berdasarkan channel yang dikirim
    Importance importance = Importance.defaultImportance;
    Priority priority = Priority.defaultPriority;

    if (channelId == 'locker_danger_channel') {
      importance = Importance.max;
      priority = Priority.max;
    } else if (channelId == 'locker_warning_channel') {
      importance = Importance.high;
      priority = Priority.high;
    }

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelId == 'locker_danger_channel'
          ? 'Darurat & Bahaya Loker'
          : channelId == 'locker_warning_channel'
              ? 'Peringatan Waspada Loker'
              : 'Informasi Aktivitas Loker',
      channelDescription: 'Notifikasi sistem keamanan loker pesantren.',
      importance: importance,
      priority: priority,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    NotificationDetails platformDetails = NotificationDetails(
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

  // Fungsi Helper untuk memicu Notifikasi Lokal secara manual
  static Future<void> triggerManualNotification({
    required String title,
    required String body,
    String channelId = 'locker_info_channel',
  }) async {
    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      channelId: channelId,
    );
  }
}
