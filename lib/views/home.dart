import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:ionicons/ionicons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:uSpace/server/http_server_provider.dart';
import 'package:uSpace/server/server_status.dart';
import 'package:uSpace/utils/hook.dart';
import 'package:uSpace/widget/empty.dart';
import 'package:uSpace/widget/file_widget.dart';
import 'package:uSpace/widget/text_light.dart';

import 'about.dart';

class _State {
  const _State(
    this.directory, [
    this.fileCount = 0,
    this.files = const [],
  ]);

  final Directory? directory;
  final List<FileState> files;
  final int fileCount;
}

class FileState {
  FileState(
    this.file,
    this.isDirectory,
    this.changed,
  );

  final FileSystemEntity file;
  final bool isDirectory;
  final DateTime changed;
}

class HomePage extends HookWidget {
  HomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final port = useState(8020);

    final listRefreshKey = useState(Object());

    final status = useValueListenable(useMemoized(
      () => HttpServerProvider(port.value, () {
        listRefreshKey.value = Object();
      }),
      [port.value],
    ));

    final state = useMemoizedFuture(
      () async {
        final directory = await getApplicationDocumentsDirectory();
        var files = await directory.list().toList();
        var list = await Future.wait(files.map(
          (e) async => FileState(
            e,
            await FileSystemEntity.isDirectory(e.path),
            (await FileStat.stat(e.path)).changed,
          ),
        ));
        list.sort((a, b) => b.changed.compareTo(a.changed));

        return _State(
          directory,
          list.where((element) => !element.isDirectory).length,
          list,
        );
      },
      const _State(null),
      keys: [listRefreshKey.value],
    );

    final localIP = useMemoizedFuture(
      () => getLocalIpAddress(port.value),
      null,
      keys: [port.value],
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Ionicons.help_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AboutPage(),
                ),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextLight('Status:'),
            Text(
              serverStatusStringMap[status]!,
              style: const TextStyle(
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextLight('Server:'),
            GestureDetector(
              onTap: () {
                if (localIP.data == null) return;
                var url = 'http://${localIP.data}:${port.value}';
                Clipboard.setData(ClipboardData(text: url));
                Share.share(url);
              },
              child: Row(
                children: [
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 140),
                    child: Text(
                      localIP.data != null
                          ? '${localIP.data}:${port.value}'
                          : '...',
                      style: const TextStyle(
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (localIP.data != null)
                    const Icon(Ionicons.copy_outline, size: 16)
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Expanded(
              child: Builder(builder: (context) {
                Widget child;
                if (state.data!.fileCount > 0)
                  child = CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                          child: TextLight('Files (${state.data!.fileCount})')),
                      SliverImplicitlyAnimatedList<FileState>(
                        items: state.data!.files,
                        itemBuilder: (context, animation, item, index) =>
                            SizeFadeTransition(
                          sizeFraction: 0.7,
                          curve: Curves.easeInOut,
                          animation: animation,
                          child: FileWidget(
                            directory: state.data!.directory!,
                            file: item.file,
                            isDir: item.isDirectory,
                            changed: item.changed,
                            onRemove: () {
                              listRefreshKey.value = Object();
                            },
                          ),
                        ),
                        areItemsTheSame: (a, b) => a?.file.path == b?.file.path,
                        spawnIsolate: true,
                      ),
                    ],
                  );
                else
                  child = Empty();
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: child,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
