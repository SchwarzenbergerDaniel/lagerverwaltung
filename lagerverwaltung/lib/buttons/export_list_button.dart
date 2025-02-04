import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/buttons/home_page_button_base.dart';
import 'package:lagerverwaltung/service/csv_converter_service.dart';
import 'package:lagerverwaltung/service/lagerlistenverwaltung_service.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';
import 'package:lagerverwaltung/service/mailsender/mailsender_service.dart';
import 'package:lagerverwaltung/widget/showsnackbar.dart';

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
    return HomePageButtonBase(
        title: "Liste exportieren",
        icon: Icons.file_download,
        backgroundColor: Color.fromRGBO(233, 175, 134, 1),
        onPressed: () => export(context));
  }

  void export(BuildContext context) async {
    mailSenderService.sendLagerListe(
        await fileConverterService
            .toCsv(await lagerListenVerwaltungsService.artikelEntries),
        localSettingsManagerService.getMail(),
        false);
    Showsnackbar.showSnackBar(context,
        "Lagerliste exportiert an ${localSettingsManagerService.getMail()}");
  }
}
