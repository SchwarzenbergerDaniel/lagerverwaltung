import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lagerverwaltung/page/settings/setting_tile.dart';
import 'package:lagerverwaltung/widget/custom_leading_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Einstellungen'),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        leading: CustomBackButton(),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            //TODO: Actual Content
            createSettingTile(
                "Account", Icons.person, Center(child: Text("Account-Page"))),
            createSettingTile("Mail-Empfänger", Icons.mail,
                Center(child: Text("Mail-Empfänger"))),
          ],
        ),
      ),
    );
  }

  SettingTile createSettingTile(
      String bezeichnung, IconData icon, Widget page) {
    return SettingTile(
      bezeichnung: bezeichnung,
      icon: Icon(icon),
      page: page,
    );
  }
}
