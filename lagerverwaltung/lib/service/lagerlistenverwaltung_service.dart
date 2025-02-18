import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/config/errormessage_constants.dart';
import 'package:lagerverwaltung/model/lagerlistenentry.dart';
import 'package:lagerverwaltung/service/xlsx_converter_service.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';
import 'package:lagerverwaltung/service/localstorage_service.dart';
import 'package:lagerverwaltung/service/mailsender/mailsender_service.dart';

// Wenn ein String zurück gegeben wird, dann wird in diesem beschrieben was passiert ist: SNACKBAR nach aufruf!
class LagerlistenVerwaltungsService {
  // Service-Setup:
  LagerlistenVerwaltungsService._privateConstructor();
  static final LagerlistenVerwaltungsService _instance =
      LagerlistenVerwaltungsService._privateConstructor();
  factory LagerlistenVerwaltungsService() {
    return _instance;
  }

  // Instanzen
  final localStorageService = GetIt.instance<LocalStorageService>();
  final mailSenderService = GetIt.instance<MailSenderService>();
  final fileConverterService = GetIt.instance<FileConverterService>();
  final localSettingsManagerService =
      GetIt.instance<LocalSettingsManagerService>();

  Future<List<LagerlistenEntry>> get artikelEntries async =>
      await localStorageService.getArtikel();

  Future<List<LagerlistenEntry>> get lagerplatzEntries async =>
      await localStorageService.getLagerplaetze();

  // Methods:
  Future speichereInventur(
      String lagerplatzId,
      List<LagerlistenEntry> sollBestand,
      List<LagerlistenEntry> istBestand) async {
    List<LagerlistenEntry> entries = await artikelEntries;
    entries.removeWhere((x) => x.lagerplatzId == lagerplatzId);
    entries.addAll(istBestand);
    await localStorageService.inventurAbgeschlossen(entries, lagerplatzId);

    mailSenderService.sendInventurAbgeschlossen(
        lagerplatzId,
        await fileConverterService.convertToInventurListe(
            sollBestand, istBestand),
        localSettingsManagerService.getMail());
  }

  Future<bool> lagerplatzExist(String lagerplatzId) async {
    return (await lagerplatzEntries)
        .any((val) => val.lagerplatzId == lagerplatzId);
  }

  Future deleteLagerplatz(String lagerplatzId) async {
    // Artikel Löschen
    final artikel =
        (await artikelEntries).where((x) => x.lagerplatzId == lagerplatzId);
    for (final i in artikel) {
      deleteArtikel(i.artikelGWID!, i.lagerplatzId!);
    }
    final lagerplaetzeList = await lagerplatzEntries;

    LagerlistenEntry entry = lagerplaetzeList
        .firstWhere((element) => element.lagerplatzId == lagerplatzId);
    lagerplaetzeList.remove(entry);
    await localStorageService.removeLagerplatz(lagerplaetzeList);
  }

  Future deleteArtikel(String artikelGWID, String lagerplatzID) async {
    final list = await artikelEntries;

    try {
      LagerlistenEntry entry = list.firstWhere(
        (element) =>
            element.artikelGWID == artikelGWID &&
            element.lagerplatzId == lagerplatzID,
      );

      list.remove(entry);
      await localStorageService.removeArtikel(list, entry);
    } catch (e) {}
  }

  Future updateArtikel(
      String artikelGWID, String lagerplatzID, LagerlistenEntry entry) async {
    await deleteArtikel(artikelGWID, lagerplatzID);
    await addArtikelToLagerliste(entry);
  }

  Future<bool> artikelGWIDExist(String gwidCode) async {
    return (await artikelEntries).any((val) => val.artikelGWID == gwidCode);
  }

  Future addArtikelToLagerliste(LagerlistenEntry artikel) async {
    final list = await artikelEntries;
    list.add(artikel);
    localStorageService.addEntry(list, artikel);
  }

  Future addLagerplatzToLagerliste(LagerlistenEntry lagerplatz) async {
    final list = await lagerplatzEntries;
    list.add(lagerplatz);
    localStorageService.addEntry(list, lagerplatz);
  }

  Future addEmptyLagerplatz(String lagerplatzCode) async {
    LagerlistenEntry entry = LagerlistenEntry(lagerplatzId: lagerplatzCode);
    await addLagerplatzToLagerliste(entry);
  }

