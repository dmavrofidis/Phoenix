import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

QueryExecutor openPhoenixConnection() => LazyDatabase(() async {
  final directory = await getApplicationSupportDirectory();
  final file = File('${directory.path}/phoenix.sqlite');
  return NativeDatabase.createInBackground(file);
});
