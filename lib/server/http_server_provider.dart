import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http_server/http_server.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uSpace/server/server_status.dart';

Future<String?> getLocalIpAddress(int port) async {
  final interfaces = List<NetworkInterface?>.of(await NetworkInterface.list(
      type: InternetAddressType.IPv4, includeLinkLocal: true));

  // Try VPN connection first
  var interface = (interfaces.firstWhere((element) => element?.name == 'tun0',
          orElse: () => null) ??
      // Try wlan connection next
      interfaces.firstWhere((element) => element?.name == 'wlan0',
          orElse: () => null) ??
      // Try any other connection next
      interfaces.firstWhere((element) => true, orElse: () => null));

  return interface?.addresses.first.address;
}

class HttpServerProvider extends ValueNotifier<ServerStatus> {
  HttpServerProvider(this.port, this.onNew) : super(ServerStatus.starting) {
    _initHttpServer();
  }

  final int port;
  final VoidCallback onNew;
  HttpServer? server;

  Future<void> _initHttpServer() async {
    var foundFile = false;

    try {
      server = await HttpServer.bind('0.0.0.0', port);
    } catch (e) {
      value = ServerStatus.error;
      notifyListeners();
      return;
    }

    value = ServerStatus.running;
    notifyListeners();

    debugPrint('Server running');
    server?.transform(HttpBodyHandler()).listen((HttpRequestBody body) async {
      debugPrint('Request URI ... ${body.request.uri.toString()}');
      switch (body.request.uri.toString()) {
        case '/upload':
          if (body.type != 'form') {
            _http(body, 400);
            return;
          }

          for (var key in body.body.keys.toSet()) {
            if (key == 'file') {
              foundFile = true;
            }
          }

          if (!foundFile) {
            _http(body, 400);
            return;
          }

          value = ServerStatus.uploading;
          notifyListeners();

          HttpBodyFileUpload data = body.body['file'];
          debugPrint(data.content?.runtimeType.toString());
          // Save file
          final directory = await getApplicationDocumentsDirectory();
          var fFile = File('${directory.path}/${data.filename}');
          debugPrint('${data.filename}');

          if (data.content.runtimeType == String) {
            await fFile.writeAsString(data.content, mode: FileMode.write);
          } else {
            await fFile.writeAsBytes(data.content, mode: FileMode.write);
          }

          value = ServerStatus.running;
          notifyListeners();

          _http(body, 201);
          onNew();
          break;
        case '/':
          var _content = await rootBundle.loadString('assets/upload.html');
          body.request.response.statusCode = 200;
          body.request.response.headers
              .set('Content-Type', 'text/html; charset=utf-8');
          body.request.response.write(_content);
          await body.request.response.close();
          break;

        default:
          _http(body, 404);
      }
    });
  }

  void _http(HttpRequestBody body, int code) {
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
        body.request.response.write('Upload DONE');
        body.request.response.close();
        break;
      default:
    }
  }

  @override
  Future<void> dispose() async {
    await server?.close();
    super.dispose();
  }
}
