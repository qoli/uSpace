import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ionicons/ionicons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:tuple/tuple.dart';
import 'package:uSpace/server/http_server_provider.dart';
import 'package:uSpace/server/server_status.dart';
import 'package:uSpace/widget/empty.dart';
import 'package:uSpace/widget/file_widget.dart';
import 'package:uSpace/widget/text_light.dart';

import 'about.dart';

class HomePage extends HookWidget {
  HomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    var port = useState(8020);
    var listRefreshKey = useState(Object());
    var status = useValueListenable(useMemoized(
      () => HttpServerProvider(port.value, () {
        listRefreshKey.value = Object();
      }),
      [port.value],
    ));
    var filesTuple = useFuture(
      useMemoized(
        () async {
          final directory = await getApplicationDocumentsDirectory();
          var files = await directory.list().toList();

          var isDirectoryList = await Future.wait(
              files.map((e) => FileSystemEntity.isDirectory(e.path)));
          var asMap = isDirectoryList.asMap()
            ..removeWhere((key, value) => value);
          files = asMap.keys.map((e) => files[e]).toList();

          return Tuple2(directory, files);
        },
        [listRefreshKey.value],
      ),
      initialData: Tuple2(null, null),
    );
    var localIP = useFuture(
      useMemoized(
        () => getLocalIpAddress(port.value),
        [port.value],
      ),
      initialData: null,
    );
    var listCount = filesTuple.data?.item2?.length ?? 0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(Ionicons.help_outline),
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
              ServerStatusStringMap[status]!,
              style: const TextStyle(
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            TextLight('Server:'),
            GestureDetector(
              onTap: () {
                if (localIP.data == null) return;
                var url = 'http://$localIP:$port';
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
                      style:
                          TextStyle(height: 1.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Spacer(),
                  if (localIP.data != null)
                    Icon(Ionicons.copy_outline, size: 16)
                ],
              ),
            ),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 8),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: TextLight('Files ($listCount)')),
                  if (listCount > 0)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) => FileWidget(
                          directory: filesTuple.data!.item1!,
                          file: filesTuple.data!.item2![index],
                          onRemove: () {
                            listRefreshKey.value = Object();
                          },
                        ),
                        childCount: listCount,
                      ),
                    )
                  else
                    SliverToBoxAdapter(child: Empty()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
