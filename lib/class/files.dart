import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Files {
  Directory? directory;

  Future<void> removeAllFiles() async {
    directory = await getApplicationDocumentsDirectory();
    final files = await directory!.list().toList();
    for (final item in files) {
      if (!await FileSystemEntity.isDirectory(item.path)) {
        await item.delete();
      }
    }
  }
}
