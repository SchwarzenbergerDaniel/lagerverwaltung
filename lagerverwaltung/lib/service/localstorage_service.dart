import 'dart:convert';

import 'package:lagerverwaltung/model/LagerlistenEntry.dart';
import 'package:shared_preferences/shared_preferences.dart';

//TODO: Always add to logs => Will do that in the next PR.
enum ReasonForLagerlistenChange { import, amountChange, addEntry, noReason }

class LocalStorageService {
  // Service-Setup:
  LocalStorageService._privateConstructor();
  static final LocalStorageService _instance =
      LocalStorageService._privateConstructor();
  factory LocalStorageService() {
    return _instance;
  }

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

  void clearLagerliste() async {
    lagerlisteChanged([], ReasonForLagerlistenChange.noReason);
  }

  void lagerlisteChanged(
      List<LagerListenEntry> newList, ReasonForLagerlistenChange reason) async {
    // Reason (not my brother wezon) is relevant for the logs.
    final prefs = await _getSharePreference();

    final jsonList = newList.map((entry) => entry.toJson()).toList();
    await prefs.setString(_lagerlisteKey, jsonEncode(jsonList));

    if (reason != ReasonForLagerlistenChange.noReason) {
      //TODO: LOG
    }
  }
}
