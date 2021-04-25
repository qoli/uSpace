import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shelf/shelf_io.dart';
import 'package:uSpace/provider/server/server_status.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

Future<String?> getLocalIpAddress(int port) async {
  String? ipAddress;

  final interfaces = List<NetworkInterface?>.of(await NetworkInterface.list(
      type: InternetAddressType.IPv4, includeLinkLocal: true));
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
  late Directory directory;

  Future<void> _initHttpServer() async {
    directory = await getApplicationDocumentsDirectory();

    var router = Router()
      ..get('/', _home)
      ..post('/upload', _upload);

    server = await serve(router, '0.0.0.0', port);

    value = ServerStatus.running;
    notifyListeners();

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

    return;
  }

  @override
  Future<void> dispose() async {
    await server?.close();
    super.dispose();
  }

  Future<Response> _home(Request request) async {
    final _content = await rootBundle.loadString('assets/upload.html');
    return Response.ok(_content, headers: {
      'Content-Type': 'text/html; charset=utf-8',
    });
  }

  Future<Response> _upload(Request request) async {
    final contentType = request.headers['content-type'];
    if (contentType == null) return Response(400);
    var header = HeaderValue.parse(contentType);
    var boundary = header.parameters['boundary'];
    if (boundary == null) return Response(400);

    await for (final part in request
        .read()
        .cast<Uint8List>()
        .map((Uint8List event) => event.toList())
        .transform(MimeMultipartTransformer(boundary))) {
      final contentDisposition = part.headers['content-disposition'];
      if (contentDisposition == null) continue;
      header = HeaderValue.parse(contentDisposition);
      final filename = header.parameters['filename'];
      if (filename == null) continue;

      var file = File('${directory.path}/$filename');
      var count = 1;
      while (await file.exists()) {
        file = File('${directory.path}/${count++}.$filename');
      }

      value = ServerStatus.uploading;
      notifyListeners();

      var fileSink = file.openWrite();
      await part.pipe(fileSink);
      await fileSink.close();

      value = ServerStatus.running;
      notifyListeners();

      return Response(201, body: 'Upload DONE');
    }
    return Response(400);
  }
}
