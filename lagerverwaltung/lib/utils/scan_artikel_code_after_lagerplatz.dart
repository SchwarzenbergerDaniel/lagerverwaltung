// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/config/constants.dart';
import 'package:lagerverwaltung/model/lagerlistenentry.dart';
import 'package:lagerverwaltung/page/edit_artikel_page.dart';
import 'package:lagerverwaltung/service/codescanner_service.dart';
import 'package:lagerverwaltung/service/lagerlistenverwaltung_service.dart';
import 'package:lagerverwaltung/utils/showsnackbar.dart';

Future<void> scanArtikelCodeAfterLagerplatz(
    BuildContext context, String lagerplatzId) async {
  final codeScannerService = GetIt.instance<CodeScannerService>();
  final lagerListenVerwaltungsService =
      GetIt.instance<LagerlistenVerwaltungsService>();
  final scannedID =
      await codeScannerService.getCodeByScan(context, "Artikel Code scannen");

  if (scannedID != null) {
    if (scannedID == Constants.EXIT_RETURN_VALUE) {
      // Wenn man durch den Backarrow zurück will, soll kein Error kommen
      return;
    }

    if (await lagerListenVerwaltungsService.artikelGWIDExist(scannedID)) {
      LagerlistenEntry artikel =
          await lagerListenVerwaltungsService.getArtikelByGWID(scannedID);
      await Showsnackbar.showSnackBar(context,
          "Der Artikel existiert bereits - Sie werden zur Bearbeitungsseite weitergeleitet");
      await Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => EditArtikelPage(entry: artikel),
        ),
      );
    } else {
      await Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => EditArtikelPage(
                      entry: LagerlistenEntry(
                    lagerplatzId: lagerplatzId,
                    artikelGWID: scannedID,
                  ))));
    }
  } else {
    Showsnackbar.showSnackBar(context, "kein Code gefunden!");
  }
}
