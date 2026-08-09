// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html';

Future<bool> requestLocalNotificationPermission() async {
  if (!Notification.supported) return false;
  if (Notification.permission == 'granted') return true;
  return await Notification.requestPermission() == 'granted';
}

Future<bool> showLocalWorkoutNotification({
  required String title,
  required String body,
}) async {
  if (!Notification.supported || Notification.permission != 'granted') {
    return false;
  }
  Notification(title, body: body, icon: 'icons/Icon-192.png');
  return true;
}

Future<bool> installPhoenixPwa() async {
  final isReady =
      document.documentElement?.dataset['phoenixPwaReady'] == 'true';
  if (!isReady) return false;
  window.dispatchEvent(CustomEvent('phoenix-install-request'));
  return true;
}
