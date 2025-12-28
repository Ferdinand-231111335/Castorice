import 'package:awesome_notifications/awesome_notifications.dart';

Future<void> showRedeemNotification({
  required String title,
  required String body,
}) async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      channelKey: 'basic_channel',
      title: title,
      body: body,
      notificationLayout: NotificationLayout.Default,
    ),
  );
}
