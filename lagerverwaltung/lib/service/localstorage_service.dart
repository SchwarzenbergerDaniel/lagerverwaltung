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
  static const String _lastBackupKey = "lagerliste_lastbackupmade_key";
  static const String _lastAbgelaufenMailSentKey =
      "abgelaufen_lastMailDate_key";

  static const String _lastLogMailSentKey = "lastLogMail_key";
  static const String _lagerplaetzeKey = "lagerplaetze_key";
  static const String _artikelKey = "artikel_key";

  // SharedPreference-Cache:
  static SharedPreferences? _prefs;

  Future<SharedPreferences> _getSharePreference() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Last Log Mail
  void setLastTimeLogsMailWasSent() async {
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    final prefs = await _getSharePreference();
    await prefs.setString(_lastLogMailSentKey, dateTimeToString(today));
  }

  Future<DateTime> getLastTimeLogsMailWasSent() async {
    final prefs = await _getSharePreference();
    String? lastTime = prefs.getString(_lastLogMailSentKey);

    if (lastTime == null) {
      return DateTime(1, 1, 1);
    }
    return DateTime.parse(lastTime);
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

  // Lagerlistet
  Future<List<LagerListenEntry>> getArtikel() async {
    final prefs = await _getSharePreference();
    final jsonString = prefs.getString(_artikelKey);
    if (jsonString == null) {
      return [];
    }
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((entry) => LagerListenEntry.fromJson(entry)).toList();
  }

  Future<List<LagerListenEntry>> getLagerplaetze() async {
    final prefs = await _getSharePreference();
    final jsonString = prefs.getString(_lagerplaetzeKey);
    if (jsonString == null) {
      return [];
    }
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((entry) => LagerListenEntry.fromJson(entry)).toList();
  }

  void clearArtikelListe() async {
    _artikelListeChanged([]);
  }

  void _artikelListeChanged(List<LagerListenEntry> artikelList) async {
    final prefs = await _getSharePreference();
    await prefs.setString(_artikelKey,
        jsonEncode(artikelList.map((entry) => entry.toJson()).toList()));
  }

  void _lagerplaetzeChanged(List<LagerListenEntry> lagerplaetze) async {
    final prefs = await _getSharePreference();
    await prefs.setString(_lagerplaetzeKey,
        jsonEncode(lagerplaetze.map((entry) => entry.toJson()).toList()));
  }

  void import(List<LagerListenEntry> artikelList) {
    _artikelListeChanged(artikelList);
    loggerService.log(LogEntryModel(
        timestamp: DateTime.now(), logReason: LogReason.Lagerliste_importiert));
  }

  void removeEntry(List<LagerListenEntry> artikelList, LagerListenEntry entry) {
    _artikelListeChanged(artikelList);
    loggerService.log(LogEntryModel(
        timestamp: DateTime.now(),
        logReason: LogReason.Artikel_entnehmen,
        artikelGWID: entry.artikelGWID,
        lagerplatzId: entry.lagerplatzId));
  }

  void addEntry(List<LagerListenEntry> list, LagerListenEntry entry) {
    if (entry.istArtikel()) {
      _artikelListeChanged(list);
    } else {
      _lagerplaetzeChanged(list);
    }

    loggerService.log(LogEntryModel(
        timestamp: DateTime.now(),
        logReason: entry.istArtikel()
            ? LogReason.Eintrag_in_Lagerliste
            : LogReason.Lagerplatz_angelegt,
        artikelGWID: entry.istArtikel() ? entry.artikelGWID : null,
        lagerplatzId: entry.lagerplatzId));
  }

  void amountChange(List<LagerListenEntry> artikelList, LagerListenEntry entry,
      int amountChange) {
    _artikelListeChanged(artikelList);

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
