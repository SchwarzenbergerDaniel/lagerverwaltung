import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/buttons/base/secondary_button_base.dart';
import 'package:lagerverwaltung/config/errormessage_constants.dart';
import 'package:lagerverwaltung/service/xlsx_converter_service.dart';
import 'package:lagerverwaltung/service/lagerlistenverwaltung_service.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';
import 'package:lagerverwaltung/service/mailsender/mailsender_service.dart';
import 'package:lagerverwaltung/utils/loading_dialog.dart';
import 'package:lagerverwaltung/utils/showsnackbar.dart';

class ExportListButton extends StatelessWidget {
  ExportListButton({super.key});
  final lagerListenVerwaltungsService =
      GetIt.instance<LagerlistenVerwaltungsService>();
  final mailSenderService = GetIt.instance<MailSenderService>();
  final fileConverterService = GetIt.instance<FileConverterService>();
  final localSettingsManagerService =
      GetIt.instance<LocalSettingsManagerService>();

  @override
  Widget build(BuildContext context) {
    return SecondaryButtonBase(
        title: "Liste exportieren",
        accentColor: Color.fromRGBO(233, 175, 134, 1),
        onPressed: () => export(context));
  }

  void export(BuildContext context) async {
    LoadingDialog.showLoadingDialog(context, "Backup wird versendet...");

    bool success = await mailSenderService.sendLagerListe(
        await fileConverterService
            .toXlsx(await lagerListenVerwaltungsService.artikelEntries),
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
}
