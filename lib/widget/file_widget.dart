import 'dart:io';
import 'dart:ui';

// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ionicons/ionicons.dart';
import 'package:mime/mime.dart';
import 'package:uSpace/utils/file_size.dart';
import 'package:uSpace/utils/hook.dart';
import 'package:uSpace/widget/text_light.dart';

import 'file_action.dart';

class _State {
  _State(
    this.icon,
    this.listColor,
    this.bgColor,
  );

  final IconData icon;
  final Color listColor;
  final Color bgColor;
}

class FileWidget extends HookWidget {
  const FileWidget({
    Key? key,
    required this.directory,
    required this.file,
    this.onRemove,
    this.isDir = false,
    required this.changed,
  }) : super(key: key);

  final Directory directory;
  final FileSystemEntity file;
  final VoidCallback? onRemove;
  final bool isDir;
  final DateTime changed;

  @override
  Widget build(BuildContext context) {
    var state = useMemoized(() {
      final mimeType = lookupMimeType(file.path);
      var icon = Ionicons.document_outline;
      var listColor = Theme.of(context).primaryIconTheme.color!;
      var bgColor = listColor.withAlpha(5);

      if (mimeType != null) {
        if (mimeType.startsWith('image')) {
          icon = Ionicons.image_outline;
          listColor = Colors.indigo;
          bgColor = listColor.withAlpha(10);
        }
        if (mimeType.startsWith('audio')) {
          icon = Ionicons.musical_note_outline;
          listColor = Colors.amber;
          bgColor = listColor.withAlpha(10);
        }
        if (mimeType.startsWith('video')) {
          icon = Ionicons.play_outline;
          listColor = Colors.cyan;
          bgColor = listColor.withAlpha(10);
        }
        if (mimeType.startsWith('text')) {
          icon = Ionicons.document_text_outline;
          listColor = Colors.green;
          bgColor = listColor.withAlpha(10);
        }
        if (mimeType.startsWith('application')) {
          icon = Ionicons.code_outline;
          listColor = Colors.blue;
          bgColor = listColor.withAlpha(10);
        }
      }

      if (isDir) {
        icon = Ionicons.folder_outline;
        listColor = Colors.pink;
        bgColor = listColor.withAlpha(5);
      }

      return _State(icon, listColor, bgColor);
    }, [file]);

    var size = useMemoizedFuture(
      () async {
        if (isDir) return '';
        return fileSize(await File(file.path).length());
      },
      '',
      keys: [file, isDir],
    );

    return GestureDetector(
      onTap: () {
        if (isDir) return;
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
          ),
          builder: (ctx) => SafeArea(
              child: FileAction(
            directory: directory,
            file: file,
            fileSize: size.data!,
            changed: changed,
            onRemove: onRemove,
          )),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        child: Container(
          decoration: BoxDecoration(
            color: state.bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(state.icon, color: state.listColor, size: 16),
                const SizedBox(width: 8),
                Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 150),
                  child: Text(
                    file.path.replaceAll('${directory.path}/', ''),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      height: 1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                if (isDir) const TextLight('Folder') else TextLight(size.data!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
