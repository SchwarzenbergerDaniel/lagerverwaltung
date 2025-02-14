// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/buttons/base/primary_button_base.dart';
import 'package:lagerverwaltung/config/constants.dart';
import 'package:lagerverwaltung/page/lagerliste_page.dart';
import 'package:lagerverwaltung/widget/lagerplatz_code_scanned_modal.dart';
import 'package:lagerverwaltung/service/codescanner_service.dart';
import 'package:lagerverwaltung/service/lagerlistenverwaltung_service.dart';
import 'package:lagerverwaltung/utils/showsnackbar.dart';
import 'package:lagerverwaltung/utils/scan_artikel_code_after_lagerplatz.dart';

class ScanLagerplatzButton extends StatelessWidget {
  ScanLagerplatzButton({super.key});
  final codeScannerService = GetIt.instance<CodeScannerService>();
  final lagerListenVerwaltungsService =
      GetIt.instance<LagerlistenVerwaltungsService>();

  @override
  Widget build(BuildContext context) {
    return PrimaryButtonBase(
        title: "Lagerplatz\nScannen",
        accentColor: Color.fromRGBO(131, 166, 241, 1),
        onPressed: () => scanLagerplatz(context));
  }

  void scanLagerplatz(BuildContext context) async {
    final scannedID = await codeScannerService.getCodeByScan(
        context, "Lagerplatz Code scannen");

    if (scannedID != null) {
      if (scannedID == Constants.EXIT_RETURN_VALUE) {
        //When backarrow is clicked
        return;
      }

      if (await lagerListenVerwaltungsService.lagerplatzExist(scannedID)) {
        // Lagerplatz existiert bereits.
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => LagerlistePage(
                      lagerplatzId: scannedID,
                    )));
      } else {
        final result = await NewLagerplatzCodeScannedModal.showActionSheet(
            context, scannedID);
        if (result == true) {
          lagerListenVerwaltungsService.addEmptyLagerplatz(scannedID);
          scanArtikelCodeAfterLagerplatz(context, scannedID);
        } else if (result == false) {
          lagerListenVerwaltungsService.addEmptyLagerplatz(scannedID);
          Showsnackbar.showSnackBar(context, "Lagerplatz wurde hinzugefügt!");
        }
      }
    } else {
      Showsnackbar.showSnackBar(context, "kein Code gefunden!");
    }
  }
}
