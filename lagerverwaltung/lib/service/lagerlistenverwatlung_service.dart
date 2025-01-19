import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/model/LagerlistenEntry.dart';
import 'package:lagerverwaltung/service/csv_converter_service.dart';
import 'package:lagerverwaltung/service/localstorage_service.dart';
import 'package:lagerverwaltung/service/mailsender_service.dart';

// Wenn ein String zurück gegeben wird, dann wird in diesem beschrieben was passiert ist: SNACKBAR nach aufruf!
class LagerlistenVerwatlungsService {
  // Service-Setup:
  LagerlistenVerwatlungsService._privateConstructor();
  static final LagerlistenVerwatlungsService _instance =
      LagerlistenVerwatlungsService._privateConstructor();
  factory LagerlistenVerwatlungsService() {
    return _instance;
  }

  // instanzen
  final localStorageService = GetIt.instance<LocalStorageService>();
  final mailSenderService = GetIt.instance<MailSenderService>();
  final csvConverterService = GetIt.instance<CsvConverterService>();

  List<LagerListenEntry> lagerlistenEntries = [];

  // Methods:
  bool regalExist(String regalId) {
    return lagerlistenEntries.any((val) => val.regalId == regalId);
  }

  bool artikelGWIDExist(String gwidCode) {
    return lagerlistenEntries.any((val) => val.artikelGWID == gwidCode);
  }

  void addToLagerliste(LagerListenEntry entry) {
    this.lagerlistenEntries.add(entry);
    localStorageService.addLagerListenEntry(entry);
  }

  void addEmptyRegal(String regalCode) {
    LagerListenEntry entry = LagerListenEntry(regalId: regalCode);
    addToLagerliste(entry);
  }

  List<LagerListenEntry> getLagerlisteByRegal(String regalCode) {
    return this
        .lagerlistenEntries
        .where((val) => val.regalId == regalCode)
        .toList();
  }

  String? changeAmount(String artikelGWID, int amountChange) {
    LagerListenEntry? entry = lagerlistenEntries
        .where((val) => val.artikelGWID == artikelGWID)
        .firstOrNull;
    if (entry == null) {
      return "Artikel konnte nicht gefunden werden!";
    }
    entry.menge = entry.menge! + amountChange;
    if (entry.menge! < 0) {
      return "Sie können nicht mehr entnehmen als im Lager vorhanden ist!";
    }

    localStorageService.changeAmount(entry, amountChange);

    if (entry.menge! <= entry.mindestMenge!) {
      mailSenderService.sendMindestmengeErreicht(entry);
      return "Die Mindestmenge wurde erreicht! Genauere Informationen per Mail!";
    }

    return null;
  }

  void exportLagerListe() {
    File file = csvConverterService.toCsv(this.lagerlistenEntries);
    mailSenderService.sendLagerListe(file);
  }

  String? importFromFile(File file) {
    var newList = csvConverterService.convertToList(file);
    if (newList == null) {
      return "File konnte nicht importiert werden. Achten Sie auf richtiges Format!";
    }

    exportLagerListe();
    localStorageService.clearLagerliste();
    localStorageService.setNewLagerListe(newList);
    this.lagerlistenEntries = newList;

    return null;
  }
}
