import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:uSpace/provider/file/file_provider.dart';
import 'package:uSpace/provider/server/http_server_provider.dart';
import 'package:uSpace/provider/server/server_status.dart';
import 'package:uSpace/utils/hook.dart';
import 'package:uSpace/widget/empty.dart';
import 'package:uSpace/widget/file_widget.dart';
import 'package:uSpace/widget/text_light.dart';

import 'about.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
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
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: _HomePage(),
        ),
      );
}

class _HomePage extends HookWidget {
  const _HomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final port = useState(8020);

    var fileProvider = useChangeNotifier(() => FileProvider());

    var httpServerProvider = useChangeNotifier(
      () => HttpServerProvider(port.value, () => fileProvider.refresh()),
      [port.value],
    );

    final status = useValueListenable(httpServerProvider);

    final fileState = useValueListenable(fileProvider);

    var connectivityResultStream = useStream(
      useMemoized(() => Connectivity().onConnectivityChanged),
      initialData: null,
    );
    final localIP = useMemoizedFuture(
      () => getLocalIpAddress(port.value),
      null,
      keys: [port.value, connectivityResultStream],
    );

    return ChangeNotifierProvider.value(
      value: fileProvider,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const TextLight('Status:'),
          Text(
            serverStatusStringMap[status]!,
            style: const TextStyle(
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          const TextLight('Server:'),
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
              if (fileState.fileCount > 0)
                child = CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                        child: TextLight('Files (${fileState.fileCount})')),
                    SliverImplicitlyAnimatedList<FileItem>(
                      items: fileState.files,
                      areItemsTheSame: (a, b) => a?.file.path == b?.file.path,
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
                        child: FileWidget(item: item),
                      ),
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
    );
  }
}
