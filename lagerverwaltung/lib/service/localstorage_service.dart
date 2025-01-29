import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/model/LagerlistenEntry.dart';
import 'package:lagerverwaltung/service/logger/log_entry.dart';
import 'package:lagerverwaltung/service/logger/logger_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  // Service-Setup:
  LocalStorageService._privateConstructor();
  static final LocalStorageService _instance =
      LocalStorageService._privateConstructor();
  factory LocalStorageService() {
    return _instance;
  }
  final loggerService = GetIt.instance<LoggerService>();

  // Keys:
  static const String _lagerlisteKey = "lagerliste_key";
  static const String _lastBackupKey = "lagerliste_lastbackupmade_key";
  static const String _lastAbgelaufenMailSentKey =
      "abgelaufen_lastMailDate_key";

  // SharedPreference-Cache:
  static SharedPreferences? _prefs;

  Future<SharedPreferences> _getSharePreference() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Last Abgelaufen Mail:
  Future<DateTime> getLastTimeAbgelaufenMailSent() async {
    final prefs = await _getSharePreference();
    String? lastTime = prefs.getString(_lastAbgelaufenMailSentKey);

    if (lastTime == null) {
      return DateTime(1, 1, 1);
    }
    return DateTime.parse(lastTime);
  }

  void setLastTimeAbgelaufenMailSent() async {
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    final prefs = await _getSharePreference();
    await prefs.setString(_lastAbgelaufenMailSentKey, dateTimeToString(today));
  }

  // Last Backup:
  Future<DateTime> getLastBackup() async {
    final prefs = await _getSharePreference();
    String? lastTime = prefs.getString(_lastBackupKey);

    if (lastTime == null) {
      return DateTime(1, 1, 1);
    }
    return DateTime.parse(lastTime);
  }

  void setLastBackup() async {
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    final prefs = await _getSharePreference();
    await prefs.setString(_lastBackupKey, dateTimeToString(today));
  }

  String dateTimeToString(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month}-${dateTime.day}";
  }

  // Lagerliste

  Future<List<LagerListenEntry>> getLagerliste() async {
    final prefs = await _getSharePreference();
    final jsonString = prefs.getString(_lagerlisteKey);
    if (jsonString == null) {
      return [];
    }
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((entry) => LagerListenEntry.fromJson(entry)).toList();
  }

  void clearLagerliste() async {
    _lagerlisteChanged([]);
  }

  void _lagerlisteChanged(List<LagerListenEntry> newList) async {
    // Reason (not my brother wezon) is relevant for the logs.
    final prefs = await _getSharePreference();

    final jsonList = newList.map((entry) => entry.toJson()).toList();
    await prefs.setString(_lagerlisteKey, jsonEncode(jsonList));
  }

  void import(List<LagerListenEntry> newList) {
    _lagerlisteChanged(newList);
    loggerService.log(LogEntryModel(
        timestamp: DateTime.now(), logReason: LogReason.Lagerliste_importiert));
  }

  void removeEntry(
      List<LagerListenEntry> newLagerlistenEntries, LagerListenEntry entry) {
    _lagerlisteChanged(newLagerlistenEntries);
    loggerService.log(LogEntryModel(
        timestamp: DateTime.now(),
        logReason: LogReason.Artikel_entnehmen,
        artikelGWID: entry.artikelGWID,
        lagerplatzId: entry.lagerplatzId));
  }

  void addEntry(
      List<LagerListenEntry> newLagerlistenEntries, LagerListenEntry entry) {
    _lagerlisteChanged(newLagerlistenEntries);

    if (entry.istArtikel()) {
      loggerService.log(LogEntryModel(
          timestamp: DateTime.now(),
          logReason: LogReason.Eintrag_in_Lagerliste,
          artikelGWID: entry.artikelGWID,
          lagerplatzId: entry.lagerplatzId));
    } else {
      // Leerer Lagerplatz wurde angelegt.
      loggerService.log(LogEntryModel(
          timestamp: DateTime.now(),
          logReason: LogReason.Lagerplatz_angelegt,
          lagerplatzId: entry.lagerplatzId));
    }
  }

  void amountChange(List<LagerListenEntry> lagerlistenEntries,
      LagerListenEntry entry, int amountChange) {
    _lagerlisteChanged(lagerlistenEntries);

    loggerService.log(
      LogEntryModel(
          timestamp: DateTime.now(),
          logReason:
              amountChange > 0 ? LogReason.Einlagerung : LogReason.Auslagerung,
          lagerplatzId: entry.lagerplatzId,
          artikelGWID: entry.artikelGWID,
          menge: amountChange > 0 ? amountChange : -amountChange,
          neueMenge: entry.menge),
    );
  }
}
