import 'dart:ui';

import 'package:flutter/material.dart';

class TextLight extends Text {
  const TextLight(
    String data, {
    Key? key,
  }) : super(
          data,
          key: key,
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w300,
          ),
        );
}
