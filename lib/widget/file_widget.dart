import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ionicons/ionicons.dart';
import 'package:mime/mime.dart';
import 'package:uSpace/provider/file/file_provider.dart';
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
    required this.item,
  }) : super(key: key);

  final FileItem item;

  @override
  Widget build(BuildContext context) {
    final state = useMemoized(() {
      final mimeType = lookupMimeType(item.file.path);
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

      if (item.isDirectory) {
        icon = Ionicons.folder_outline;
        listColor = Colors.pink;
        bgColor = listColor.withAlpha(5);
      }

      return _State(icon, listColor, bgColor);
    }, [item.file.path]);

    return GestureDetector(
      onTap: () {
        if (item.isDirectory) return;
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
          ),
          builder: (ctx) => SafeArea(
            child: FileAction(item: item),
          ),
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
                    item.shortPath,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      height: 1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                // maybe display 'Folder'
                TextLight(item.size),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
