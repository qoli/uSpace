// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh';

  static m0(count) => "共 ${count} 个文件";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "about" : MessageLookupByLibrary.simpleMessage("关于"),
    "delete" : MessageLookupByLibrary.simpleMessage("删除"),
    "error" : MessageLookupByLibrary.simpleMessage("错误"),
    "fileCount" : m0,
    "githubProject" : MessageLookupByLibrary.simpleMessage("Github 项目"),
    "noFiles" : MessageLookupByLibrary.simpleMessage("没有文件"),
    "removeAllFiles" : MessageLookupByLibrary.simpleMessage("删除所有文件"),
    "running" : MessageLookupByLibrary.simpleMessage("运行中"),
    "server" : MessageLookupByLibrary.simpleMessage("服务器"),
    "share" : MessageLookupByLibrary.simpleMessage("分享"),
    "starting" : MessageLookupByLibrary.simpleMessage("启动中"),
    "status" : MessageLookupByLibrary.simpleMessage("状态"),
    "uploadFileDes" : MessageLookupByLibrary.simpleMessage("打开网址并上传文件。"),
    "uploading" : MessageLookupByLibrary.simpleMessage("上传中")
  };
}
