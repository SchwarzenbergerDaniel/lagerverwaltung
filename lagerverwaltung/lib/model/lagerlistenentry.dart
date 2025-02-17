import 'package:lagerverwaltung/config/constants.dart';
import 'package:lagerverwaltung/page/settings/xlsx_column_order/xlsx_column_order_changer_page.dart';

class LagerlistenEntry {
  // Instanzen
  String? fach;
  String? regal;
  String? lagerplatzId;
  String? artikelGWID;
  String? arikelFirmenId;
  String? beschreibung;
  String? kunde;
  DateTime? ablaufdatum;
  int? menge;
  int? mindestMenge;

  // Methoden:
  bool istArtikel() {
    return artikelGWID != null;
  }

  bool getIstAbgelaufen() {
    if (ablaufdatum == null) {
      return false;
    }
    return ablaufdatum!.isBefore(DateTime.now());
  }

  String? getId() {
    if (lagerplatzId == null || artikelGWID == null) {
      return null;
    }
    return "${lagerplatzId!} ${artikelGWID!}";
  }

  // Used to be able to write it into localstorage..
  Map<String, dynamic> toJson() {
    return {
      'fach': fach,
      'regal': regal,
      'lagerplatzId': lagerplatzId,
      'artikelGWID': artikelGWID,
      'arikelFirmenId': arikelFirmenId,
      'beschreibung': beschreibung,
      'kunde': kunde,
      'ablaufdatum': ablaufdatum?.toIso8601String(), // ISO format for DateTime
      'menge': menge,
      'mindestMenge': mindestMenge,
    };
  }

  // Used to convert from LocalStorage to Object.
  factory LagerlistenEntry.fromJson(Map<String, dynamic> json) {
    return LagerlistenEntry(
      fach: json['fach'],
      regal: json['regal'],
      lagerplatzId: json['lagerplatzId'],
      artikelGWID: json['artikelGWID'],
      arikelFirmenId: json['arikelFirmenId'],
      beschreibung: json['beschreibung'],
      kunde: json['kunde'],
      ablaufdatum: json['ablaufdatum'] != null
          ? DateTime.parse(json['ablaufdatum'])
          : null,
      menge: json['menge'],
      mindestMenge: json['mindestMenge'],
    );
  }

  // Konstruktor
  LagerlistenEntry({
    this.fach,
    this.regal,
    this.lagerplatzId,
    this.artikelGWID,
    this.arikelFirmenId,
    this.beschreibung,
    this.kunde,
    this.ablaufdatum,
    this.menge,
    this.mindestMenge,
  }) {
    if (ablaufdatum != null) {
      ablaufdatum =
          DateTime(ablaufdatum!.year, ablaufdatum!.month, ablaufdatum!.day);
    }
  }

  // CSV - STUFF
  static LagerlistenEntry convertCSVLine(
      String line, List<Columns> columnOrder) {
    List<String> split = line.split(Constants.XLSX_DELIMITER_VALUE);

    Map<Columns, String> values = {};

    for (int i = 0; i < columnOrder.length && i < split.length; i++) {
      values[columnOrder[i]] = split[i].replaceAll(
          Constants.XLSX_DELIMITER_REPLACER, Constants.XLSX_DELIMITER_VALUE);
    }

    return LagerlistenEntry(
      lagerplatzId: values[Columns.lagerplatzId]?.isNotEmpty == true
          ? values[Columns.lagerplatzId]
          : null,
      fach: values[Columns.fach]?.isNotEmpty == true
          ? values[Columns.fach]
          : null,
      regal: values[Columns.regal]?.isNotEmpty == true
          ? values[Columns.regal]
          : null,
      artikelGWID: values[Columns.artikelGWID]?.isNotEmpty == true
          ? values[Columns.artikelGWID]
          : null,
      arikelFirmenId: values[Columns.arikelFirmenId]?.isNotEmpty == true
          ? values[Columns.arikelFirmenId]
          : null,
      beschreibung: values[Columns.beschreibung]?.isNotEmpty == true
          ? values[Columns.beschreibung]
          : null,
      kunde: values[Columns.kunde]?.isNotEmpty == true
          ? values[Columns.kunde]
          : null,
      ablaufdatum: values[Columns.ablaufdatum]?.isNotEmpty == true
          ? DateTime.tryParse(values[Columns.ablaufdatum]!)
          : null,
      menge: values[Columns.menge]?.isNotEmpty == true
          ? int.tryParse(values[Columns.menge]!)
          : null,
      mindestMenge: values[Columns.mindestMenge]?.isNotEmpty == true
          ? int.tryParse(values[Columns.mindestMenge]!)
          : null,
    );
  }

  String toCsvRow(List<Columns> default_csv_order) {
    List<(Columns column, dynamic value)> values = [
      (
        Columns.lagerplatzId,
        (lagerplatzId ?? '').replaceAll(
            Constants.XLSX_DELIMITER_VALUE, Constants.XLSX_DELIMITER_REPLACER)
      ),
      (
        Columns.fach,
        (fach ?? '').replaceAll(
            Constants.XLSX_DELIMITER_VALUE, Constants.XLSX_DELIMITER_REPLACER)
      ),
      (
        Columns.regal,
        (regal ?? '').replaceAll(
            Constants.XLSX_DELIMITER_VALUE, Constants.XLSX_DELIMITER_REPLACER)
      ),
      (
        Columns.artikelGWID,
        (artikelGWID ?? '').replaceAll(
            Constants.XLSX_DELIMITER_VALUE, Constants.XLSX_DELIMITER_REPLACER)
      ),
      (
        Columns.arikelFirmenId,
        (arikelFirmenId ?? '').replaceAll(
            Constants.XLSX_DELIMITER_VALUE, Constants.XLSX_DELIMITER_REPLACER)
      ),
      (
        Columns.beschreibung,
        (beschreibung ?? '').replaceAll(
            Constants.XLSX_DELIMITER_VALUE, Constants.XLSX_DELIMITER_REPLACER)
      ),
      (
        Columns.kunde,
        (kunde ?? '').replaceAll(
            Constants.XLSX_DELIMITER_VALUE, Constants.XLSX_DELIMITER_REPLACER)
      ),
      (
        Columns.ablaufdatum,
        ablaufdatum?.toIso8601String().replaceAll(
                Constants.XLSX_DELIMITER_VALUE,
                Constants.XLSX_DELIMITER_REPLACER) ??
            ''
      ),
      (
        Columns.menge,
        menge?.toString().replaceAll(Constants.XLSX_DELIMITER_VALUE,
                Constants.XLSX_DELIMITER_REPLACER) ??
            ''
      ),
      (
        Columns.mindestMenge,
        mindestMenge?.toString().replaceAll(Constants.XLSX_DELIMITER_VALUE,
                Constants.XLSX_DELIMITER_REPLACER) ??
            ''
      )
    ];

    values.sort((left, right) => default_csv_order
        .indexOf(left.$1)
        .compareTo(default_csv_order.indexOf(right.$1)));
    final erg =
        values.map((value) => value.$2).join(Constants.XLSX_DELIMITER_VALUE);
    return erg;
  }
}
