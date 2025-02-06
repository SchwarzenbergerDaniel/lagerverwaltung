import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/model/lagerlistenentry.dart';
import 'package:lagerverwaltung/service/lagerlistenverwaltung_service.dart';
import 'package:lagerverwaltung/utils/scan_artikel_code_after_lagerplatz.dart';
import 'package:lagerverwaltung/widget/custom_leading_button.dart';
import 'package:lagerverwaltung/page/edit_artikel_page.dart';

class LagerlistePage extends StatefulWidget {
  final String lagerplatzId;

  const LagerlistePage({super.key, required this.lagerplatzId});

  @override
  _LagerlistePageState createState() => _LagerlistePageState();
}

class _LagerlistePageState extends State<LagerlistePage> {
  final lagerlistenVerwaltungsService =
      GetIt.instance<LagerlistenVerwaltungsService>();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          "Artikel in Lagerplatz: ${widget.lagerplatzId}",
          style: CupertinoTheme.of(context).textTheme.textStyle,
        ),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        leading: CustomBackButton(),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            CupertinoButton.filled(
              onPressed: () async {
                await scanArtikelCodeAfterLagerplatz(
                    context, widget.lagerplatzId);

                setState(() {}); // Rebuild the page
              },
              child: Text(
                'Neuen Artikel hinzufügen',
                style: CupertinoTheme.of(context).textTheme.textStyle,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<LagerlistenEntry>>(
                future: lagerlistenVerwaltungsService
                    .getLagerlisteByLagerplatz(widget.lagerplatzId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CupertinoActivityIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(
                      "Fehler: ${snapshot.error}",
                      style: CupertinoTheme.of(context).textTheme.textStyle,
                    ));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Text(
                      "Keine Artikel gefunden.",
                      style: CupertinoTheme.of(context).textTheme.textStyle,
                    ));
                  }

                  final entries = snapshot.data!;
                  return ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return CupertinoButton(
                        padding: const EdgeInsets.all(0),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => EditArtikelPage(
                                entry: entry,
                                isEditable: true,
                              ),
                            ),
                          );
                          setState(() => {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
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
