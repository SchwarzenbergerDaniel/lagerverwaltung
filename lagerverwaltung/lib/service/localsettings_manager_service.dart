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
  static const String _CSV_ORDER_LIST_KEY = "CSV_ORDER_LIST_KEY";

  // SharedPreference-Cache:
  static SharedPreferences? _prefs;

  Future<SharedPreferences> _getSharePreference() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
      setDefaultValues(_prefs!);
    }
    return _prefs!;
  }

  Future setDefaultValues(SharedPreferences prefs) async {
    await setMail(prefs?.getString(_TO_MAIL_KEY));
    await setCsvOrder(prefs
        ?.getStringList(_CSV_ORDER_LIST_KEY)
        ?.map((value) => Columns.values.firstWhere((e) => e.name == value))
        .toList());
  }

  // INSTANZEN
  String? _toMail;
  List<Columns>? _csv_order;

  // MAIL:
  String getMail() {
    return _toMail!;
  }

  Future setMail(String? value) async {
    value = value ?? DefaultValues.DEFAULT_MAIL_EMPFAENGER;
    final prefs = await _getSharePreference();
    _toMail = value;
    prefs.setString(_TO_MAIL_KEY, value);
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
}
