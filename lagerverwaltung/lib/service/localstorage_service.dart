import 'package:lagerverwaltung/model/LagerlistenEntry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  // Service-Setup:
  LocalStorageService._privateConstructor();
  static final LocalStorageService _instance =
      LocalStorageService._privateConstructor();
  factory LocalStorageService() {
    return _instance;
  }

  // Keys:
  static const String _lastBackupKey = "lagerliste_lastbackupmade_key";
  static const String _lastAbgelaufenMailSentKey =
      "abgelaufen_lastMailDate_key";

  // SharedPreference-Cache:
  static SharedPreferences? _prefs;

  Future<SharedPreferences> _getSharePreference() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    return _prefs!;
  }

  // METHODEN:

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

  //TODO: Erst machbar wenn wir wissen wie genau der Spaß aussehen soll.
  void addLagerListenEntry(LagerListenEntry entry) {}

  void changeAmount(LagerListenEntry entry, int amountChange) {}

  void clearLagerliste() {}

  void setNewLagerListe(List<LagerListenEntry> newList) {}
}
