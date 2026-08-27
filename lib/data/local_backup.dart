import 'local_backup_stub.dart'
    if (dart.library.io) 'local_backup_io.dart' as impl;

Future<String?> writeBackupFile(String payload) => impl.writeBackupFile(payload);
