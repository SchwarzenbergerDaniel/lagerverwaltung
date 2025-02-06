import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/config/errormessage_constants.dart';
import 'package:lagerverwaltung/model/LagerlistenEntry.dart';
import 'package:lagerverwaltung/service/csv_converter_service.dart';
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

  Future<List<LagerListenEntry>> get artikelEntries async =>
      await localStorageService.getArtikel();

  Future<List<LagerListenEntry>> get lagerplatzEntries async =>
      await localStorageService.getLagerplaetze();

  // Methods:

  Future<bool> lagerplatzExist(String lagerplatzId) async {
    return (await lagerplatzEntries)
        .any((val) => val.lagerplatzId == lagerplatzId);
  }

  Future<void> deleteArtikel(String artikelGWID, String lagerplatzID) async {
    final list = await artikelEntries;

    try {
      LagerListenEntry entry = list.firstWhere(
        (element) =>
            element.artikelGWID == artikelGWID &&
            element.lagerplatzId == lagerplatzID,
      );

      list.remove(entry);
      await localStorageService.removeEntry(list, entry);
    } catch (e) {}
  }

  void updateArtikel(
      String artikelGWID, String lagerplatzID, LagerListenEntry entry) async {
    await deleteArtikel(artikelGWID, lagerplatzID);
    await addArtikelToLagerliste(entry);
  }

  Future<bool> artikelGWIDExist(String gwidCode) async {
    return (await artikelEntries).any((val) => val.artikelGWID == gwidCode);
  }

  Future addArtikelToLagerliste(LagerListenEntry artikel) async {
    final list = await artikelEntries;
    list.add(artikel);
    localStorageService.addEntry(list, artikel);
  }

  void addLagerplatzToLagerliste(LagerListenEntry lagerplatz) async {
    final list = await lagerplatzEntries;
    list.add(lagerplatz);
    localStorageService.addEntry(list, lagerplatz);
  }

  void addEmptyLagerplatz(String lagerplatzCode) {
    LagerListenEntry entry = LagerListenEntry(lagerplatzId: lagerplatzCode);
    addLagerplatzToLagerliste(entry);
  }

  Future<List<LagerListenEntry>> getLagerlisteByLagerplatz(
      String lagerplatzCode) async {
    return (await artikelEntries)
        .where((val) => val.lagerplatzId == lagerplatzCode)
        .toList();
  }

  Future<LagerListenEntry> getArtikelByGWID(String gwidCode) async {
    return (await artikelEntries)
        .where((val) => val.artikelGWID == gwidCode)
        .first;
  }

  Future<String?> changeAmount(String artikelGWID, int amountChange) async {
    LagerListenEntry? entry = (await artikelEntries)
        .where((val) => val.artikelGWID == artikelGWID)
        .firstOrNull;

    if (entry == null) {
      return ErrorMessageConstants.COULD_NOT_CONVERT_CSV;
    }
    entry.menge = entry.menge! + amountChange;
    if (entry.menge! < 0) {
      return ErrorMessageConstants.NOT_ENOUGH_IN_STORAGE;
    }

    localStorageService.amountChange(
        (await artikelEntries), entry, amountChange);

    if (entry.menge! <= entry.mindestMenge!) {
      mailSenderService.sendMindestmengeErreicht(
          entry, amountChange, localSettingsManagerService.getMail());
      return ErrorMessageConstants.MIN_AMOUNT_REACHED;
    }

    return null;
  }

  void exportLagerListe({bool isAutomatic = false}) async {
    File file = await fileConverterService.toCsv(await artikelEntries);
    mailSenderService.sendLagerListe(
        file, localSettingsManagerService.getMail(), isAutomatic);
  }

  String importFromFile(String filePath) {
    if (filePath.endsWith(".csv") == false) {
      return ErrorMessageConstants.MUST_BE_CSV;
    }
    File file = File(filePath);
    var newList = fileConverterService.convertToList(file);
    if (newList == null) {
      return ErrorMessageConstants.COULD_NOT_CONVERT_CSV;
    }

    exportLagerListe(isAutomatic: true);
    localStorageService.clearArtikelListe();
    localStorageService.import(newList);

    return "Die Lagerliste wurde erfolgreich überschrieben";
  }
}
