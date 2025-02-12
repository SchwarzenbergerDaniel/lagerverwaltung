import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/model/lagerlistenentry.dart';
import 'package:lagerverwaltung/service/codescanner_service.dart';
import 'package:lagerverwaltung/service/lagerlistenverwaltung_service.dart';
import 'package:lagerverwaltung/utils/showdialog.dart';
import 'package:lagerverwaltung/utils/showsnackbar.dart';

class InventurPage extends StatefulWidget {
  final String lagerplatzId;
  const InventurPage({super.key, required this.lagerplatzId});

  @override
  _InventurPageState createState() => _InventurPageState();
}

class _InventurPageState extends State<InventurPage> {
  final lagerListenVerwaltungsService = GetIt.instance<LagerlistenVerwaltungsService>();
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
    var bestand = await lagerListenVerwaltungsService.getLagerlisteByLagerplatz(widget.lagerplatzId);
    setState(() {
      sollBestand = List.from(bestand);
      istBestand = List.from(bestand.map((e) => LagerlistenEntry(
            artikelGWID: e.artikelGWID,
            lagerplatzId: e.lagerplatzId,
            menge: e.menge ?? 0,
          )));
    });
  }

  /// Gescannter Artikel wird Ist Liste hinzugefügt
  Future<void> _artikelScannen() async {
    String? artikelGWID = await codeScannerService.getCodeByScan(context, "Artikel Code scannen");
    if (artikelGWID == null || artikelGWID.isEmpty) return;

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
        istBestand.add(LagerlistenEntry(artikelGWID: artikelGWID, lagerplatzId: widget.lagerplatzId, menge: 1));
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
  void _inventurAbschliessen() {
    //lagerListenVerwaltungsService.speichereInventur(widget.lagerplatzId, istBestand);
    Showsnackbar.showSnackBar(context, "Inventur abgeschlossen!");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Inventur: ${widget.lagerplatzId}"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text("Fertig"),
          onPressed: _inventurAbschliessen,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoButton.filled(
                child: Text("Artikel scannen"),
                onPressed: _artikelScannen,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: istBestand.length,
                itemBuilder: (context, index) {
                  var entry = istBestand[index];

                  return CupertinoListTile(
                    title: Text("Artikel: ${entry.artikelGWID}"),
                    subtitle: Text(
                      "Soll: ${sollBestand.where((e) => e.artikelGWID == entry.artikelGWID).fold(0, (sum, e) => sum + (e.menge ?? 0))} | Ist: ${entry.menge}",
                     
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Icon(CupertinoIcons.minus_circle, color: CupertinoColors.systemRed),
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
                            placeholder: "${entry.menge}",
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Icon(CupertinoIcons.add_circled, color: CupertinoColors.systemGreen),
                          onPressed: () {
                            _updateMenge(index, (entry.menge ?? 0) + 1);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
