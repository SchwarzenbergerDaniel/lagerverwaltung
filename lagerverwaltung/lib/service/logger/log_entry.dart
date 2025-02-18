// ignore_for_file: constant_identifier_names

enum LogReason {
  Einlagerung,
  Lagerplatz_angelegt,
  Auslagerung,
  Inventur_abgeschlossen,
  Inventurliste_gesendet,
  Backup_Lagerliste_gesendet,
  Lagerliste_gesendet,
  Lagerliste_importiert,
  Trackingliste_gesendet,
  Abgelaufen_Artikel_gesendet,
  Eintrag_in_Lagerliste,
  Artikel_entnehmen,
  Log_Liste_versendet,
  Mindestmenge_erreicht_Mail,
  Alle_abgelaufenen_Artikel_versendet,
  Lagerplatz_geloescht
}

class LogEntryModel {
  final DateTime timestamp;
  final LogReason logReason;
  final String? lagerplatzId;
  final String? artikelGWID;
  final int? menge; // Menge, optional
  final int? neueMenge; // Bei ein/ausnahme: Wie viel nach Aktion
  final String? zusatzInformationen;

  LogEntryModel(
      {required this.timestamp,
      required this.logReason,
      this.lagerplatzId,
      this.artikelGWID,
      this.menge,
      this.neueMenge,
      this.zusatzInformationen});

  Map<String, dynamic> toMap() {
    return {
      'timestamp':
          "${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}",
      'logReason': logReason.name,
      'lagerplatzId': lagerplatzId,
      'artikelGWID': artikelGWID,
      'menge': menge,
      'neueMenge': neueMenge,
      'zusatzInformationen': zusatzInformationen
    };
  }

  factory LogEntryModel.fromMap(Map<String, dynamic> map) {
    return LogEntryModel(
        timestamp: DateTime.parse(map['timestamp']),
        logReason: LogReason.values.firstWhere(
          (e) => e.name == map['logReason'],
        ),
        lagerplatzId: map['lagerplatzId'],
        artikelGWID: map['artikelGWID'],
        menge: map['menge'],
        neueMenge: map['neueMenge'],
        zusatzInformationen: map['zusatzInformationen']);
  }

  @override
  String toString() {
    final List<String> parts = [];

    parts.add("$timestamp");
    parts.add(logReason.name.replaceAll('_', ' '));

    if (lagerplatzId != null) {
      parts.add("Lagerplatz-ID: $lagerplatzId");
    }
    if (artikelGWID != null) {
      parts.add("Artikel-GWID: $artikelGWID");
    }
    if (menge != null) {
      parts.add("Menge: $menge");
    }
    if (neueMenge != null) {
      parts.add("Neue Menge: $neueMenge");
    }
    if (zusatzInformationen != null) {
      parts.add("$zusatzInformationen");
    }

    return parts.join(" | ");
  }
}
