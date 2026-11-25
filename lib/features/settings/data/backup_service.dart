import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupService {
  const BackupService(this._database);

  final MilkDatabase _database;

  Future<void> shareBackup() async {
    final json = await _database.exportJson();
    final directory = await getTemporaryDirectory();
    final now = DateTime.now();
    final fileName =
        'doodh-hisaab-backup-${now.year}-${now.month}-${now.day}.json';
    final file = File(p.join(directory.path, fileName));
    await file.writeAsString(json, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: fileName,
      ),
    );
  }

  Future<bool> restoreBackup() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (files.isEmpty) {
      return false;
    }

    final selectedFile = files.single;
    final path = selectedFile.path;
    if (path == null) {
      throw const FileSystemException('The selected backup could not be read.');
    }
    final source = await File(path).readAsString();
    await _database.restoreJson(source);
    return true;
  }
}
