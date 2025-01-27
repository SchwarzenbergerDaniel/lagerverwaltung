import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lagerverwaltung/model/LagerlistenEntry.dart';
import 'package:lagerverwaltung/utils/scan_artikel_code_after_lagerplatz.dart';
import 'package:lagerverwaltung/widget/custom_leading_button.dart';
import 'package:lagerverwaltung/page/artikel_page.dart';

class LagerlistePage extends StatefulWidget {
  final List<LagerListenEntry> entries;
  final String lagerplatzId;

  const LagerlistePage({Key? key, required this.entries, required this.lagerplatzId}) : super(key: key);

  @override
  _LagerlistePageState createState() => _LagerlistePageState();
}

class _LagerlistePageState extends State<LagerlistePage> {
  @override
  Widget build(BuildContext context) {
    String lagerplatzId = widget.lagerplatzId;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Lagerliste: $lagerplatzId"),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        leading: CustomBackButton(),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            CupertinoButton.filled(
              onPressed: () async {
                scanArtikelCodeAfterLagerplatz(context, widget.lagerplatzId);
              },
              child: const Text('Neuen Artikel hinzufügen'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.entries.length,
                itemBuilder: (context, index) {
                  final entry = widget.entries[index];
                  return CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => ArtikelPage(entry: entry,),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: CupertinoColors.systemGrey4,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.beschreibung ?? "Unbennant!",
                            style: const TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.white,
                            ),
                          ),
                          const Icon(
                            Icons.edit_outlined,
                            color: CupertinoColors.systemGrey,
                          ),
                        ],
                      ),
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