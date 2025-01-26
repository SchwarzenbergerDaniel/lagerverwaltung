import 'dart:convert';
import 'package:lagerverwaltung/service/logger/log_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoggerService {
  // Service Setup
  LoggerService._privateConstructor();
  static final LoggerService _instance = LoggerService._privateConstructor();
  factory LoggerService() => _instance;

  static const String _logsKey = "lagerverwaltung_logs";

  static SharedPreferences? _prefs;
  Future<SharedPreferences> _getSharedPreferences() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> log(LogEntryModel logModel) async {
    final prefs = await _getSharedPreferences();

    final List<String> logs = prefs.getStringList(_logsKey) ?? [];

    logs.add(jsonEncode(logModel.toMap()));
    await prefs.setStringList(_logsKey, logs);
  }

  Future<List<LogEntryModel>> getLogs() async {
    final prefs = await _getSharedPreferences();

    final List<String> logJsonList = prefs.getStringList(_logsKey) ?? [];

    return logJsonList.map((logJson) {
      final Map<String, dynamic> logMap = jsonDecode(logJson);
      return LogEntryModel.fromMap(logMap);
    }).toList();
  }

  Future<void> clearLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_logsKey);
  }
}


/*
Cannot implement / these yet: 
20022025 14:30 | Inventur gestartet
20022025 14:30 | Inventurliste gesendet
20022025 14:30 | Trackingliste gesendet
*/