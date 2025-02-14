import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/buttons/base/primary_button_base.dart';
import 'package:lagerverwaltung/config/constants.dart';
import 'package:lagerverwaltung/model/lagerlistenentry.dart';
import 'package:lagerverwaltung/service/codescanner_service.dart';
import 'package:lagerverwaltung/service/lagerlistenverwaltung_service.dart';
import 'package:lagerverwaltung/utils/dialog_number_input.dart';
import 'package:lagerverwaltung/utils/showdialog.dart';
import 'package:lagerverwaltung/utils/showsnackbar.dart';

class ArtikelAmountChangeButton extends StatelessWidget {
  ArtikelAmountChangeButton({super.key});
  final codeScannerService = GetIt.instance<CodeScannerService>();
  final lagerListenVerwaltungsService =
      GetIt.instance<LagerlistenVerwaltungsService>();

  @override
  Widget build(BuildContext context) {
    return PrimaryButtonBase(
        title: "Artikelmenge verändern",
        accentColor: Color.fromRGBO(247, 119, 162, 1),
        onPressed: () => changeAmount(context));
  }

  void changeAmount(BuildContext context) async {
    // ARTIKEL SCANNEN => ERHÖHEN / VERMINDERN DIALOG => ZAHL EINGEBEN

    String? artikelGWID = await codeScannerService.getCodeByScan(
        context, "Scanne Artikel für Mengenänderung");
    if (artikelGWID == null || artikelGWID == Constants.EXIT_RETURN_VALUE) {
      return;
    }

    int amount = await lagerListenVerwaltungsService
        .howManyArtikelWithThisGWIDExist(artikelGWID);

    if (amount == 0) {
      Showsnackbar.showSnackBar(context,
          "Kein Artikel mit der der ArtikelGWID $artikelGWID existiert");
      return;
    }
    LagerlistenEntry? entry;
    if (amount == 1) {
      entry = await lagerListenVerwaltungsService.getArtikelByGWID(artikelGWID);
    } else {
      entry = await multipleArtikelExistGetByLagerplatz(context, artikelGWID);
    }
    if (entry == null) {
      return;
    }
    changeAmountWithDialog(context, entry);
  }

  void changeAmountWithDialog(
      BuildContext context, LagerlistenEntry entry) async {
    // Erhöhen oder vermindern ?
    bool isIncrease = await ShowDialogTwoOptions.isFirstOptionClicked(
      context,
      "Menge ändern",
      "Möchtest du die Menge erhöhen oder verringern?",
      "Erhöhen",
      "Verringern",
    );
    int? amount = await DialogNumberInput.getNumber(
        context,
        isIncrease ? "Wie viel legen Sie hinen?" : "Wie viel entnehmen Sie?",
        "Geben Sie die Menge ein"); // SHOW DIALOG with number inputfield
    if (amount == null || amount == 0) return;

    amount = amount * (isIncrease ? 1 : -1);
    String? response =
        await lagerListenVerwaltungsService.changeAmount(entry, amount);
    if (response != null) {
      Showsnackbar.showSnackBar(context, response);
    }
  }

  Future<LagerlistenEntry?> multipleArtikelExistGetByLagerplatz(
      BuildContext context, String artikelGWID) async {
    await Showsnackbar.showSnackBar(context,
        "Mehrere Artikel mit der ID $artikelGWID existieren. Bitte scanne den Lagerplatz");
    String? lagerplatz =
        await codeScannerService.getCodeByScan(context, "Lagerplatz scannen");
    while (lagerplatz != null &&
        lagerplatz != Constants.EXIT_RETURN_VALUE &&
        !await lagerListenVerwaltungsService.exist(lagerplatz, artikelGWID)) {
      // Ungültiger scan
      await Showsnackbar.showSnackBar(context,
          "In dem Lager $lagerplatz ist der Artikel mit der ID $artikelGWID nicht enthalten, scanne erneut.");

      lagerplatz =
          await codeScannerService.getCodeByScan(context, "Lagerplatz scannen");
    }
    if (lagerplatz == null || lagerplatz == Constants.EXIT_RETURN_VALUE) {
      return null;
    }
    return await lagerListenVerwaltungsService.getArtikelByGWIDAndLagerplatz(
        artikelGWID, lagerplatz);
  }
}
