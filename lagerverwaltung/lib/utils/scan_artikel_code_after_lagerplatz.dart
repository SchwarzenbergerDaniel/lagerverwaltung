import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/config/constants.dart';
import 'package:lagerverwaltung/model/LagerlistenEntry.dart';
import 'package:lagerverwaltung/page/artikel_page.dart';
import 'package:lagerverwaltung/service/codescanner_service.dart';
import 'package:lagerverwaltung/service/lagerlistenverwaltung_service.dart';
import 'package:lagerverwaltung/widget/showsnackbar.dart';

Future<void> scanArtikelCodeAfterLagerplatz(BuildContext context, String lagerplatzId) async {
  final codeScannerService = GetIt.instance<CodeScannerService>();
  final lagerListenVerwaltungsService = GetIt.instance<LagerlistenVerwaltungsService>();
  final scannedID = await codeScannerService.getCodeByScan(context);

  if (scannedID != null) {
    if (scannedID == Constants.EXIT_RETURN_VALUE) {
      // Wenn man durch den Backarrow zurück will, soll kein Error kommen
      return;
    }

    if (lagerListenVerwaltungsService.artikelGWIDExist(scannedID)) {
      LagerListenEntry artikel =
          lagerListenVerwaltungsService.getArtikelByGWID(scannedID);

      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => ArtikelPage(entry: artikel),
        ),
      );
    } else {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => ArtikelPage(
            entry: LagerListenEntry(
              lagerplatzId: lagerplatzId,
              artikelGWID: scannedID,
            ),
          ),
        ),
      );
    }
  } else {
    Showsnackbar.showSnackBar(context, "kein Code gefunden!");
  }
}