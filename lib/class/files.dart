import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Files {
  Directory? directory;

  Future<void> removeAllFiles() async {
    directory = await getApplicationDocumentsDirectory();
    var files = await directory!.list().toList();
    for (var item in files) {
      if (!await FileSystemEntity.isDirectory(item.path)) {
        await item.delete();
      }
    }
  }
}
