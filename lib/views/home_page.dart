import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http_server/http_server.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:uSpace/views/about.dart';

enum ServerType { starting, running, uploading, stopped, error }

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? localIP;
  String serverText = '';

  bool serverEnable = false;
  late HttpServer server;
  List<FileSystemEntity> files = [];
  int filesCount = 0;
  List<Widget>? filesListWidget;
  late Directory directory;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    _statusText(ServerType.starting);
    _getLocalFiles();
    await Future.delayed(Duration(milliseconds: 600));
    localIP = await _getLocalIpAddress();
    await _httpServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
              icon: Icon(Ionicons.help_outline),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AboutPage()));
              })
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            textLight('Status:'),
            Text(
              serverText,
              style: TextStyle(height: 1.5, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            textLight('Server:'),
            if (localIP != null) textLeftRight('$localIP:8020', callback: _copy),
            if (localIP == null) Text('...'),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 8),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  if (filesListWidget != null) textLight('Files ($filesCount)'),
                  if (filesListWidget != null) ...filesListWidget!,
                  if (filesListWidget != null && filesCount == 0) _noFiles(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _copy() {
    var url = 'http://$localIP:8020';
    Clipboard.setData(ClipboardData(text: url));
    Share.share(url);
  }

  Widget _noFiles() {
    return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 50, 0, 8),
            child: SizedBox(
              width: 96,
              height: 96,
              child: Image.asset('assets/empty.png'),
            ),
          ),
        ),
        Text(
          'No Files',
          style: TextStyle(height: 1.5, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        textLight('Open web and upload your files.'),
      ],
    );
  }

  Widget textLight(String text) {
    return Text(text, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w300));
  }

  Widget _fileWidget(FileSystemEntity file, {required VoidCallback callback}) {
    final filename = file.path.replaceAll(directory.path + '/', '');
    final mimeType = lookupMimeType(file.path);
    IconData icon = Ionicons.document_outline;
    Color listColor = Theme.of(context).primaryIconTheme.color!;
    Color bgColor = listColor.withAlpha(5);

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

    return GestureDetector(
      onTap: callback,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, color: listColor, size: 16),
                SizedBox(width: 8),
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 150),
                  child: Text(
                    filename,
                    style: TextStyle(fontWeight: FontWeight.w500, height: 1),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Spacer(),
                textLight(filesize(File(file.path).lengthSync())),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget textLeftRight(String title, {VoidCallback? callback}) {
    return GestureDetector(
      onTap: () {
        callback?.call();
      },
      child: Row(
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
            child: Text(
              title,
              style: TextStyle(height: 1.5, fontWeight: FontWeight.w600),
            ),
          ),
          Spacer(),
          Icon(Ionicons.copy_outline, size: 16)
        ],
      ),
    );
  }

  void _statusText(ServerType status) {
    setState(() {
      switch (status) {
        case ServerType.starting:
          serverText = 'Starting';
          break;
        case ServerType.running:
          serverText = 'Running';
          break;
        case ServerType.uploading:
          serverText = 'Uploading';
          break;
        case ServerType.stopped:
          serverText = 'Stoping';
          break;
        case ServerType.error:
          serverText = 'Error, Try reboot app';
          break;
        default:
          serverText = 'unknow';
      }
    });
  }

  _fileAction(FileSystemEntity file) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) => SafeArea(child: _buttomSheet(ctx, file)),
    );
  }

  _buttomSheet(BuildContext context, FileSystemEntity file) {
    final stat = FileStat.statSync(file.path);
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
                        style: TextStyle(fontWeight: FontWeight.bold, height: 1.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${filesize(File(file.path).lengthSync())} - ${f.format(stat.changed)}',
                      style: TextStyle(fontWeight: FontWeight.w400, height: 1.5, fontSize: 12, color: Theme.of(context).textTheme.headline1!.color),
                    ),
                  ],
                ),
                Spacer(),
                SizedBox(
                  height: 48,
                  width: 48,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryIconTheme.color!.withAlpha(10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(Ionicons.trash_outline),
                      iconSize: 20,
                      onPressed: () {
                        Navigator.pop(context);
                        _remove(file, name);
                      },
                    ),
                  ),
                )
              ],
            ),

            // SizedBox(
            //   width: double.infinity,
            //   child: Padding(
            //     padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            //     child: Container(
            //       decoration: BoxDecoration(
            //         color: Theme.of(context).primaryIconTheme.color.withAlpha(10),
            //         borderRadius: BorderRadius.circular(8),
            //       ),
            //       padding: EdgeInsets.all(8),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text(
            //             'Changed Time',
            //             style: TextStyle(
            //               fontWeight: FontWeight.bold,
            //               height: 1.5,
            //             ),
            //             maxLines: 1,
            //             overflow: TextOverflow.ellipsis,
            //           ),
            //           Text(
            //             f.format(stat.changed),
            //             style: TextStyle(
            //               fontWeight: FontWeight.w400,
            //               height: 1.5,
            //               color: Theme.of(context).textTheme.bodyText1.color.withAlpha(75),
            //             ),
            //             maxLines: 2,
            //             overflow: TextOverflow.ellipsis,
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ButtonTheme(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  _remove(FileSystemEntity file, String name) async {
    final OkCancelResult result = await showOkCancelAlertDialog(context: context, title: 'Delete', message: name);
    if (result == OkCancelResult.ok) {
      file.deleteSync();
      _getLocalFiles();
    }
  }

  _getLocalFiles() async {
    filesCount = 0;
    directory = await getApplicationDocumentsDirectory();
    files = directory.listSync(recursive: false).toList();
    filesListWidget = List.generate(files.length, (index) {
      if (!FileSystemEntity.isDirectorySync(files[index].path)) {
        final filename = files[index].path.replaceAll(directory.path + '/', '');
        if (!filename.startsWith('res_timestamp')) {
          filesCount = filesCount + 1;
          return _fileWidget(
            files[index],
            callback: () {
              _fileAction(files[index]);
            },
          );
        }
      }
      return Container();
    });

    setState(() {});
  }

  Future<String?> _getLocalIpAddress() async {
    final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4, includeLinkLocal: true);

    try {
      // Try VPN connection first
      NetworkInterface vpnInterface = interfaces.firstWhere((element) => element.name == "tun0");
      return vpnInterface.addresses.first.address;
    } on StateError {
      // Try wlan connection next
      try {
        NetworkInterface interface = interfaces.firstWhere((element) => element.name == "wlan0");
        return interface.addresses.first.address;
      } catch (ex) {
        // Try any other connection next
        try {
          NetworkInterface interface = interfaces.firstWhere((element) => !(element.name == "tun0" || element.name == "wlan0"));
          return interface.addresses.first.address;
        } catch (ex) {
          return null;
        }
      }
    }
  }

  Future _httpServer() async {
    bool foundFile = false;

    try {
      server = await HttpServer.bind('0.0.0.0', 8020);
    } catch (e) {
      _statusText(ServerType.error);
      setState(() {
        serverEnable = false;
      });

      return;
    }

    _statusText(ServerType.running);
    setState(() {
      serverEnable = true;
    });

    print('Server running');
    server.transform(HttpBodyHandler()).listen((HttpRequestBody body) async {
      print('Request URI ... ${body.request.uri.toString()}');
      switch (body.request.uri.toString()) {
        case '/upload':
          if (body.type != "form") {
            _http(body, 400);
            return;
          }

          for (var key in body.body.keys.toSet()) {
            if (key == "file") {
              foundFile = true;
            }
          }

          if (!foundFile) {
            _http(body, 400);
            return;
          }

          _statusText(ServerType.uploading);
          HttpBodyFileUpload data = body.body['file'];
          print(data.content.runtimeType);
          // Save file
          final directory = await getApplicationDocumentsDirectory();
          File fFile = File('${directory.path}/${data.filename}');
          print('${data.filename}');

          if (data.content.runtimeType == String) {
            fFile.writeAsStringSync(data.content, mode: FileMode.write);
          } else {
            fFile.writeAsBytesSync(data.content, mode: FileMode.write);
          }

          _statusText(ServerType.running);
          _http(body, 201);

          break;
        case '/':
          String _content = await rootBundle.loadString('assets/upload.html');
          body.request.response.statusCode = 200;
          body.request.response.headers.set("Content-Type", "text/html; charset=utf-8");
          body.request.response.write(_content);
          body.request.response.close();
          break;

        default:
          _http(body, 404);
      }
    });
  }

  _http(HttpRequestBody body, int code) {
    switch (code) {
      case 400:
        body.request.response.statusCode = 400;
        body.request.response.close();
        break;
      case 404:
        body.request.response.statusCode = 404;
        body.request.response.write('Not found');
        body.request.response.close();
        break;
      case 201:
        body.request.response.statusCode = 201;
        body.request.response.write("Upload DONE");
        body.request.response.close();

        _getLocalFiles();
        break;
      default:
    }
  }
}