  Future<List<LagerlistenEntry>> getLagerlisteByLagerplatz(
      String lagerplatzCode) async {
    return (await artikelEntries)
        .where((val) => val.lagerplatzId == lagerplatzCode)
        .toList();
  }

  Future<LagerlistenEntry> getArtikelByGWID(String gwidCode) async {
    return (await artikelEntries)
        .where((val) => val.artikelGWID == gwidCode)
        .first;
  }

  Future<LagerlistenEntry> getArtikelByGWIDAndLagerplatz(
      String artikelGWID, String lagerplatz) async {
    return (await artikelEntries)
        .where((val) =>
            val.artikelGWID == artikelGWID && val.lagerplatzId == lagerplatz)
        .first;
  }

  Future<int> howManyArtikelWithThisGWIDExist(String artikelGWID) async {
    return (await artikelEntries)
        .where((val) => val.artikelGWID == artikelGWID)
        .length;
  }

  Future<bool> exist(String? lagerplatz, String artikelGWID) async {
    return (await artikelEntries).any((val) =>
        val.artikelGWID == artikelGWID && val.lagerplatzId == lagerplatz);
  }

  Future<String?> changeAmount(LagerlistenEntry entry, int amountChange) async {
    entry.menge = entry.menge! + amountChange;
    if (entry.menge! < 0) {
      return "${ErrorMessageConstants.NOT_ENOUGH_IN_STORAGE}. Menge im Lager: ${entry.menge! - amountChange}";
    }
    List<LagerlistenEntry> artikel = await artikelEntries;
    artikel.removeWhere((val) =>
        val.artikelGWID == entry.artikelGWID &&
        val.lagerplatzId == entry.lagerplatzId);
    if (entry.menge != 0) {
      artikel.add(entry);
    }

    localStorageService.amountChange(artikel, entry, amountChange);

    if (entry.menge! <= entry.mindestMenge! && entry.menge != 0) {
      mailSenderService.sendMindestmengeErreicht(
          entry, amountChange, localSettingsManagerService.getMail());
      return ErrorMessageConstants.MIN_AMOUNT_REACHED;
    }
    if (entry.menge == 0) {
      return "Die Menge beträgt nun 0. Der Artikel wurde gelöscht!";
    }

    return null;
  }

  Future<List<LagerlistenEntry>> getLaeuftDemnaechstAb() async {
    int daysInFuture =
        localSettingsManagerService.getAbgelaufenReminderInDays();
    DateTime day = DateTime.now().add(Duration(days: daysInFuture));
    day = DateTime(day.year, day.month, day.day);

    return (await artikelEntries).where((val) {
      if (val.getIstAbgelaufen()) {
        return false;
      }
      if (val.ablaufdatum != null) {
        DateTime ablaufDate = DateTime(
          val.ablaufdatum!.year,
          val.ablaufdatum!.month,
          val.ablaufdatum!.day,
        );
        return ablaufDate.isBefore(day) || ablaufDate.isAtSameMomentAs(day);
      }
      return false;
    }).toList();
  }

  Future<List<LagerlistenEntry>> getAbgelaufeneArtikel() async {
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    return (await artikelEntries).where((val) {
      if (val.ablaufdatum != null) {
        DateTime ablaufDate = DateTime(
          val.ablaufdatum!.year,
          val.ablaufdatum!.month,
          val.ablaufdatum!.day,
        );
        return ablaufDate.isBefore(today) || ablaufDate.isAtSameMomentAs(today);
      }
      return false;
    }).toList();
  }

  void exportLagerListe({bool isAutomatic = false}) async {
    File file = await fileConverterService.toXlsx(await artikelEntries);
    mailSenderService.sendLagerListe(
        file, localSettingsManagerService.getMail(), isAutomatic);
  }

  String importFromFile(String filePath) {
    if (filePath.endsWith(".xlsx") == false) {
      return ErrorMessageConstants.MUST_BE_XLSX;
    }
    File file = File(filePath);
    var newList = fileConverterService.convertToList(file);
    if (newList == null) {
      return ErrorMessageConstants.COULD_NOT_CONVERT_XLSX;
    }

    exportLagerListe(isAutomatic: true);
    localStorageService.clearArtikelListe();
    localStorageService.import(newList);

    return "Die Lagerliste wurde erfolgreich überschrieben";
  }
}
