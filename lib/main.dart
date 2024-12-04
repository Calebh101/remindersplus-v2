import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_navbar/quick_navbar.dart';
import 'package:remindersplus/home.dart';
import 'package:remindersplus/settings.dart';
import 'package:localpkg/theme.dart';

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
      theme: customTheme(darkMode: false, seedColor: Colors.lightBlue, textStyle: GoogleFonts.poppinsTextTheme()),
      darkTheme: customTheme(darkMode: true, seedColor: Colors.lightBlue),
      home: QuickNavBar(
        items: [
          {
            "label": "Home",
            "icon": FontAwesomeIcons.house,
            "widget": HomePage(),
          },{
            "label": "Settings",
            "icon": FontAwesomeIcons.gear,
            "widget": Settings(),
          },
        ], selectedColor: Colors.blue, sidebarBeta: true,
      ),
    );
  }
}