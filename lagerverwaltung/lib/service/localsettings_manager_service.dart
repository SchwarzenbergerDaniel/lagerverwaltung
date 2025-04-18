// ignore_for_file: constant_identifier_names

import 'package:lagerverwaltung/config/default_values.dart';
import 'package:lagerverwaltung/page/settings/xlsx_column_order/xlsx_column_order_changer_page.dart';
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
  static const String _SEND_ABGELAUFEN_REMINDER_IN_DAYS_KEY =
      "_SEND_ABGELAUFEN_REMINDER_IN_DAYS_KEY";
  static const String _XLSX_ORDER_LIST_KEY = "XLSX_ORDER_LIST_KEY";
  static const String _IST_MOVING_BACKGROUND_KEY = "_IST_MOVING_BACKGROUND_KEY";
  static const String _IST_BRIGHT_BACKGROUND = "_IST_BRIGHT_BACKGROUND";
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
    await setXlsxOrder(prefs
        .getStringList(_XLSX_ORDER_LIST_KEY)
        ?.map((value) => Columns.values.firstWhere((e) => e.name == value))
        .toList());
    await setIntervallLogMailDays(prefs.getInt(_LOG_INTERVALL_MAIL_DAYS_KEY));
    await setDeleteLogsAfterDays(prefs.getInt(_DELETE_LOGS_AFTER_DAYS_KEY));
    await setAbgelaufenReminderInDays(
        prefs.getInt(_DELETE_LOGS_AFTER_DAYS_KEY));
    await setIsMoving(prefs.getBool(_IST_MOVING_BACKGROUND_KEY));
    await setIsBright(prefs.getBool(_IST_BRIGHT_BACKGROUND));
    await setIstBunt(prefs.getBool(_IST_BUNT_KEY));
  }

  // INSTANZEN
  String? _toMail;
  int? _logIntervallDays;
  int? _deleteLogsAfterDays;
  int? _sendAbgelaufenReminderInDays;
  List<Columns>? _xlsx_order;
  bool? _isMovingBackground;
  bool? _isBrightBackground;
  bool? _isBunt;

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

  // XLSX ORDER:
  List<Columns> getXlsxOrder() {
    return _xlsx_order!;
  }

  Future setXlsxOrder(List<Columns>? newOrder) async {
    newOrder = newOrder ?? DefaultValues.DEFAULT_XLSX_ORDER;
    final prefs = await _getSharePreference();
    _xlsx_order = newOrder;
    prefs.setStringList(
        _XLSX_ORDER_LIST_KEY, newOrder.map((val) => val.name).toList());
  }

  // Moving background-Farbgebung:
  bool getIsMoving() {
    return _isMovingBackground!;
  }

  Future setIsMoving(bool? istMoving) async {
    istMoving = istMoving ?? true;
    final prefs = await _getSharePreference();
    _isMovingBackground = istMoving;
    prefs.setBool(_IST_MOVING_BACKGROUND_KEY, _isMovingBackground!);
  }

  bool getIsBright() {
    return _isBrightBackground!;
  }

  Future setIsBright(bool? isBright) async {
    isBright = isBright ?? false;
    final prefs = await _getSharePreference();
    _isBrightBackground = isBright;
    prefs.setBool(_IST_BRIGHT_BACKGROUND, _isBrightBackground!);
  }

  int getAbgelaufenReminderInDays() {
    return _sendAbgelaufenReminderInDays!;
  }

  Future setAbgelaufenReminderInDays(int? value) async {
    value = value ?? DefaultValues.DEFAULT_ABGELAUFEN_REMINDER_DAYS;
    final prefs = await _getSharePreference();
    _sendAbgelaufenReminderInDays = value;
    prefs.setInt(_SEND_ABGELAUFEN_REMINDER_IN_DAYS_KEY, value);
  }

  Future setIstBunt(bool? istBunt) async {
    istBunt = istBunt ?? true;
    final prefs = await _getSharePreference();
    _isBunt = istBunt;
    prefs.setBool(_IST_BUNT_KEY, istBunt);
  }

  bool getIstBunt() {
    return _isBunt!;
  }
}
