// ignore_for_file: constant_identifier_names

import 'package:lagerverwaltung/config/default_values.dart';
import 'package:lagerverwaltung/page/settings/csv_column_order/csv_column_order_changer_page.dart';
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
  static const String _DELETE_LOGS_AFTER_DAYS_KEY =
      "_DELETE_LOGS_AFTER_DAYS_KEY";
  static const String _LOG_INTERVALL_MAIL_DAYS_KEY =
      "_LOG_INTERVALL_MAIL_DAYS_KEY";
  static const String _CSV_ORDER_LIST_KEY = "CSV_ORDER_LIST_KEY";
  static const String _IST_BUNT_KEY = "_IST_BUNT_KEY";

  // SharedPreference-Cache:
  static SharedPreferences? _prefs;

  Future ensureInitialized() async {
    await _getSharePreference();
  }

  Future<SharedPreferences> _getSharePreference() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
      await setDefaultValues(_prefs!);
    }
    return _prefs!;
  }

  Future setDefaultValues(SharedPreferences prefs) async {
    await setMail(prefs.getString(_TO_MAIL_KEY));
    await setCsvOrder(prefs
        .getStringList(_CSV_ORDER_LIST_KEY)
        ?.map((value) => Columns.values.firstWhere((e) => e.name == value))
        .toList());
    await setIntervallLogMailDays(prefs.getInt(_LOG_INTERVALL_MAIL_DAYS_KEY));
    await setDeleteLogsAfterDays(prefs.getInt(_DELETE_LOGS_AFTER_DAYS_KEY));
    await setIstBunt(prefs.getBool(_IST_BUNT_KEY));
  }

  // INSTANZEN
  String? _toMail;
  int? _logIntervallDays;
  int? _deleteLogsAfterDays;
  List<Columns>? _csv_order;
  bool? _istBunt;

  // MAIL-EMpfänger:
  String getMail() {
    return _toMail!;
  }

  Future setMail(String? value) async {
    value = value ?? DefaultValues.DEFAULT_MAIL_EMPFAENGER;
    final prefs = await _getSharePreference();
    _toMail = value;
    prefs.setString(_TO_MAIL_KEY, value);
  }

  // DELETE-LOGS:
  int getDeleteLogsAfterDays() {
    return _deleteLogsAfterDays!;
  }

  Future setDeleteLogsAfterDays(int? value) async {
    value = value ?? DefaultValues.DEFAULT_DELETE_LOG_ENTRIES_AFTER_DAYS;
    final prefs = await _getSharePreference();
    _deleteLogsAfterDays = value;
    prefs.setInt(_DELETE_LOGS_AFTER_DAYS_KEY, value);
  }

  // LOG-MAIL:
  int getIntervallLogMailDays() {
    return _logIntervallDays!;
  }

  Future setIntervallLogMailDays(int? value) async {
    value = value ?? DefaultValues.DEFAULT_LOG_MAIL_INTERVALL_DAYS;
    final prefs = await _getSharePreference();
    _logIntervallDays = value;
    prefs.setInt(_LOG_INTERVALL_MAIL_DAYS_KEY, value);
  }

  // CSV ORDER:
  List<Columns> getCsvOrder() {
    return _csv_order!;
  }

  Future setCsvOrder(List<Columns>? newOrder) async {
    newOrder = newOrder ?? DefaultValues.DEFAULT_CSV_ORDER;
    final prefs = await _getSharePreference();
    _csv_order = newOrder;
    prefs.setStringList(
        _CSV_ORDER_LIST_KEY, newOrder.map((val) => val.name).toList());
  }

  // BUNTE-Farbgebung:
  bool getIstBunt() {
    return _istBunt!;
  }

  Future setIstBunt(bool? istBunt) async {
    istBunt = istBunt ?? true;
    final prefs = await _getSharePreference();
    this._istBunt = istBunt;
    prefs.setBool(_IST_BUNT_KEY, this._istBunt!);
  }
}
