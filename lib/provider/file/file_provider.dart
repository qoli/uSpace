import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uSpace/utils/file_size.dart';

class FileState {
  FileState(
    this.directory, [
    this.files = const [],
    this.fileCount = 0,
  ]);

  Directory? directory;
  List<FileItem> files;
  int fileCount;
}

class FileItem {
  FileItem(
    this.file,
    this.isDirectory,
    this.changed,
    this.size,
    this.shortPath,
  );

  FileSystemEntity file;
  bool isDirectory;
  DateTime changed;
  String size;
  String shortPath;
}

extension FileSystemEntityExtension on FileSystemEntity {
  Future<FileItem> _toFileItem(Directory directory) async {
    var sizeText = 'Folder';

    if (!await FileSystemEntity.isDirectory(path)) {
      sizeText = fileSize(await File(path).length());
    }

    return FileItem(
        this,
        await FileSystemEntity.isDirectory(path),
        (await FileStat.stat(path)).changed,
        sizeText,
        path.replaceAll('${directory.path}/', ''));
  }
}

class FileProvider extends ValueNotifier<FileState> {
  FileProvider() : super(FileState(null)) {
    refresh();
  }

  Future<void> refresh() async {
    final directory = await getApplicationDocumentsDirectory();
    var files = await directory.list().toList();
    var list = await Future.wait(files.map((e) => e._toFileItem(directory)));
    list.sort((a, b) => b.changed.compareTo(a.changed));
    value = FileState(
      directory,
      list,
      list.where((element) => !element.isDirectory).length,
    );
    notifyListeners();
  }
}
