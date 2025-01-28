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

  List<LagerListenEntry> lagerlistenEntries = [];

  // Methods:
  bool lagerplatzExist(String lagerplatzId) {
    return lagerlistenEntries.any((val) => val.lagerplatzId == lagerplatzId);
  }

  bool artikelGWIDExist(String gwidCode) {
    return lagerlistenEntries.any((val) => val.artikelGWID == gwidCode);
  }

  void addToLagerliste(LagerListenEntry entry) {
    lagerlistenEntries.add(entry);
    localStorageService.addEntry(lagerlistenEntries, entry);
  }

  void addEmptyLagerplatz(String lagerplatzCode) {
    LagerListenEntry entry = LagerListenEntry(lagerplatzId: lagerplatzCode);
    addToLagerliste(entry);
  }

  List<LagerListenEntry> getLagerlisteByLagerplatz(String lagerplatzCode) {
    return lagerlistenEntries
        .where((val) => val.lagerplatzId == lagerplatzCode && val.istArtikel())
        .toList();
  }

  LagerListenEntry getArtikelByGWID(String gwidCode) {
    return lagerlistenEntries.where((val) => val.artikelGWID == gwidCode).first;
  }

  Future<String?> changeAmount(String artikelGWID, int amountChange) async {
    LagerListenEntry? entry = lagerlistenEntries
        .where((val) => val.artikelGWID == artikelGWID)
        .firstOrNull;

    if (entry == null) {
      return ErrorMessageConstants.COULD_NOT_FIND_ARTICLE;
    }
    entry.menge = entry.menge! + amountChange;
    if (entry.menge! < 0) {
      return ErrorMessageConstants.NOT_ENOUGH_IN_STORAGE;
    }

    localStorageService.amountChange(lagerlistenEntries, entry, amountChange);

    if (entry.menge! <= entry.mindestMenge!) {
      mailSenderService.sendMindestmengeErreicht(
          entry, amountChange, localSettingsManagerService.getMail());
      return ErrorMessageConstants.MIN_AMOUNT_REACHED;
    }

    return null;
  }

  void exportLagerListe() async {
    File file = await csvConverterService.toCsv(lagerlistenEntries);
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
    lagerlistenEntries = newList;

    return null;
  }
}
