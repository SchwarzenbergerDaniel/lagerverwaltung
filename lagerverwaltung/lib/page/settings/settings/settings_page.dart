import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lagerverwaltung/page/settings/change_mail/change_mail_page.dart';
import 'package:lagerverwaltung/page/settings/csv_column_order/csv_column_order_changer_page.dart';
import 'package:lagerverwaltung/page/settings/settings/color_changing_page.dart';
import 'package:lagerverwaltung/page/settings/log_intervall/log_intervall_mail_page.dart';
import 'package:lagerverwaltung/page/settings/settings/setting_tile.dart';
import 'package:lagerverwaltung/widget/custom_leading_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
            createSettingTile("Export Spalten Reihenfolge ändern",
                Icons.exposure_outlined, CsvColumnOrderChangerPage()),
            createSettingTile("Mail-Empfänger", Icons.mail_outline,
                EMailEmpfaengerAendernPage()),
            createSettingTile(
                "Farbgebung", Icons.color_lens_outlined, ColorChangingPage()),
            createSettingTile(
                "Log Konfigurationen", Icons.timelapse, LogConigPage())
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
