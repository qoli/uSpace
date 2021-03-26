import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:uSpace/views/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparent status bar
  ));

  await SentryFlutter.init(
    (options) => options
      ..dsn = 'https://6c2ad9cb95f9412d837cc799aca8786e@o332403.ingest.sentry.io/5693358'
      ..debug = false,
    appRunner: () => runApp(MyApp()),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'uSpace',
      theme: lightTheme,
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const HomePage(title: 'uSpace'),
    );
  }

  ThemeData get lightTheme => ThemeData(
        primarySwatch: white,
        primaryTextTheme: const TextTheme(
          headline6: TextStyle(color: Colors.black87),
        ),
      );
}

const MaterialColor white = MaterialColor(
  0xFFFFFFFF,
  <int, Color>{
    50: Color(0xFFFFFFFF),
    100: Color(0xFFFFFFFF),
    200: Color(0xFFFFFFFF),
    300: Color(0xFFFFFFFF),
    400: Color(0xFFFFFFFF),
    500: Color(0xFFFFFFFF),
    600: Color(0xFFFFFFFF),
    700: Color(0xFFFFFFFF),
    800: Color(0xFFFFFFFF),
    900: Color(0xFFFFFFFF),
  },
);
