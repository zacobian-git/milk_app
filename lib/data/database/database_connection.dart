import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:milk_app/data/database/milk_database.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

MilkDatabase openMilkDatabase() => MilkDatabase(
  LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'doodh_hisaab.sqlite'));
    return NativeDatabase.createInBackground(file);
  }),
);
