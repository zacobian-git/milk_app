import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupService {
  const BackupService(this._database);

  final MilkDatabase _database;
  static const automaticBackupCopies = 7;
  static const _automaticBackupPrefix = 'doodh-hisaab-auto-';

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
    await _restoreFromFile(File(path));
    return true;
  }

  Future<File> createAutomaticBackup({DateTime? now}) async {
    final directory = await _automaticBackupDirectory();
    await directory.create(recursive: true);

    final timestamp = _timestamp(now ?? DateTime.now());
    final file = File(
      p.join(directory.path, '$_automaticBackupPrefix$timestamp.json'),
    );
    await file.writeAsString(await _database.exportJson(), flush: true);
    await retainAutomaticBackups(directory);
    return file;
  }

  Future<List<File>> automaticBackups() async {
    final directory = await _automaticBackupDirectory();
    if (!await directory.exists()) {
      return const [];
    }

    final files = await directory
        .list(followLinks: false)
        .where(
          (entity) =>
              entity is File &&
              p.basename(entity.path).startsWith(_automaticBackupPrefix) &&
              p.extension(entity.path) == '.json',
        )
        .cast<File>()
        .toList();
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return files;
  }

  Future<void> restoreAutomaticBackup(File backup) async {
    final directory = await _automaticBackupDirectory();
    final expectedDirectory = p.normalize(p.absolute(directory.path));
    final actualDirectory = p.normalize(p.absolute(backup.parent.path));
    final name = p.basename(backup.path);
    if (actualDirectory != expectedDirectory ||
        !name.startsWith(_automaticBackupPrefix) ||
        p.extension(name) != '.json') {
      throw const FileSystemException(
        'The selected automatic backup is invalid.',
      );
    }
    if (!await backup.exists()) {
      throw const FileSystemException('The selected backup could not be read.');
    }
    await _restoreFromFile(backup);
  }

  Future<void> _restoreFromFile(File file) async {
    await _database.restoreJson(await file.readAsString());
  }

  Future<Directory> _automaticBackupDirectory() async {
    final documents = await getApplicationDocumentsDirectory();
    return Directory(p.join(documents.path, 'automatic_backups'));
  }

  static Future<void> retainAutomaticBackups(
    Directory directory, {
    int maxCopies = automaticBackupCopies,
  }) async {
    if (maxCopies < 1) {
      throw ArgumentError.value(maxCopies, 'maxCopies', 'Must be at least 1.');
    }
    if (!await directory.exists()) {
      return;
    }

    final files = await directory
        .list(followLinks: false)
        .where(
          (entity) =>
              entity is File &&
              p.basename(entity.path).startsWith(_automaticBackupPrefix) &&
              p.extension(entity.path) == '.json',
        )
        .cast<File>()
        .toList();
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    for (final file in files.skip(maxCopies)) {
      await file.delete();
    }
  }

  String _timestamp(DateTime value) {
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    String threeDigits(int number) => number.toString().padLeft(3, '0');

    return '${value.year}${twoDigits(value.month)}${twoDigits(value.day)}-'
        '${twoDigits(value.hour)}${twoDigits(value.minute)}'
        '${twoDigits(value.second)}${threeDigits(value.millisecond)}';
  }
}
