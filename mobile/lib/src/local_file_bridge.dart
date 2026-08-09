export 'local_file_bridge_stub.dart'
    if (dart.library.io) 'local_file_bridge_native.dart'
    if (dart.library.html) 'local_file_bridge_web.dart';
