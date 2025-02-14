import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/buttons/base/primary_button_base.dart';
import 'package:lagerverwaltung/config/constants.dart';
import 'package:lagerverwaltung/model/lagerlistenentry.dart';
import 'package:lagerverwaltung/page/edit_artikel_page.dart';
import 'package:lagerverwaltung/service/codescanner_service.dart';
import 'package:lagerverwaltung/service/lagerlistenverwaltung_service.dart';
import 'package:lagerverwaltung/utils/showdialog.dart';

class ScanArtikelButton extends StatelessWidget {
  const ScanArtikelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimaryButtonBase(
        title: "Artikel\nScannen",
        accentColor: Color.fromRGBO(211, 153, 241, 1),
        onPressed: () => scanArtikel(context));
  }

  void scanArtikel(BuildContext context) async {
    final codeScannerService = GetIt.instance<CodeScannerService>();
    final lagerListenVerwaltungsService =
        GetIt.instance<LagerlistenVerwaltungsService>();

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
          builder: (context) => EditArtikelPage(
            entry: entry,
            isEditable: true,
          ),
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

      if (addNew) {
        // Lagerplatz-ID scannen

        bool scanNew = false;
        String? scannedLagerplatz;
        do {
          scannedLagerplatz = await codeScannerService.getCodeByScan(
            context,
            "Lagerplatz-ID scannen",
          );

          if (scannedLagerplatz == null ||
              scannedLagerplatz == Constants.EXIT_RETURN_VALUE) {
            return;
          }

          if (!await lagerListenVerwaltungsService
              .lagerplatzExist(scannedLagerplatz)) {
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

        // Zur `EditArtikelPage`, um neuen Artikel zu erstellen
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => EditArtikelPage(
              entry: LagerlistenEntry(
                artikelGWID: artikelGWID,
                lagerplatzId: scannedLagerplatz,
              ),
              isEditable: true,
            ),
          ),
        );
      }
    }
  }
}
