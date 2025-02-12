import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/model/lagerlistenentry.dart';
import 'package:lagerverwaltung/service/lagerlistenverwaltung_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Testhelper {
  static Future clearLocalStorage() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();
  }

  static Future add_default_values() async {
    final LagerlistenVerwaltungsService lagerlistenVerwaltungsService =
        GetIt.instance<LagerlistenVerwaltungsService>();

    await lagerlistenVerwaltungsService.addEmptyLagerplatz("eins");
    await lagerlistenVerwaltungsService.addEmptyLagerplatz("zwei");
    await lagerlistenVerwaltungsService.addEmptyLagerplatz("drei");

    for (var artikel in getEntries()) {
      await lagerlistenVerwaltungsService.addArtikelToLagerliste(artikel);
    }
  }

  static List<LagerlistenEntry> getEntries() {
    return [
      // LAGERPLATZ 1:
      LagerlistenEntry(
          fach: "fach1",
          regal: "regal",
          lagerplatzId: "eins",
          artikelGWID: "glas",
          arikelFirmenId: "firmaID",
          beschreibung:
              "Glas, welches in Regal eins ist und kein Ablaufdatum hat",
          kunde: "Kunde",
          ablaufdatum: null,
          menge: 10,
          mindestMenge: 5),
      LagerlistenEntry(
          fach: "fach1",
          regal: "regal",
          lagerplatzId: "eins",
          artikelGWID: "laptop",
          arikelFirmenId: "firmaID",
          beschreibung: "Laptop, welcher in Regal eins ist",
          kunde: "Kunde",
          ablaufdatum: DateTime.now().add(const Duration(days: 10)),
          menge: 10,
          mindestMenge: 5),
      LagerlistenEntry(
          fach: "fach1",
          regal: "regal",
          lagerplatzId: "eins",
          artikelGWID: "stift",
          arikelFirmenId: "firmaID",
          beschreibung: "Stift, welcher in Regal eins ist",
          kunde: "Kunde",
          ablaufdatum: DateTime.now().add(const Duration(days: 10)),
          menge: 10,
          mindestMenge: 5),

      // LAGERPLATZ 2
      LagerlistenEntry(
          fach: "fach2",
          regal: "regal2",
          lagerplatzId: "zwei",
          artikelGWID: "fernseher",
          arikelFirmenId: "firmaID2",
          beschreibung:
              "Fernseher, welcher in Regal zwei ist und die Mindestmenge nicht erreicht hat und heute abläuft",
          kunde: "Kunde2",
          ablaufdatum: DateTime.now(),
          menge: 2,
          mindestMenge: 5),
      LagerlistenEntry(
          fach: "fach2",
          regal: "regal2",
          lagerplatzId: "zwei",
          artikelGWID: "handy",
          arikelFirmenId: "firmaID2",
          beschreibung: "Handy, welches in Regal zwei ist",
          kunde: "Kunde2",
          ablaufdatum: DateTime.now().add(const Duration(days: 10)),
          menge: 10,
          mindestMenge: 5),
      LagerlistenEntry(
          fach: "fach2",
          regal: "regal2",
          lagerplatzId: "zwei",
          artikelGWID: "tastatur",
          arikelFirmenId: "firmaID2",
          beschreibung:
              "Tastatur, welche in Regal zwei ist und seit 10 Tagen abgelaufen ist",
          kunde: "Kund2e",
          ablaufdatum: DateTime.now().add(const Duration(days: -10)),
          menge: 10,
          mindestMenge: 5),

      //LAGERPLATZ 3
      LagerlistenEntry(
          fach: "fach3",
          regal: "regal3",
          lagerplatzId: "drei",
          artikelGWID: "battlepass",
          arikelFirmenId: "firmaID3",
          beschreibung:
              "Battle-Pass, welcher in Regal drei ist und die Mindestmenge nicht erreicht hat",
          kunde: "Kunde3",
          ablaufdatum: DateTime.now(),
          menge: 2,
          mindestMenge: 5),
      LagerlistenEntry(
          fach: "fach3",
          regal: "regal3",
          lagerplatzId: "drei",
          artikelGWID: "handy",
          arikelFirmenId: "firmaID3",
          beschreibung: "Groschen, welcher in Regal drei ist",
          kunde: "Kunde3",
          ablaufdatum: DateTime.now().add(const Duration(days: 10)),
          menge: 10,
          mindestMenge: 5),
      LagerlistenEntry(
          fach: "fach3",
          regal: "regal3",
          lagerplatzId: "drei",
          artikelGWID: "tastatur",
          arikelFirmenId: "firmaID3",
          beschreibung:
              "Playstation, welche in Regal drei ist und heute abläuft",
          kunde: "Kunde3",
          ablaufdatum: DateTime.now().add(const Duration(days: -10)),
          menge: 20,
          mindestMenge: 5),
    ];
  }
}
