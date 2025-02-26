import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/model/lagerlistenentry.dart';
import 'package:lagerverwaltung/service/lagerlistenverwaltung_service.dart';
import 'package:lagerverwaltung/utils/scan_artikel_code_after_lagerplatz.dart';
import 'package:lagerverwaltung/utils/showdialog.dart';
import 'package:lagerverwaltung/widget/background/animated_background.dart';
import 'package:lagerverwaltung/widget/custom_app_bar.dart';
import 'package:lagerverwaltung/page/edit_artikel_page.dart';

class LagerplatzPage extends StatefulWidget {
  final String lagerplatzId;

  const LagerplatzPage({super.key, required this.lagerplatzId});

  @override
  _LagerplatzPageState createState() => _LagerplatzPageState();
}

class _LagerplatzPageState extends State<LagerplatzPage> {
  final lagerlistenVerwaltungsService =
      GetIt.instance<LagerlistenVerwaltungsService>();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar:
          CustomAppBar(title: "Artikel in Lagerplatz: ${widget.lagerplatzId}"),
      child: AnimatedBackground(
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
                                builder: (context) =>
                                    EditArtikelPage(entry: entry),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.beschreibung ?? "Unbenannt!",
                                    softWrap: true,
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                    style: CupertinoTheme.of(context)
                                        .textTheme
                                        .textStyle
                                        .merge(TextStyle(fontSize: 16)),
                                  ),
                                ),
                                const SizedBox(width: 8),
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
              const SizedBox(height: 16),
              CupertinoButton(
                color: CupertinoColors.systemRed,
                onPressed: _deleteLagerplatz,
                child: Text(
                  'Lösche Lagerplatz',
                  style:
                      CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                            color: CupertinoColors.white,
                          ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteLagerplatz() async {
    bool cancel = await ShowDialogTwoOptions.isFirstOptionClicked(
        context,
        "Lagerplatz Löschen?",
        "Möchten Sie den Lagerplatz mit der ID ${widget.lagerplatzId} und alle dazugehörigen Artikel wirklich löschen?",
        "Abbrechen",
        "Löschen");
    if (cancel) {
      return;
    }
    lagerlistenVerwaltungsService.deleteLagerplatz(widget.lagerplatzId);
    Navigator.pop(context);
  }
}
