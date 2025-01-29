import 'package:lagerverwaltung/config/default_values.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalSettingsManagerService {
  // Service-Setup:
  LocalSettingsManagerService._privateConstructor() {
    _getSharePreference();
  }
  static final LocalSettingsManagerService _instance =
      LocalSettingsManagerService._privateConstructor();

  factory LocalSettingsManagerService() {
    return _instance;
  }

  // KEYS:
  static const String _TO_MAIL_KEY = "TO_MAIL_KEY";

  // SharedPreference-Cache:
  static SharedPreferences? _prefs;

  Future<SharedPreferences> _getSharePreference() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
      await setDefaultValuesIfNeeded();
    }
    return _prefs!;
  }

  Future setDefaultValuesIfNeeded() async {
    final prefs = await _getSharePreference();
    //TODO: SET DEFAULT VALUE => NEEDED IF THE APP IS LAUNCEHD FOR THE FIRST TIME!
    setMail(prefs.getString(_TO_MAIL_KEY));

    if (prefs.getString(_TO_MAIL_KEY) == null) {
      setMail(DefaultValues.DEFAULT_MAIL_EMPFAENGER);
    }
  }

  // INSTANZEN
  String? _toMail;

  // METHODEN
  String getMail() {
    return _toMail!;
  }

  void setMail(String? value) async {
    value = value ?? DefaultValues.DEFAULT_MAIL_EMPFAENGER;
    final prefs = await _getSharePreference();
    _toMail = value;
    prefs.setString(_TO_MAIL_KEY, value);
  }
}
