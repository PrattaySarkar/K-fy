import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String?> writeBackupFile(String payload) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/kfy_backup.json');
  await file.writeAsString(payload);
  return file.path;
}
