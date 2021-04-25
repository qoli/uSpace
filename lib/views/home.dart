import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:ionicons/ionicons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:uSpace/generated/l10n.dart';
import 'package:uSpace/provider/file_item.dart';
import 'package:uSpace/provider/server/http_server_provider.dart';
import 'package:uSpace/utils/address.dart';
import 'package:uSpace/utils/hook.dart';
import 'package:uSpace/widget/empty.dart';
import 'package:uSpace/widget/file_widget.dart';
import 'package:uSpace/widget/text_light.dart';
import 'package:watcher/watcher.dart';
import 'package:rxdart/rxdart.dart';

import 'about.dart';

class HomePage extends HookWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final port = useState(8020);

    final httpServerProvider = useChangeNotifier(
      () => HttpServerProvider(port.value),
      [port.value],
    );

    final state = useValueListenable(httpServerProvider);

    final watchEventStreamController =
        context.read<StreamController<WatchEvent>>();
    final watchEvent = useStream(
      useMemoizedFuture(
        () async => Rx.merge([
          watchEventStreamController.stream,
          DirectoryWatcher((await getApplicationDocumentsDirectory()).path)
              .events,
        ]),
        watchEventStreamController.stream,
      ).data,
      initialData: null,
    ).data;

    final fileState = useMemoizedFuture(
      () async {
        final directory = await getApplicationDocumentsDirectory();
        final files = await directory.list().toList();
        final list =
            await Future.wait(files.map((e) => e.toFileItem(directory)));
        list.sort((a, b) => b.changed.compareTo(a.changed));
        return FileState(
          directory,
          list,
          list.where((element) => !element.isDirectory).length,
        );
      },
      null,
      keys: [watchEvent?.type, watchEvent?.path, ...state.uploadingFilePathSet],
    ).data;

    final connectivityResult = useStream(
      useMemoized(() => Connectivity().onConnectivityChanged),
      initialData: null,
    ).data;

    final localIP = useMemoizedFuture(
      () => getLocalIpAddress(port.value),
      null,
      keys: [port.value, connectivityResult],
    );

    return Provider.value(
      value: fileState,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'uSpace',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              icon: const Icon(Ionicons.help_outline),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutPage(),
                ),
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TextLight('${L10n.of(context).status}: '),
              Text(
                {
                  ServerStatus.starting: L10n.of(context).starting,
                  ServerStatus.running: L10n.of(context).running,
                  ServerStatus.uploading: L10n.of(context).uploading,
                  ServerStatus.error: L10n.of(context).error,
                }[state.status]!,
                style: const TextStyle(
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              TextLight('${L10n.of(context).server}:'),
              GestureDetector(
                onTap: () {
                  if (localIP.data == null) return;
                  final url = 'http://${localIP.data}:${port.value}';
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
                  if (fileState != null && fileState.fileCount > 0)
                    child = CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                            child: TextLight(L10n.of(context)
                                .fileCount(fileState.fileCount))),
                        SliverImplicitlyAnimatedList<FileItem>(
                          items: fileState.files,
                          areItemsTheSame: (a, b) => a.file.path == b.file.path,
                          itemBuilder: (
                            BuildContext context,
                            Animation<double> animation,
                            FileItem item,
                            _,
                          ) =>
                              SizeFadeTransition(
                            sizeFraction: 0.7,
                            curve: Curves.easeInOut,
                            animation: animation,
                            child: FileWidget(
                              item: item,
                              uploading: state.uploadingFilePathSet
                                  .contains(item.file.path),
                            ),
                          ),
                        ),
                      ],
                    );
                  else
                    child = const Empty();
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: child,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
