import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() => _instance;

  NotificationService._internal();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/logo_monochrome');

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: DarwinInitializationSettings(),
        );

    await _notifications.initialize(initializationSettings);

    // Запрашиваем разрешения через permission_handler
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.request();

      if (status.isGranted) {
        debugPrint('Разрешение на уведомления получено');
      } else if (status.isDenied) {
        debugPrint('Разрешение на уведомления отклонено');
      } else if (status.isPermanentlyDenied) {
        debugPrint('Разрешение на уведомления отклонено навсегда');

        await openAppSettings();
      }
    }
  }

  Future<bool> _checkPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.status;
      return status.isGranted;
    }
    return true;
  }

  Future<void> showSuccessNotification() async {
    // Проверяем разрешения через permission_handler
    if (!await _checkPermissions()) {
      debugPrint('Уведомления не разрешены');
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'drawing_channel',
          'Drawing Notifications',
          channelDescription: 'Notifications for drazzle',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker',
          enableVibration: true,
          playSound: true,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      0,
      'Рисунок сохранён',
      'Ваш рисунок успешно сохранён в галерею!',
      platformDetails,
      payload: 'drawing_saved',
    );
  }

  Future<void> showErrorNotification(String message) async {
    if (!await _checkPermissions()) {
      debugPrint('Уведомления не разрешены');
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'drawing_channel',
          'Drawing Notifications',
          channelDescription: 'Error notifications for drawing app',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker',
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      1,
      'Ошибка сохранения',
      message,
      platformDetails,
      payload: 'drawing_error',
    );
  }
}
