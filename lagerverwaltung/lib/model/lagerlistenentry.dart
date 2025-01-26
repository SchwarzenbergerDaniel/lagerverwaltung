import 'package:lagerverwaltung/config/constants.dart';

class LagerListenEntry {
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
  factory LagerListenEntry.fromJson(Map<String, dynamic> json) {
    return LagerListenEntry(
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
  LagerListenEntry({
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

  LagerListenEntry.onlyId({required String fach}) {
    this.fach = fach;
  }

  // CSV - STUFF
  static LagerListenEntry convertCSVLine(String csvLine) {
    List<String> split = csvLine.split(Constants.CSV_DELIMITER_VALUE);

    return LagerListenEntry(
      lagerplatzId: split[0].isNotEmpty ? split[0] : null,
      fach: split[1].isNotEmpty ? split[1] : null,
      regal: split[2].isNotEmpty ? split[2] : null,
      artikelGWID: split[3].isNotEmpty ? split[3] : null,
      arikelFirmenId: split[4].isNotEmpty ? split[4] : null,
      beschreibung: split[5].isNotEmpty ? split[5] : null,
      kunde: split[6].isNotEmpty ? split[6] : null,
      ablaufdatum: split[7].isNotEmpty ? DateTime.tryParse(split[7]) : null,
      menge: split[8].isNotEmpty ? int.tryParse(split[8]) : null,
      mindestMenge: split[9].isNotEmpty ? int.tryParse(split[9]) : null,
    );
  }

  String toCsvRow() {
    return [
      lagerplatzId ?? '',
      fach ?? '',
      regal ?? '',
      artikelGWID ?? '',
      arikelFirmenId ?? '',
      beschreibung ?? '',
      kunde ?? '',
      ablaufdatum?.toIso8601String() ?? '',
      menge?.toString() ?? '',
      mindestMenge?.toString() ?? ''
    ].join(',');
  }
}
