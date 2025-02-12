import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/page/inventur_page.dart';
import 'package:lagerverwaltung/config/constants.dart';
import 'package:lagerverwaltung/utils/showdialog.dart';
import 'package:lagerverwaltung/buttons/home_page_button_base.dart';
import 'package:lagerverwaltung/service/codescanner_service.dart';
import 'package:lagerverwaltung/service/lagerlistenverwaltung_service.dart';

class InventurDurchfuehrenButton extends StatelessWidget {
  InventurDurchfuehrenButton({super.key});
  final codeScannerService = GetIt.instance<CodeScannerService>();
  final lagerListenVerwaltungsService = GetIt.instance<LagerlistenVerwaltungsService>();

  @override
  Widget build(BuildContext context) {
    return HomePageButtonBase(
        title: "Inventur durchführen",
        icon: Icons.assignment,
        backgroundColor: Color.fromRGBO(135, 241, 211, 1),
        onPressed: () => inventurDurchfuehren(context));
  }

  void inventurDurchfuehren(BuildContext context) async {
    // Lagerplatz-ID scannen

        bool scanNew = false;
        String? scannedLagerplatz;
        do {
          scannedLagerplatz = await codeScannerService.getCodeByScan(
            context,
            "Lagerplatz-ID scannen",
          );

          if (!await lagerListenVerwaltungsService
              .lagerplatzExist(scannedLagerplatz!)) {
            scanNew = await ShowDialogTwoOptions.isFirstOptionClicked(
                context,
                "Lagerplatz nicht gefunden",
                "Wie möchten Sie fortfahren?",
                "Lagerplatz erneut scannen",
                "Gescannten Lagerplatz anlegen",
                isFirstDefaultAction: false);
            if (scanNew == false) {
              lagerListenVerwaltungsService
                  .addEmptyLagerplatz(scannedLagerplatz);
            }
          }
        } while (scanNew);

      // Artikel-Code scannen
    final artikelGWID =
        await codeScannerService.getCodeByScan(context, "Artikel Code scannen");

    // Falls der Scan abgebrochen wird oder `EXIT_RETURN_VALUE`, abbrechen
    if (artikelGWID == null || artikelGWID == Constants.EXIT_RETURN_VALUE) {
      return;
    }

    if (await lagerListenVerwaltungsService.artikelGWIDExist(artikelGWID)) {
      final entry =
          await lagerListenVerwaltungsService.getArtikelByGWID(artikelGWID);
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => InventurPage(lagerplatzId: scannedLagerplatz!),
       ),
    );
    
    } else {
      // ArtikelGWID existiert nicht
      bool addNew = await ShowDialogTwoOptions.isFirstOptionClicked(
          context,
          "Artikel nicht gefunden",
          "Möchten Sie einen neuen Artikel hinzufügen?",
          "Ja",
          "Nein");
    }
  }
}
