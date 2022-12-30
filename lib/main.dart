import 'package:flutter/material.dart';
import 'package:uas_mobile/pages/main_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
      theme: ThemeData(primarySwatch: Colors.green),
      darkTheme: ThemeData(
        primarySwatch: Colors.grey,
        primaryColor: Colors.black,
        brightness: Brightness.dark,
        dividerColor: Colors.black12,
      ),
      themeMode: ThemeMode.light,
    );
  }
}
