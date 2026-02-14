import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:talker_flutter/talker_flutter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() => _instance;

  NotificationService._internal();

  Future<void> initialize({required Talker talker}) async {
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(iOS: initializationSettingsIOS);

    await _notifications.initialize(initializationSettings);

    await _requestPermissions(talker: talker);
  }

  // Запрашиваем разрешения
  Future<void> _requestPermissions({required Talker talker}) async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final bool? result = await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      if (result == true) {
        talker.info('Разрешение на уведомления iOS получено');
      } else {
        talker.warning('Разрешение на уведомления iOS отклонено');
      }
    }
  }

  Future<void> showSuccessNotification({required Talker talker}) async {
    talker.info('Попытка отправки уведомления об успехе');

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      iOS: iosDetails,
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

  Future<void> showErrorNotification(
    String message, {
    required Talker talker,
  }) async {
    talker.info('Попытка отправки уведомления об ошибке');

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      iOS: iosDetails,
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
