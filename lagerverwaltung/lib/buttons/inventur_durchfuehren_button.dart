import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/buttons/base/primary_button_base.dart';
import 'package:lagerverwaltung/page/inventur_page.dart';
import 'package:lagerverwaltung/config/constants.dart';
import 'package:lagerverwaltung/utils/showdialog.dart';
import 'package:lagerverwaltung/service/codescanner_service.dart';
import 'package:lagerverwaltung/service/lagerlistenverwaltung_service.dart';

class InventurDurchfuehrenButton extends StatelessWidget {
  InventurDurchfuehrenButton({super.key});
  final codeScannerService = GetIt.instance<CodeScannerService>();
  final lagerListenVerwaltungsService =
      GetIt.instance<LagerlistenVerwaltungsService>();

  @override
  Widget build(BuildContext context) {
    return PrimaryButtonBase(
        title: "Inventur durchführen",
        accentColor: Color.fromRGBO(135, 241, 211, 1),
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
      if (scannedLagerplatz == Constants.EXIT_RETURN_VALUE ||
          scannedLagerplatz == null) {
        return;
      }

      if (!await lagerListenVerwaltungsService
          .lagerplatzExist(scannedLagerplatz!)) {
        scanNew = await ShowDialogTwoOptions.isFirstOptionClicked(
            context,
            "Lagerplatz nicht gefunden",
            "Wie möchten Sie fortfahren?",
            "Lagerplatz erneut scannen",
            "Inventur beenden",
            isFirstDefaultAction: false);
        if (scanNew == false) {
          return;
        }
      }
    } while (scanNew);
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => InventurPage(lagerplatzId: scannedLagerplatz!),
      ),
    );
  }
}
