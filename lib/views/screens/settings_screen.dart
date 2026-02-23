import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            title: Text(
              'Appearance',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use a dark theme for the editor and UI'),
            secondary: const Icon(Icons.dark_mode),
            value: settings.themeMode == ThemeMode.dark,
            onChanged: (value) {
              settings.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          const Divider(),
          const ListTile(
            title: Text(
              'Editor Settings',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          ListTile(
            title: const Text('Font Size'),
            subtitle: Text('${settings.fontSize.toInt()} px'),
            leading: const Icon(Icons.format_size),
            trailing: SizedBox(
              width: 200,
              child: Slider(
                min: 10,
                max: 30,
                divisions: 20,
                label: settings.fontSize.toInt().toString(),
                value: settings.fontSize,
                onChanged: (value) {
                  settings.setFontSize(value);
                },
              ),
            ),
          ),
          const Divider(),
          const ListTile(
            title: Text(
              'About',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          const ListTile(
            title: Text('Offline Code Editor'),
            subtitle: Text('Version 1.0.0\nBuilt with Flutter & SQLite'),
            leading: Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }
}
