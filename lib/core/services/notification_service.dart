import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:talker_flutter/talker_flutter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() => _instance;

  NotificationService._internal();

  Future<void> initialize({required Talker talker}) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/logo_monochrome');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notifications.initialize(initializationSettings);

    // Запрашиваем разрешения через permission_handler
    await _requestPermissions(talker: talker);
  }

  Future<void> _requestPermissions({required Talker talker}) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.request();

      if (status.isGranted) {
        talker.info('Разрешение на уведомления получено');
      } else if (status.isDenied) {
        talker.warning('Разрешение на уведомления отклонено');
      } else if (status.isPermanentlyDenied) {
        talker.warning('Разрешение на уведомления отклонено навсегда');

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

  Future<void> showSuccessNotification({required Talker talker}) async {
    talker.info('Попытка отправки уведомления об успехе');
    
    // Проверяем разрешения через permission_handler
    if (!await _checkPermissions()) {
      talker.warning('Уведомления не разрешены');
      return;
    }

    talker.info('Разрешения получены, создаем уведомление');

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
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      ),
    );

    try {
      await _notifications.show(
        0,
        'Рисунок сохранён',
        'Ваш рисунок успешно сохранён в галерею!',
        platformDetails,
        payload: 'drawing_saved',
      );
      talker.info('Уведомление об успехе отправлено');
    } catch (e) {
      talker.error('Ошибка отправки уведомления: $e');
    }
  }

  Future<void> showErrorNotification(String message, {required Talker talker}) async {
    talker.info('Попытка отправки уведомления об ошибке');
    
    if (!await _checkPermissions()) {
      talker.warning('Уведомления не разрешены');
      return;
    }

    talker.info('Разрешения получены, создаем уведомление об ошибке');

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
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      ),
    );

    try {
      await _notifications.show(
        1,
        'Ошибка сохранения',
        message,
        platformDetails,
        payload: 'drawing_error',
      );
      talker.info('Уведомление об ошибке отправлено');
    } catch (e) {
      talker.error('Ошибка отправки уведомления: $e');
    }
  }
}
