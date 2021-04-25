import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:uSpace/provider/file/file_provider.dart';
import 'package:uSpace/generated/l10n.dart';

class FileAction extends HookWidget {
  const FileAction({
    Key? key,
    required this.item,
  }) : super(key: key);

  final FileItem item;

  @override
  Widget build(BuildContext context) {
    var fileProvider = useContext().read<FileProvider>();

    final date = useMemoized(
      () => DateFormat('yyyy-MM-dd hh:mm').format(item.changed),
      [item.changed],
    );
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 120,
                          child: Text(
                            item.shortPath,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              height: 1.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.size} - $date',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            fontSize: 12,
                            color: Theme.of(context).textTheme.headline1!.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _DeleteButton(
                  file: item.file,
                  onRemove: () => fileProvider.refresh(),
                )
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ButtonTheme(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Share.shareFiles([item.file.path]);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      L10n.of(context).share,
                      style: const TextStyle(
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

class _DeleteButton extends HookWidget {
  const _DeleteButton({
    Key? key,
    required this.file,
    required this.onRemove,
  }) : super(key: key);

  final FileSystemEntity file;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    var confirmDelete = useState(false);
    var tickerProvider = useSingleTickerProvider();
    return GestureDetector(
      onTap: () async {
        if (!confirmDelete.value) {
          confirmDelete.value = true;
          return;
        }
        Navigator.pop(context);
        await file.delete();
        onRemove?.call();
      },
      child: AnimatedContainer(
        decoration: BoxDecoration(
          color: confirmDelete.value
              ? Colors.red
              : Theme.of(context).primaryIconTheme.color!.withAlpha(10),
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(milliseconds: 300),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                Ionicons.trash_outline,
                size: 20,
                color: confirmDelete.value
                    ? Colors.white
                    : Theme.of(context).primaryIconTheme.color,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                vsync: tickerProvider,
                child: confirmDelete.value
                    ? Padding(
                        padding: const EdgeInsets.only(left: 14),
                        child: Text(
                          L10n.of(context).delete,
                          style: const TextStyle(color: Colors.white),
                        ),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
