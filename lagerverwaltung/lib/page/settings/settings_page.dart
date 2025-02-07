import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lagerverwaltung/page/settings/change_logo/change_logo_page.dart';
import 'package:lagerverwaltung/page/settings/change_mail/change_mail_page.dart';
import 'package:lagerverwaltung/page/settings/csv_column_order/csv_column_order_changer_page.dart';
import 'package:lagerverwaltung/page/settings/send_mail/send_mail_page.dart';
import 'package:lagerverwaltung/page/settings/color_change/color_changing_page.dart';
import 'package:lagerverwaltung/page/settings/log_intervall/log_intervall_mail_page.dart';
import 'package:lagerverwaltung/page/settings/setting_tile.dart';
import 'package:lagerverwaltung/service/mailsender/google_auth_api.dart';
import 'package:lagerverwaltung/widget/custom_leading_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Einstellungen',
          style: CupertinoTheme.of(context).textTheme.textStyle,
        ),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        leading: CustomBackButton(),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            createHeading("Datenverwaltung"),
            createSettingTile("Export Spalten Reihenfolge ändern",
                Icons.exposure_outlined, CsvColumnOrderChangerPage()),
            createSettingTile(
                "Log Konfigurationen", Icons.timelapse, LogConigPage()),
            createHeading("Personalisierung"),
            createSettingTile(
                "Farbgebung", Icons.color_lens_outlined, ColorChangingPage()),
            createSettingTile("Logo ändern", Icons.design_services,
                ChangeLogoPage()), //TODO: Passendes ICON
            createHeading("E-Mail Verwaltung"),
            createSettingTile("Mail-Empfänger", Icons.mail_outline,
                EMailEmpfaengerAendernPage()),
            createSettingTile("Mail versenden", Icons.mail, SendMailPage()),
            createGoogleAuthorizeButton(),
          ],
        ),
      ),
    );
  }

  Widget createHeading(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.systemGrey,
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

  Widget createGoogleAuthorizeButton() {
    return SettingTile(
        bezeichnung: "Mail-Sender wechseln",
        icon: Icon(Icons.change_circle),
        onTap: () async => await GoogleAuthApi.changeUser());
  }
}
