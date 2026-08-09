export 'drift_connection_stub.dart'
    if (dart.library.io) 'drift_connection_native.dart'
    if (dart.library.html) 'drift_connection_web.dart';
