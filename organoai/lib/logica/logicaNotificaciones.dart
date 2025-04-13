import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotiService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initNotification() async {
    print('🔔 [NotiService] initNotification() called');
    if (_isInitialized) {
      print('🔔 [NotiService] ya inicializado, saliendo');
      return;
    }

    final status = await Permission.notification.status;
    print('🔔 [NotiService] estado permiso antes de request(): $status');
    if (status.isDenied || status.isPermanentlyDenied) {
      final newStatus = await Permission.notification.request();
      print('🔔 [NotiService] estado permiso después de request(): $newStatus');
      if (!newStatus.isGranted) {
        print('⚠️ [NotiService] permiso denegado, no se inicializa');
        return;
      }
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(),
    );

    await notificationsPlugin.initialize(settings,
        onDidReceiveNotificationResponse: (response) {
      print('🔔 [NotiService] onDidReceiveNotificationResponse: '
          '${response.payload}');
    });

    _isInitialized = true;
    print('🔔 [NotiService] inicializado con éxito');
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        'Daily Notifications',
        channelDescription: 'Daily Notification Channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    print('🔔 [NotiService] showNotification() called');
    if (!_isInitialized) {
      print(
          '⚠️ [NotiService] no está inicializado, llamando a initNotification()');
      await initNotification();
      if (!_isInitialized) {
        print(
            '❌ [NotiService] initNotification falló, no se muestra notificación');
        return;
      }
    }
    await notificationsPlugin.show(id, title, body, notificationDetails());
    print('✅ [NotiService] notificación enviada: $title / $body');
  }
}
