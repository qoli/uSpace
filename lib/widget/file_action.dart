import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:share/share.dart';

class FileAction extends HookWidget {
  const FileAction({
    Key? key,
    required this.directory,
    required this.file,
    required this.fileSize,
    this.onRemove,
  }) : super(key: key);

  final Directory directory;
  final FileSystemEntity file;
  final String fileSize;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    var stat = useFuture(useMemoized(() => FileStat.stat(file.path), [file]),
        initialData: null);
    final f = DateFormat('yyyy-MM-dd hh:mm');
    final name = file.path.replaceAll(directory.path + '/', '');
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 120,
                      child: Text(
                        name,
                        style:
                            TextStyle(fontWeight: FontWeight.bold, height: 1.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$fileSize - ${stat.data != null ? f.format(stat.data!.changed) : ''}',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        fontSize: 12,
                        color: Theme.of(context).textTheme.headline1!.color,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                SizedBox(
                  height: 48,
                  width: 48,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .primaryIconTheme
                          .color!
                          .withAlpha(10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(Ionicons.trash_outline),
                      iconSize: 20,
                      onPressed: () async {
                        Navigator.pop(context);
                        await file.delete();
                        onRemove?.call();
                      },
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ButtonTheme(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: RaisedButton(
                  color: Colors.black,
                  elevation: 0,
                  onPressed: () {
                    Navigator.pop(context);
                    Share.shareFiles([file.path]);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Share",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
