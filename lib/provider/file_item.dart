import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:uSpace/utils/file.dart';

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

class FileItem with EquatableMixin {
  const FileItem(
    this.file,
    this.isDirectory,
    this.changed,
    this.size,
    this.shortPath,
  );

  final FileSystemEntity file;
  final bool isDirectory;
  final DateTime changed;
  final String size;
  final String shortPath;

  @override
  List<Object?> get props => [
        file.path,
        isDirectory,
        changed,
        size,
        shortPath,
      ];
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
