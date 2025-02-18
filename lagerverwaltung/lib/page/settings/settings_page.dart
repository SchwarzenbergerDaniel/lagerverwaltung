import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/page/settings/logs/log_page.dart';
import 'package:lagerverwaltung/page/settings/xlsx_column_order/xlsx_column_order_changer_page.dart';
import 'package:lagerverwaltung/page/settings/send_mail/send_mail_page.dart';
import 'package:lagerverwaltung/page/settings/color_change/color_changing_page.dart';
import 'package:lagerverwaltung/page/settings/log_intervall/log_intervall_mail_page.dart';
import 'package:lagerverwaltung/page/settings/setting_tile.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';
import 'package:lagerverwaltung/service/mailsender/google_auth_api.dart';
import 'package:lagerverwaltung/utils/dialog_number_input.dart';
import 'package:lagerverwaltung/utils/dialog_string_input.dart';
import 'package:lagerverwaltung/utils/showsnackbar.dart';
import 'package:lagerverwaltung/widget/background/animated_background.dart';
import 'package:lagerverwaltung/widget/custom_app_bar.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});
  final localSettingsManagerService =
      GetIt.instance<LocalSettingsManagerService>();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomAppBar(
        title: 'Einstellungen',
      ),
      child: AnimatedBackground(
        child: SafeArea(
          child: ListView(
            children: [
              createHeading("Datenverwaltung"),
              createSettingTile("Logs anzeigen", Icons.history, LogPage()),
              createSettingTile(
                  "Log-Einstellungen", Icons.tune, LogConfigPage()),
              createArtikelAbgelaufenSettingTile(context),
              createSettingTile("Export-Spalten anpassen", Icons.view_column,
                  XlsxColumnOrderChangerPage()),
              createHeading("Personalisierung"),
              createSettingTile(
                  "Farbschema ändern", Icons.palette, ColorChangingPage()),
              createHeading("E-Mail-Verwaltung"),
              createEMailEmpfaenger(context),
              createSettingTile("E-Mail senden", Icons.send, SendMailPage()),
              createGoogleAuthorizeButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget createEMailEmpfaenger(BuildContext context) {
    return SettingTile(
      bezeichnung: "Empfänger verwalten",
      icon: Icon(Icons.people_alt),
      onTap: () async {
        String? newMail = await DialogStringInput.getString(
            context,
            "Empfänger E-Mail",
            "E-Mail eingeben...",
            localSettingsManagerService.getMail());

        if (newMail != null) {
          localSettingsManagerService.setMail(newMail);
        } else {
          Showsnackbar.showSnackBar(
            context,
            "Daten wurden nicht verändert!",
          );
        }
      },
    );
  }

  Widget createArtikelAbgelaufenSettingTile(BuildContext context) {
    return SettingTile(
      bezeichnung: "Vorzeitige Erinnerung abgelaufener Artikel",
      icon: Icon(Icons.event_busy),
      onTap: () async {
        int? reminderDays = await DialogNumberInput.getNumber(
          context,
          "Vorzeitige Erinnerung abgelaufener Artikel",
          "Tage vor Erreichen des Ablaufdatums erinnern:",
          localSettingsManagerService.getAbgelaufenReminderInDays(),
        );

        if (reminderDays != null) {
          localSettingsManagerService.setAbgelaufenReminderInDays(reminderDays);
        } else {
          Showsnackbar.showSnackBar(
            context,
            "Daten wurden nicht verändert!",
          );
        }
      },
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
