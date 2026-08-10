import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static bool _riskAreaWelcomeShown = false;
  static Uint8List? _largeIconBytes;

  static Future<void> initialize() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings(
      'notification_small_icon',
    );
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: darwin);

    await _plugin.initialize(settings: settings);

    final androidImpl =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await androidImpl?.requestNotificationsPermission();

    final iosImpl =
        _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
    await iosImpl?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  static Future<void> showRiskAreaAlert({
    required String title,
    required String body,
    String payload = 'risk-area',
  }) async {
    await initialize();
    final largeIcon = await _getLargeIcon();
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'risk_area_alerts_v2',
        'Risk Area Alerts',
        channelDescription: 'แจ้งเตือนพื้นที่เสี่ยงและบริการภาคสนาม',
        importance: Importance.high,
        priority: Priority.high,
        icon: 'notification_small_icon',
        largeIcon: ByteArrayAndroidBitmap(largeIcon),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: true,
        presentList: true,
      ),
    );

    final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(
      100000,
    );

    await _plugin.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );

    // ignore: avoid_print
    print(
      '🔔 Notification shown with id: $notificationId, '
      'icon: notification_small_icon',
    );
  }

  static Future<void> showChatuchakRiskWelcomeOnce() async {
    if (_riskAreaWelcomeShown) return;
    _riskAreaWelcomeShown = true;
    await showRiskAreaAlert(
      title: 'แจ้งเตือนพื้นที่เสี่ยง เขตจตุจักร',
      body:
          'ขณะนี้มีการเฝ้าระวังโรคสัตว์สู่คนและสัตว์ป่วยผิดปกติในพื้นที่ จตุจักร',
    );
  }

  static Future<Uint8List> _getLargeIcon() async {
    final cached = _largeIconBytes;
    if (cached != null) return cached;

    final data = await rootBundle.load('assets/icons/iconapp.png');
    final bytes = data.buffer.asUint8List();
    _largeIconBytes = bytes;
    return bytes;
  }
}
