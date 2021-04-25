import 'dart:io';

import 'package:sentry_flutter/sentry_flutter.dart';

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

