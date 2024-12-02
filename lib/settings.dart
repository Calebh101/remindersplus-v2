import 'package:flutter/material.dart';
import 'package:personal/dialogue.dart';
import 'package:personal/widgets.dart';
import 'package:remindersplus/var.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AboutSettings(
              context: context,
              version: version,
              beta: beta,
              about: about,
            ),
            SettingTitle(title: "Reset"),
            Setting(
              title: "Reset All Data",
              desc: "Resets all data and settings. This cannot be undone.",
              action: () async {
                try {
                  bool result = await showConfirmDialogue(context, "Are you sure?", "This will erase all settings, reminders, and data from the app. This cannot be undone.") ?? false;
                  if (result) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    print('data cleared');
                  }
                } catch (e) {
                  showAlertDialogue(context, "Something went wrong", "Unable to delete your data: Unable to clear SharedPreferences: $e", false, {"show": true, "text": e.toString()});
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}