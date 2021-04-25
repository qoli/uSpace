import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http_server/http_server.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:uSpace/provider/server/server_status.dart';

Future<String?> getLocalIpAddress(int port) async {
  String? ipAddress;

  final interfaces = List<NetworkInterface?>.of(await NetworkInterface.list(type: InternetAddressType.IPv4, includeLinkLocal: true));
  await Sentry.captureMessage(interfaces.toString());

  for (final interface in interfaces) {
    switch (interface?.name) {
      case 'en0':
      case 'wlan0':
        ipAddress = interface?.addresses.first.address;
        break;

      default:
    }
  }

  return ipAddress;
}

class HttpServerProvider extends ValueNotifier<ServerStatus> {
  HttpServerProvider(this.port) : super(ServerStatus.starting) {
    _initHttpServer();
  }

  final int port;
  HttpServer? server;

  Future<void> _initHttpServer() async {
    final directory = await getApplicationDocumentsDirectory();

    try {
      server = await HttpServer.bind('0.0.0.0', port);
    } catch (e) {
      value = ServerStatus.error;
      notifyListeners();
      return;
    }

    // try {
    //   final serverVD = await HttpServer.bind('0.0.0.0', port + 1);
    //   VirtualDirectory(directory.path)
    //     ..jailRoot = false
    //     ..followLinks = true
    //     ..allowDirectoryListing = true
    //     ..serve(serverVD);
    // } catch (e) {
    //   print(e);
    // }

    value = ServerStatus.running;
    notifyListeners();

    // vd

    debugPrint('Server running');
    server?.transform(HttpBodyHandler()).listen((HttpRequestBody body) async {
      debugPrint('Request URI ... ${body.request.uri.toString()}');
      switch (body.request.uri.toString()) {
        case '/upload':
          if (body.type != 'form') {
            _http(body, 400);
            return;
          }

          if (!body.body.keys.contains('file')) {
            _http(body, 400);
            return;
          }

          value = ServerStatus.uploading;
          notifyListeners();

          HttpBodyFileUpload data = body.body['file'];
          debugPrint(data.content?.runtimeType.toString());
          // Save file

          var file = File('${directory.path}/${data.filename}');
          var count = 1;
          while (await file.exists()) {
            file = File('${directory.path}/${count++}.${data.filename}');
          }
          debugPrint('${data.filename}');

          try {
            if (data.content.runtimeType == String) {
              await file.writeAsString(data.content, mode: FileMode.write);
            } else {
              await file.writeAsBytes(data.content, mode: FileMode.write);
            }

            value = ServerStatus.running;
            notifyListeners();

            _http(body, 201);

          } catch (e) {
            await file.delete();
            value = ServerStatus.error;
            notifyListeners();
            _http(body, 400);
          }
          break;

        case '/':
          final _content = await rootBundle.loadString('assets/upload.html');
          body.request.response.statusCode = 200;
          body.request.response.headers.set('Content-Type', 'text/html; charset=utf-8');
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
