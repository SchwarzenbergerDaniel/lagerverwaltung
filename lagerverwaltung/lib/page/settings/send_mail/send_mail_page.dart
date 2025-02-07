import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/config/errormessage_constants.dart';
import 'package:lagerverwaltung/service/csv_converter_service.dart';
import 'package:lagerverwaltung/service/lagerlistenverwaltung_service.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';
import 'package:lagerverwaltung/service/logger/logger_service.dart';
import 'package:lagerverwaltung/service/mailsender/mailsender_service.dart';
import 'package:lagerverwaltung/utils/loading_dialog.dart';
import 'package:lagerverwaltung/utils/showsnackbar.dart';
import 'package:lagerverwaltung/widget/custom_leading_button.dart';

class SendMailPage extends StatelessWidget {
  SendMailPage({super.key});

  final mailSenderService = GetIt.instance<MailSenderService>();
  final lagerListenVerwaltungsService =
      GetIt.instance<LagerlistenVerwaltungsService>();
  final localSettingsManagerService =
      GetIt.instance<LocalSettingsManagerService>();
  final fileConverterService = GetIt.instance<FileConverterService>();
  final loggerService = GetIt.instance<LoggerService>();

  void send_abgelaufen_liste(BuildContext context) async {
    LoadingDialog.showLoadingDialog(context, "Liste wird versendet...");
    final abgelaufen =
        await lagerListenVerwaltungsService.getAbgelaufeneArtikel();

    if (abgelaufen.isEmpty) {
      LoadingDialog.hideLoadingDialog(context);
      Showsnackbar.showSnackBar(context,
          "Gute Nachrichten: Es wurden keine abgelaufenen Artikel gefunden!");
      return;
    }

    bool success = await mailSenderService.sendAbgelaufen(
        abgelaufen, localSettingsManagerService.getMail());

    LoadingDialog.hideLoadingDialog(context);
    if (success) {
      Showsnackbar.showSnackBar(context,
          "Alle abgelaufenen Artikel wurden an ${localSettingsManagerService.getMail()} versendet!");
    } else {
      Showsnackbar.showSnackBar(context, ErrorMessageConstants.MAIL_FAILED);
    }
  }

  void send_lagerliste_backup(BuildContext context) async {
    LoadingDialog.showLoadingDialog(context, "Backup wird versendet...");

    bool success = await mailSenderService.sendLagerListe(
        await fileConverterService
            .toCsv(await lagerListenVerwaltungsService.artikelEntries),
        localSettingsManagerService.getMail(),
        false);

    LoadingDialog.hideLoadingDialog(context);
    if (success) {
      Showsnackbar.showSnackBar(context,
          "Ein Backup der Lagerliste wurde an ${localSettingsManagerService.getMail()} versendet!");
    } else {
      Showsnackbar.showSnackBar(context, ErrorMessageConstants.MAIL_FAILED);
    }
  }

  void send_log_list(BuildContext context) async {
    LoadingDialog.showLoadingDialog(
        context, "Aktivitätsliste wird versendet...");

    bool success = await mailSenderService.sendLogs(
        await loggerService.getLogs(),
        localSettingsManagerService.getMail(),
        false);

    LoadingDialog.hideLoadingDialog(context);
    if (success) {
      Showsnackbar.showSnackBar(context,
          "Die Aktivitätsliste wurde an ${localSettingsManagerService.getMail()} versendet!");
    } else {
      Showsnackbar.showSnackBar(context, ErrorMessageConstants.MAIL_FAILED);
    }
  }

  void send_mindestmenge_artikel(BuildContext context) async {
    LoadingDialog.showLoadingDialog(
        context, "Abgelaufene Artikel werden versendet...");
    final artikel = await lagerListenVerwaltungsService.getAbgelaufeneArtikel();

    if (artikel.isEmpty) {
      LoadingDialog.hideLoadingDialog(context);
      Showsnackbar.showSnackBar(context,
          "Gute Nachrichten: Kein Artikel hat die Mindestmenge erreicht");
      return;
    }

    await mailSenderService.sendMindestmengeListe(
        artikel, localSettingsManagerService.getMail());

    LoadingDialog.hideLoadingDialog(context);
    Showsnackbar.showSnackBar(context,
        "Alle Artikel, deren Mindestmenge erreicht wurde, wurden an ${localSettingsManagerService.getMail()} versendet!");
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CustomBackButton(),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        middle: Text(
          'Mail verschicken',
          style: CupertinoTheme.of(context).textTheme.textStyle,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildButton(
                      context,
                      onPressed: () => send_abgelaufen_liste(context),
                      text: 'Abgelaufene Artikel senden',
                      icon: Icons.warning_amber_rounded,
                    ),
                    _buildButton(
                      context,
                      onPressed: () => send_lagerliste_backup(context),
                      text: 'Lagerlisten-Backup senden',
                      icon: Icons.cloud_upload,
                    ),
                    _buildButton(
                      context,
                      onPressed: () => send_log_list(context),
                      text: 'Aktivitäts-Liste senden',
                      icon: Icons.list_alt,
                    ),
                    _buildButton(
                      context,
                      onPressed: () => send_mindestmenge_artikel(context),
                      text: 'Artikel mit erreichter Mindestmenge',
                      icon: Icons.shopping_cart,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required VoidCallback onPressed,
      required String text,
      required IconData icon}) {
    return SizedBox(
      width: 200,
      height: 55,
      child: CupertinoButton.filled(
        onPressed: onPressed,
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: CupertinoColors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                softWrap: true,
                overflow: TextOverflow.visible,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
