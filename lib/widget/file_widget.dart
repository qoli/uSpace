import 'dart:io';
import 'dart:ui';

import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ionicons/ionicons.dart';
import 'package:mime/mime.dart';
import 'package:tuple/tuple.dart';
import 'package:uSpace/widget/text_light.dart';

import 'file_action.dart';

class FileWidget extends HookWidget {
  const FileWidget({
    Key? key,
    required this.directory,
    required this.file,
    this.onRemove,
  }) : super(key: key);

  final Directory directory;
  final FileSystemEntity file;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    var colorTuple = useMemoized(() {
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

      return Tuple3(icon, listColor, bgColor);
    }, [file]);

    var lengthFuture = useFuture(
      useMemoized(() async {
        if (await FileSystemEntity.isDirectory(file.path)) return 0;
        return await File(file.path).length();
      }, [file]),
      initialData: 0,
    );

    var size = useMemoized(
      () => filesize(lengthFuture.data),
      [lengthFuture.data],
    );
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          builder: (ctx) => SafeArea(
              child: FileAction(
            directory: directory,
            file: file,
            fileSize: size,
            onRemove: onRemove,
          )),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        child: Container(
          decoration: BoxDecoration(
            color: colorTuple.item3,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(colorTuple.item1, color: colorTuple.item2, size: 16),
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
                TextLight(size),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
