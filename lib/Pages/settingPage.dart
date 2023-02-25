import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingPage extends StatefulWidget {
  SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool toggleValue = false;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: SettingsList(
          brightness: Brightness.dark,
          darkTheme: SettingsThemeData(
            settingsListBackground: Color(0xFF1E1E1E),
            settingsSectionBackground: Color(0xFF1E1E1E),
          ),
          sections: [
            SettingsSection(
              title: Text('Common'),
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  leading: Icon(Icons.language),
                  title: Text('Language'),
                  value: Text('English'),
                ),
                SettingsTile.switchTile(
                  initialValue: true,
                  onToggle: (value) {
                    toggleValue = value;
                    setState(() {
                      toggleValue;
                    });
                  },
                  onPressed: (contex) {
                    setState(() {
                      toggleValue;
                    });
                  },
                  //initialValue: toggleValue,
                  leading: Icon(Icons.format_paint),
                  title: Text('Enable custom theme'),
                ),
              ],
            ),
            SettingsSection(
              title: Text('Account'),
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  leading: Icon(Icons.phone),
                  title: Text('Phone Number'),
                ),
                SettingsTile.navigation(
                  leading: Icon(Icons.email),
                  title: Text('Email'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
