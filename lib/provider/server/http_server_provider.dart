import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:equatable/equatable.dart';

enum ServerStatus {
  starting,
  running,
  uploading,
  error,
}

class ServerState with EquatableMixin {
  ServerState({
    required this.serverStatus,
    this.uploadingFilePathSet = const {},
  });

  ServerStatus serverStatus;
  Set<String> uploadingFilePathSet;

  ServerStatus get status =>
      uploadingFilePathSet.isNotEmpty ? ServerStatus.uploading : serverStatus;

  @override
  List<Object?> get props => [
        serverStatus,
        uploadingFilePathSet,
      ];
}

class HttpServerProvider extends ValueNotifier<ServerState> {
  HttpServerProvider(this.port)
      : super(ServerState(serverStatus: ServerStatus.starting)) {
    _initHttpServer();
  }

  final int port;
  HttpServer? server;
  late Directory directory;

  Future<void> _initHttpServer() async {
    directory = await getApplicationDocumentsDirectory();

    try {
      var router = Router()
        ..get('/', _home)
        ..post('/upload', _upload);

      server = await serve(router, '0.0.0.0', port);

      value.serverStatus = ServerStatus.running;
      notifyListeners();
    } catch (e) {
      value.serverStatus = ServerStatus.error;
      notifyListeners();
    }
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

      final filePath = file.path;

      value.uploadingFilePathSet.add(filePath);
      notifyListeners();

      try {
        final fileSink = file.openWrite();
        await part.timeout(const Duration(seconds: 2)).pipe(fileSink);
        await fileSink.close();

        return Response(201, body: 'Upload DONE');
      } catch (_) {
        await file.delete();
      } finally {
        value.uploadingFilePathSet.remove(filePath);
        notifyListeners();
      }
    }
    return Response(400);
  }
}
