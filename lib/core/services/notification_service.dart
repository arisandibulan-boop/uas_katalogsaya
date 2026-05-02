import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../firebase_options.dart'; // Pastikan path ini benar sesuai struktur folder Anda 

// ──────────────────────────────────────────────────────────────────────────────
// STEP 1 — BACKGROUND NOTIFICATION HANDLER (Halaman 4)
// ──────────────────────────────────────────────────────────────────────────────
@pragma('vm:entry-point') // Wajib agar Dart tidak menghapus fungsi ini saat build 
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Wajib inisialisasi ulang karena berjalan di isolate (proses) terpisah 
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling background message: ${message.messageId}");
}

class NotificationService {
  // Menggunakan Singleton agar instance hanya satu di seluruh aplikasi
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  // Mendefinisikan variabel agar tidak merah (Undefined name)
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif = FlutterLocalNotificationsPlugin();

  // Mendefinisikan ID dan Nama Channel (Harus konsisten dengan AndroidManifest.xml) 
  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'High Importance Notifications';

  // ════ INITIALIZE SERVICE ══════════════════════════════
  Future<void> initialize() async {
    // 1. Daftarkan background handler 
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Minta izin notifikasi untuk Android 13+ dan iOS 
    await _requestPermission();

    // 3. Setup plugin notifikasi lokal 
    await _setupLocalNotifications();

    // 4. Subscribe ke topik 'all_users' untuk broadcast [
    await _messaging.subscribeToTopic('all_users');

    // 5. Listener saat aplikasi sedang terbuka (Foreground) 
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 6. Listener saat notifikasi di-tap ketika aplikasi di background 
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

    // 7. Cek apakah aplikasi dibuka melalui notifikasi dari kondisi mati (Terminated) 
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      // Delay 500ms agar Navigator sudah siap sebelum berpindah halaman [cite: 168]
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleMessageOpened(initial);
      });
    }
  }

  // ════ REQUEST PERMISSION ══════════════════════════════
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('Auth status: ${settings.authorizationStatus}'); 
  }

  // ════ SETUP LOCAL NOTIFICATIONS ══════════════════════
  Future<void> _setupLocalNotifications() async {
    // Memastikan file ic_notification.xml sudah dibuat di folder drawable 
    const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotif.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Membuat channel notifikasi untuk Android 8.0 ke atas 
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.max,
      playSound: true,
    );

    await _localNotif
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // ════ HANDLER FOREGROUND ══════════════════════════════
  void _handleForegroundMessage(RemoteMessage message) {
    final notif = message.notification; 
    if (notif == null) return; 

    // Menampilkan notifikasi manual karena di Android notifikasi tidak muncul 
    // otomatis jika aplikasi sedang aktif di depan 
    _localNotif.show(
      notif.hashCode,
      notif.title,
      notif.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
        ),
      ),
    );
  }

  // ════ HANDLER TAP & ROUTING ══════════════════════════
  void _handleMessageOpened(RemoteMessage message) {
    debugPrint("Notification Tapped: ${message.data}");
    final String? screen = message.data['screen']; 
    
    // Logika routing berdasarkan nilai 'screen' di payload data 
    if (screen == 'dashboard') {
      // Tambahkan perintah navigasi ke halaman Dashboard di sini
    } else if (screen == 'profile') {
      // Tambahkan perintah navigasi ke halaman Profil di sini
    }
  }

  // ════ GET FCM TOKEN (Perbaikan Halaman 3) ══════════════
  Future<String?> getToken() async {
    // Menghapus 'return null' agar token asli bisa dikirim ke backend 
    final token = await _messaging.getToken(); 
    debugPrint('FCM Token: $token'); 
    return token; 
  }
}