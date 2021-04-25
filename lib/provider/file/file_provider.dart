import 'dart:io';

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
  Future<FileItem> toFileItem(Directory directory) async {
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
