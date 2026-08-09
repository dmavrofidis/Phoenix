export 'local_notification_bridge_stub.dart'
    if (dart.library.io) 'local_notification_bridge_native.dart'
    if (dart.library.html) 'local_notification_bridge_web.dart';
