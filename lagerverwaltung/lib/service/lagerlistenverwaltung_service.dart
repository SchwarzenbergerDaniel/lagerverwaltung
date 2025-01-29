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
  final csvConverterService = GetIt.instance<CsvConverterService>();
  final localSettingsManagerService =
      GetIt.instance<LocalSettingsManagerService>();

  Future<List<LagerListenEntry>> get lagerlistenEntries async =>
      await localStorageService.getLagerliste();

  // Methods:

  Future<bool> lagerplatzExist(String lagerplatzId) async {
    return (await lagerlistenEntries)
        .any((val) => val.lagerplatzId == lagerplatzId);
  }

  void deleteArtikel(String artikelGWID, String lagerplatzID) async {
    final list = await lagerlistenEntries;
    LagerListenEntry? entry = list.firstWhere((element) =>
        element.artikelGWID == artikelGWID &&
        element.lagerplatzId == lagerplatzID);
    list.remove(entry);
    localStorageService.removeEntry(list, entry);
  }

  void updateArtikel(
      String artikelGWID, String lagerplatzID, LagerListenEntry entry) {
    deleteArtikel(artikelGWID, lagerplatzID);
    addToLagerliste(entry);
  }

  Future<bool> artikelGWIDExist(String gwidCode) async {
    return (await lagerlistenEntries).any((val) => val.artikelGWID == gwidCode);
  }

  void addToLagerliste(LagerListenEntry entry) async {
    final list = await lagerlistenEntries;
    list.add(entry);
    localStorageService.addEntry(list, entry);
  }

  void addEmptyLagerplatz(String lagerplatzCode) {
    LagerListenEntry entry = LagerListenEntry(lagerplatzId: lagerplatzCode);
    addToLagerliste(entry);
  }

  Future<List<LagerListenEntry>> getLagerlisteByLagerplatz(
      String lagerplatzCode) async {
    return (await lagerlistenEntries)
        .where((val) => val.lagerplatzId == lagerplatzCode && val.istArtikel())
        .toList();
  }

  Future<LagerListenEntry> getArtikelByGWID(String gwidCode) async {
    return (await lagerlistenEntries)
        .where((val) => val.artikelGWID == gwidCode)
        .first;
  }

  Future<String?> changeAmount(String artikelGWID, int amountChange) async {
    LagerListenEntry? entry = (await lagerlistenEntries)
        .where((val) => val.artikelGWID == artikelGWID)
        .firstOrNull;

    if (entry == null) {
      return ErrorMessageConstants.COULD_NOT_FIND_ARTICLE;
    }
    entry.menge = entry.menge! + amountChange;
    if (entry.menge! < 0) {
      return ErrorMessageConstants.NOT_ENOUGH_IN_STORAGE;
    }

    localStorageService.amountChange(
        (await lagerlistenEntries), entry, amountChange);

    if (entry.menge! <= entry.mindestMenge!) {
      mailSenderService.sendMindestmengeErreicht(
          entry, amountChange, localSettingsManagerService.getMail());
      return ErrorMessageConstants.MIN_AMOUNT_REACHED;
    }

    return null;
  }

  void exportLagerListe() async {
    File file = await csvConverterService.toCsv(await lagerlistenEntries);
    mailSenderService.sendLagerListe(
        file, localSettingsManagerService.getMail(), false);
  }

  String? importFromFile(File file) {
    var newList = csvConverterService.convertToList(file);
    if (newList == null) {
      return ErrorMessageConstants.COULD_NOT_FIND_ARTICLE;
    }

    exportLagerListe();
    localStorageService.clearLagerliste();
    localStorageService.import(newList);

    return null;
  }
}
