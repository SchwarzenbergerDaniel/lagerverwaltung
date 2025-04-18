import 'package:flutter/cupertino.dart';
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

    await lagerlistenVerwaltungsService.addEmptyLagerplatz("regal.fach1");
    await lagerlistenVerwaltungsService.addEmptyLagerplatz("regal2.fach2");
    await lagerlistenVerwaltungsService.addEmptyLagerplatz("regal3.fach3");

    for (var artikel in getEntries()) {
      await lagerlistenVerwaltungsService.addArtikelToLagerliste(artikel);
    }
  }

  static List<LagerlistenEntry> getEntries() {
    return [
      // LAGERPLATZ 1:
      LagerlistenEntry(
        fach: "fach1",
        regal: "regal1",
        lagerplatzId: "regal1.fach1",
        artikelGWID: "monitor",
        arikelFirmenId: "firmaA1",
        beschreibung: "Monitor in regal1.fach1",
        kunde: "KundeA",
        ablaufdatum: DateTime.now().add(const Duration(days: 30)),
        menge: 5,
        mindestMenge: 2,
      ),
      LagerlistenEntry(
        fach: "fach2",
        regal: "regal1",
        lagerplatzId: "regal1.fach2",
        artikelGWID: "laptop",
        arikelFirmenId: "firmaA1",
        beschreibung: "Laptop in regal1.fach2",
        kunde: "KundeA",
        ablaufdatum: null, // Kein Ablaufdatum
        menge: 2,
        mindestMenge: 1,
      ),
      LagerlistenEntry(
        fach: "fach3",
        regal: "regal1",
        lagerplatzId: "regal1.fach3",
        artikelGWID: "stift",
        arikelFirmenId: "firmaA1",
        beschreibung: "Stift in regal1.fach3",
        kunde: "KundeA",
        ablaufdatum: DateTime.now().add(const Duration(days: -5)), // abgelaufen
        menge: 10,
        mindestMenge: 5,
      ),
      LagerlistenEntry(
        fach: "fach4",
        regal: "regal1",
        lagerplatzId: "regal1.fach4",
        artikelGWID: "ordner",
        arikelFirmenId: "firmaA1",
        beschreibung: "Ordner in regal1.fach4",
        kunde: "KundeA",
        ablaufdatum: DateTime.now().add(const Duration(days: 7)),
        menge: 15,
        mindestMenge: 5,
      ),
      LagerlistenEntry(
        fach: "fach5",
        regal: "regal1",
        lagerplatzId: "regal1.fach5",
        artikelGWID: "tastatur",
        arikelFirmenId: "firmaA1",
        beschreibung: "Tastatur in regal1.fach5",
        kunde: "KundeA",
        ablaufdatum: DateTime.now().add(const Duration(days: 1)),
        menge: 4,
        mindestMenge: 2,
      ),
      LagerlistenEntry(
        fach: "fach6",
        regal: "regal1",
        lagerplatzId: "regal1.fach6",
        artikelGWID: "telefon",
        arikelFirmenId: "firmaA1",
        beschreibung: "Telefon in regal1.fach6",
        kunde: "KundeA",
        ablaufdatum: DateTime.now().add(const Duration(days: -2)), // abgelaufen
        menge: 1,
        mindestMenge: 1,
      ),
      LagerlistenEntry(
        fach: "fach7",
        regal: "regal1",
        lagerplatzId: "regal1.fach7",
        artikelGWID: "mauspad",
        arikelFirmenId: "firmaA1",
        beschreibung: "Mauspad in regal1.fach7",
        kunde: "KundeA",
        ablaufdatum: null,
        menge: 6,
        mindestMenge: 3,
      ),
      LagerlistenEntry(
        fach: "fach8",
        regal: "regal1",
        lagerplatzId: "regal1.fach8",
        artikelGWID: "usb-kabel",
        arikelFirmenId: "firmaA1",
        beschreibung: "USB-Kabel in regal1.fach8",
        kunde: "KundeA",
        ablaufdatum: DateTime.now().add(const Duration(days: 14)),
        menge: 20,
        mindestMenge: 5,
      ),
      LagerlistenEntry(
        fach: "fach9",
        regal: "regal1",
        lagerplatzId: "regal1.fach9",
        artikelGWID: "headset",
        arikelFirmenId: "firmaA1",
        beschreibung: "Headset in regal1.fach9",
        kunde: "KundeA",
        ablaufdatum: DateTime.now().add(const Duration(days: 10)),
        menge: 2,
        mindestMenge: 1,
      ),
      LagerlistenEntry(
        fach: "fach10",
        regal: "regal1",
        lagerplatzId: "regal1.fach10",
        artikelGWID: "glas",
        arikelFirmenId: "firmaA1",
        beschreibung: "Glas in regal1.fach10",
        kunde: "KundeA",
        ablaufdatum: null,
        menge: 12,
        mindestMenge: 5,
      ),

      // ------------------ REGAL 2 ------------------
      LagerlistenEntry(
        fach: "fach1",
        regal: "regal2",
        lagerplatzId: "regal2.fach1",
        artikelGWID: "fernseher",
        arikelFirmenId: "firmaB1",
        beschreibung: "Fernseher in regal2.fach1",
        kunde: "KundeB",
        ablaufdatum: DateTime.now(), // läuft heute ab
        menge: 1,
        mindestMenge: 2,
      ),
      LagerlistenEntry(
        fach: "fach2",
        regal: "regal2",
        lagerplatzId: "regal2.fach2",
        artikelGWID: "konsole",
        arikelFirmenId: "firmaB1",
        beschreibung: "Spielkonsole in regal2.fach2",
        kunde: "KundeB",
        ablaufdatum: DateTime.now().add(const Duration(days: 3)),
        menge: 3,
        mindestMenge: 2,
      ),
      LagerlistenEntry(
        fach: "fach3",
        regal: "regal2",
        lagerplatzId: "regal2.fach3",
        artikelGWID: "controller",
        arikelFirmenId: "firmaB1",
        beschreibung: "Controller in regal2.fach3",
        kunde: "KundeB",
        ablaufdatum: DateTime.now().add(const Duration(days: -1)), // abgelaufen
        menge: 5,
        mindestMenge: 3,
      ),
      LagerlistenEntry(
        fach: "fach4",
        regal: "regal2",
        lagerplatzId: "regal2.fach4",
        artikelGWID: "bluetooth-adapter",
        arikelFirmenId: "firmaB1",
        beschreibung: "Bluetooth-Adapter in regal2.fach4",
        kunde: "KundeB",
        ablaufdatum: DateTime.now().add(const Duration(days: 30)),
        menge: 10,
        mindestMenge: 5,
      ),
      LagerlistenEntry(
        fach: "fach5",
        regal: "regal2",
        lagerplatzId: "regal2.fach5",
        artikelGWID: "lautsprecher",
        arikelFirmenId: "firmaB1",
        beschreibung: "Lautsprecher in regal2.fach5",
        kunde: "KundeB",
        ablaufdatum: null,
        menge: 2,
        mindestMenge: 1,
      ),
      LagerlistenEntry(
        fach: "fach6",
        regal: "regal2",
        lagerplatzId: "regal2.fach6",
        artikelGWID: "powerbank",
        arikelFirmenId: "firmaB1",
        beschreibung: "Powerbank in regal2.fach6",
        kunde: "KundeB",
        ablaufdatum: DateTime.now().add(const Duration(days: 5)),
        menge: 7,
        mindestMenge: 3,
      ),
      LagerlistenEntry(
        fach: "fach7",
        regal: "regal2",
        lagerplatzId: "regal2.fach7",
        artikelGWID: "router",
        arikelFirmenId: "firmaB1",
        beschreibung: "Router in regal2.fach7",
        kunde: "KundeB",
        ablaufdatum: DateTime.now().add(const Duration(days: -3)), // abgelaufen
        menge: 2,
        mindestMenge: 2,
      ),
      LagerlistenEntry(
        fach: "fach8",
        regal: "regal2",
        lagerplatzId: "regal2.fach8",
        artikelGWID: "festplatte",
        arikelFirmenId: "firmaB1",
        beschreibung: "Externe Festplatte in regal2.fach8",
        kunde: "KundeB",
        ablaufdatum: null,
        menge: 4,
        mindestMenge: 2,
      ),
      LagerlistenEntry(
        fach: "fach9",
        regal: "regal2",
        lagerplatzId: "regal2.fach9",
        artikelGWID: "mikrowelle",
        arikelFirmenId: "firmaB1",
        beschreibung: "Mikrowelle in regal2.fach9",
        kunde: "KundeB",
        ablaufdatum: DateTime.now().add(const Duration(days: 8)),
        menge: 1,
        mindestMenge: 1,
      ),
      LagerlistenEntry(
        fach: "fach10",
        regal: "regal2",
        lagerplatzId: "regal2.fach10",
        artikelGWID: "bleistift",
        arikelFirmenId: "firmaB1",
        beschreibung: "Bleistift in regal2.fach10",
        kunde: "KundeB",
        ablaufdatum: DateTime.now().add(const Duration(days: 1)),
        menge: 10,
        mindestMenge: 5,
      ),

      // ------------------ REGAL 3 ------------------
      LagerlistenEntry(
        fach: "fach1",
        regal: "regal3",
        lagerplatzId: "regal3.fach1",
        artikelGWID: "buerostuhl",
        arikelFirmenId: "firmaC1",
        beschreibung: "Bürostuhl in regal3.fach1",
        kunde: "KundeC",
        ablaufdatum: null,
        menge: 2,
        mindestMenge: 1,
      ),
      LagerlistenEntry(
        fach: "fach2",
        regal: "regal3",
        lagerplatzId: "regal3.fach2",
        artikelGWID: "schreibtisch",
        arikelFirmenId: "firmaC1",
        beschreibung: "Schreibtisch in regal3.fach2",
        kunde: "KundeC",
        ablaufdatum: DateTime.now().add(const Duration(days: 20)),
        menge: 1,
        mindestMenge: 1,
      ),
      LagerlistenEntry(
        fach: "fach3",
        regal: "regal3",
        lagerplatzId: "regal3.fach3",
        artikelGWID: "lampe",
        arikelFirmenId: "firmaC1",
        beschreibung: "Lampe in regal3.fach3",
        kunde: "KundeC",
        ablaufdatum: DateTime.now().add(const Duration(days: -1)), // abgelaufen
        menge: 5,
        mindestMenge: 2,
      ),
      LagerlistenEntry(
        fach: "fach4",
        regal: "regal3",
        lagerplatzId: "regal3.fach4",
        artikelGWID: "drucker",
        arikelFirmenId: "firmaC1",
        beschreibung: "Drucker in regal3.fach4",
        kunde: "KundeC",
        ablaufdatum: DateTime.now().add(const Duration(days: 15)),
        menge: 2,
        mindestMenge: 1,
      ),
      LagerlistenEntry(
        fach: "fach5",
        regal: "regal3",
        lagerplatzId: "regal3.fach5",
        artikelGWID: "scanner",
        arikelFirmenId: "firmaC1",
        beschreibung: "Scanner in regal3.fach5",
        kunde: "KundeC",
        ablaufdatum: null,
        menge: 1,
        mindestMenge: 1,
      ),
      LagerlistenEntry(
        fach: "fach6",
        regal: "regal3",
        lagerplatzId: "regal3.fach6",
        artikelGWID: "papier",
        arikelFirmenId: "firmaC1",
        beschreibung: "Papier in regal3.fach6",
        kunde: "KundeC",
        ablaufdatum: DateTime.now().add(const Duration(days: 5)),
        menge: 500,
        mindestMenge: 200,
      ),
      LagerlistenEntry(
        fach: "fach7",
        regal: "regal3",
        lagerplatzId: "regal3.fach7",
        artikelGWID: "buch",
        arikelFirmenId: "firmaC1",
        beschreibung: "Buch in regal3.fach7",
        kunde: "KundeC",
        ablaufdatum: null,
        menge: 10,
        mindestMenge: 5,
      ),
      LagerlistenEntry(
        fach: "fach8",
        regal: "regal3",
        lagerplatzId: "regal3.fach8",
        artikelGWID: "playstation",
        arikelFirmenId: "firmaC1",
        beschreibung: "Playstation in regal3.fach8 (abgelaufen)",
        kunde: "KundeC",
        ablaufdatum: DateTime.now().add(const Duration(days: -7)),
        menge: 2,
        mindestMenge: 1,
      ),
      LagerlistenEntry(
        fach: "fach9",
        regal: "regal3",
        lagerplatzId: "regal3.fach9",
        artikelGWID: "switch",
        arikelFirmenId: "firmaC1",
        beschreibung: "Switch in regal3.fach9",
        kunde: "KundeC",
        ablaufdatum: DateTime.now().add(const Duration(days: 3)),
        menge: 2,
        mindestMenge: 1,
      ),
      LagerlistenEntry(
        fach: "fach10",
        regal: "regal3",
        lagerplatzId: "regal3.fach10",
        artikelGWID: "blu-ray-player",
        arikelFirmenId: "firmaC1",
        beschreibung: "Blu-ray-Player in regal3.fach10",
        kunde: "KundeC",
        ablaufdatum: null,
        menge: 1,
        mindestMenge: 1,
      )
    ];
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Testhelper.clearLocalStorage();
}
