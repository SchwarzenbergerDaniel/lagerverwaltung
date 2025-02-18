import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/config/constants.dart';
import 'package:lagerverwaltung/model/lagerlistenentry.dart';
import 'package:lagerverwaltung/service/codescanner_service.dart';
import 'package:lagerverwaltung/service/lagerlistenverwaltung_service.dart';
import 'package:lagerverwaltung/utils/showsnackbar.dart';
import 'package:lagerverwaltung/widget/background/animated_background.dart';
import 'package:lagerverwaltung/widget/custom_app_bar.dart';

class InventurPage extends StatefulWidget {
  final String lagerplatzId;
  const InventurPage({super.key, required this.lagerplatzId});

  @override
  _InventurPageState createState() => _InventurPageState();
}

class _InventurPageState extends State<InventurPage> {
  final lagerListenVerwaltungsService =
      GetIt.instance<LagerlistenVerwaltungsService>();
  final codeScannerService = GetIt.instance<CodeScannerService>();

  List<LagerlistenEntry> sollBestand = [];
  List<LagerlistenEntry> istBestand = [];

  @override
  void initState() {
    super.initState();
    _loadSollBestand();
  }

  /// Sollbestand wird geladen
  void _loadSollBestand() async {
    var bestand = await lagerListenVerwaltungsService
        .getLagerlisteByLagerplatz(widget.lagerplatzId);
    setState(() {
      sollBestand = List.from(bestand);
      istBestand = List.from(
        bestand.map(
          (e) => LagerlistenEntry(
              menge: e.menge,
              artikelGWID: e.artikelGWID,
              fach: e.fach,
              regal: e.regal,
              lagerplatzId: e.lagerplatzId,
              arikelFirmenId: e.arikelFirmenId,
              beschreibung: e.beschreibung,
              kunde: e.kunde,
              ablaufdatum: e.ablaufdatum,
              mindestMenge: e.mindestMenge),
        ),
      );
    });
  }

  /// Gescannter Artikel wird Ist Liste hinzugefügt
  Future<void> _artikelScannen() async {
    String? artikelGWID =
        await codeScannerService.getCodeByScan(context, "Artikel Code scannen");
    if (artikelGWID == null ||
        artikelGWID.isEmpty ||
        artikelGWID == Constants.EXIT_RETURN_VALUE) {
      return;
    }

    setState(() {
      bool existiert = false;
      for (var entry in istBestand) {
        if (entry.artikelGWID == artikelGWID) {
          entry.menge = (entry.menge ?? 0) + 1;
          existiert = true;
          break;
        }
      }
      if (!existiert) {
        final entry = LagerlistenEntry(
            artikelGWID: artikelGWID,
            lagerplatzId: widget.lagerplatzId,
            menge: 1);

        istBestand.add(entry);
        lagerListenVerwaltungsService.addArtikelToLagerliste(entry);
      }
    });
  }

  /// Ändert Menge für Artikel
  void _updateMenge(int index, int neueMenge) {
    setState(() {
      istBestand[index].menge = neueMenge;
    });
  }

  /// Speicherung der Inventur
  Future _inventurAbschliessen() async {
    await lagerListenVerwaltungsService.speichereInventur(
        widget.lagerplatzId, sollBestand, istBestand);
    await Showsnackbar.showSnackBar(context, "Inventur abgeschlossen!");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomAppBar(
        title: "Inventur: ${widget.lagerplatzId}",
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _inventurAbschliessen,
          child: const Text("Fertig"),
        ),
      ),
      child: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CupertinoButton.filled(
                  onPressed: _artikelScannen,
                  child: Text("Artikel hinzufügen"),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: istBestand.length,
                  itemBuilder: (context, index) {
                    var entry = istBestand[index];
                    return createListTile(entry, index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget createListTile(LagerlistenEntry entry, int index) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: CupertinoListTile(
        title: Text("Artikel: ${entry.artikelGWID}"),
        subtitle: Text(
          "Soll: ${sollBestand.where((e) => e.artikelGWID == entry.artikelGWID).fold(0, (sum, e) => sum + (e.menge ?? 0))} | Ist: ${entry.menge}",
          style: CupertinoTheme.of(context).textTheme.textStyle,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(Icons.remove, color: CupertinoColors.systemRed),
              onPressed: () {
                if ((entry.menge ?? 0) > 0) {
                  _updateMenge(index, (entry.menge ?? 0) - 1);
                }
              },
            ),
            SizedBox(
              width: 50,
              child: CupertinoTextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  int? menge = int.tryParse(value);
                  if (menge != null) {
                    _updateMenge(index, menge);
                  }
                },
                placeholderStyle: const TextStyle(
                    color: CupertinoColors.white,
                    backgroundColor: CupertinoColors.black),
                placeholder: "${entry.menge}",
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(Icons.add, color: CupertinoColors.systemGreen),
              onPressed: () {
                _updateMenge(index, (entry.menge ?? 0) + 1);
              },
            ),
          ],
        ),
      ),
    );
  }
}
