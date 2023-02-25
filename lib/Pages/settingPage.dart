import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingPage extends StatefulWidget {
  SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child:Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search"
              ),
            ),
            SettingsList(
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
                  onToggle: (value) {},
                  initialValue: true,
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
          ],
        ), 
    );
  }
}
