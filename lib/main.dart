import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uSpace/views/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparent status bar
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'uSpace',
      theme: lightTheme,
      // Provide light theme.
      darkTheme: ThemeData.dark(),
      // Provide dark theme.
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
