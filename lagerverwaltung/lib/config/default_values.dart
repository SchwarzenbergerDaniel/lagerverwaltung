// ignore_for_file: constant_identifier_names

// CAN BE CONFIGURED BY THE USER. TODO: Make it package local for settings page once the settings service, once the LocalSettingsManagerService is finished.
import 'package:lagerverwaltung/page/settings/csv_column_order/csv_column_order_changer_page.dart';

class DefaultValues {
  //TODO: Mail des Kunden
  static const String DEFAULT_MAIL_EMPFAENGER = "terrorgans123@gmail.com";
  static const int DEFAULT_LOG_MAIL_INTERVALL_DAYS = 14;
  static const int DEFAULT_DELETE_LOG_ENTRIES_AFTER_DAYS = 60;
  static const List<Columns> DEFAULT_CSV_ORDER = [
    Columns.lagerplatzId,
    Columns.fach,
    Columns.regal,
    Columns.artikelGWID,
    Columns.arikelFirmenId,
    Columns.beschreibung,
    Columns.kunde,
    Columns.ablaufdatum,
    Columns.menge,
    Columns.mindestMenge
  ];
}
