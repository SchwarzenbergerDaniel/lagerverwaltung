//TODO: Welche Felder sind required? Antwort von Putzinger warten.
class LagerListenEntry {
  // Instanzen
  String? fach;
  String? regal;
  String? regalId;
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
    if (regalId == null || artikelGWID == null) {
      return null;
    }
    return regalId! + " " + artikelGWID!;
  }

  //TODO: 	static LagerListenEntry(String csvLine) => Linie von der csv liste zu Entry parsen.

  // Konstruktor
  LagerListenEntry({
    this.fach,
    this.regal,
    this.regalId,
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
}
