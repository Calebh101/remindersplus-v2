import 'package:flutter/material.dart';
import 'package:quick_navbar/quick_navbar.dart';
import 'package:remindersplus/home.dart';
import 'package:remindersplus/settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reminders+',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light, // Explicitly specify light mode
        ),
        useMaterial3: true, // Enable Material 3
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark, // Explicitly specify dark mode
        ),
        useMaterial3: true, // Enable Material 3
      ),
      home: QuickNavBar(
        items: [
          {
            "label": "Home",
            "icon": Icons.home,
            "widget": HomePage(),
          },{
            "label": "Settings",
            "icon": Icons.settings,
            "widget": Settings(),
          },
        ], selectedColor: Colors.blue,
      ),
    );
  }
}