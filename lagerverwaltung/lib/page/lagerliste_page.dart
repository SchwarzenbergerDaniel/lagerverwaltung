import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:lagerverwaltung/model/lagerlistenentry.dart';
import 'package:lagerverwaltung/page/edit_artikel_page.dart';
import 'package:lagerverwaltung/service/lagerlistenverwaltung_service.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';
import 'package:lagerverwaltung/widget/background/animated_background.dart';
import 'package:lagerverwaltung/widget/custom_app_bar.dart';

enum SortType { ablaufdatum, lagerplatz, alphabetisch, mindestmengeErreicht }

class LagerlistePage extends StatefulWidget {
  List<LagerlistenEntry> lagerlistenEntries;

  LagerlistePage({super.key, required this.lagerlistenEntries});

  @override
  State<LagerlistePage> createState() => _LagerlistePageState();
}

class _LagerlistePageState extends State<LagerlistePage> {
  final TextEditingController _searchController = TextEditingController();
  late List<LagerlistenEntry> _filteredEntries;
  SortType _currentSort = SortType.ablaufdatum;
  final localSettingsManagerService =
      GetIt.instance<LocalSettingsManagerService>();
  @override
  void initState() {
    super.initState();
    _filteredEntries = widget.lagerlistenEntries;
    _searchController.addListener(_filterEntries);
    _applySort();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterEntries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEntries = widget.lagerlistenEntries.where((entry) {
        final artikelGWID = entry.artikelGWID?.toLowerCase() ?? '';
        final beschreibung = entry.beschreibung?.toLowerCase() ?? '';
        return artikelGWID.contains(query) || beschreibung.contains(query);
      }).toList();
      _applySort();
    });
  }

  int _compareByAblaufdatum(LagerlistenEntry a, LagerlistenEntry b) {
    final aDate = a.ablaufdatum;
    final bDate = b.ablaufdatum;
    if (aDate == null && bDate == null) return 0;
    if (aDate == null) return 1;
    if (bDate == null) return -1;
    return aDate.compareTo(bDate);
  }

  int _compareByLagerplatz(LagerlistenEntry a, LagerlistenEntry b) {
    final aLager = a.lagerplatzId ?? '';
    final bLager = b.lagerplatzId ?? '';
    return aLager.compareTo(bLager);
  }

  int _compareAlphabetically(LagerlistenEntry a, LagerlistenEntry b) {
    final aName = a.artikelGWID ?? '';
    final bName = b.artikelGWID ?? '';
    return aName.compareTo(bName);
  }

  int _compareByMindestmengeErreicht(LagerlistenEntry a, LagerlistenEntry b) {
    int getRank(LagerlistenEntry entry) {
      if (entry.menge == null || entry.mindestMenge == null) return 3;
      if (entry.menge! < entry.mindestMenge!) return 0;
      if (entry.menge == entry.mindestMenge) return 1;
      return 2;
    }

    return getRank(a).compareTo(getRank(b));
  }

  void _applySort() {
    setState(() {
      _filteredEntries.sort((a, b) {
        switch (_currentSort) {
          case SortType.ablaufdatum:
            return _compareByAblaufdatum(a, b);
          case SortType.lagerplatz:
            return _compareByLagerplatz(a, b);
          case SortType.alphabetisch:
            return _compareAlphabetically(a, b);
          case SortType.mindestmengeErreicht:
            return _compareByMindestmengeErreicht(a, b);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomAppBar(title: "Alle Artikel"),
      child: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Search Field
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CupertinoTextField(
                  controller: _searchController,
                  placeholder: 'Nach Artikel suchen...',
                ),
              ),
              // Sorting Options
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoActionSheet(
                            title: const Text("Sortieren nach"),
                            actions: [
                              CupertinoActionSheetAction(
                                child: const Text("Ablaufdatum"),
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _currentSort = SortType.ablaufdatum;
                                    _applySort();
                                  });
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: const Text("Lagerplatz"),
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _currentSort = SortType.lagerplatz;
                                    _applySort();
                                  });
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: const Text("Alphabetisch"),
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _currentSort = SortType.alphabetisch;
                                    _applySort();
                                  });
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: const Text("Mindestmenge erreicht"),
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _currentSort =
                                        SortType.mindestmengeErreicht;
                                    _applySort();
                                  });
                                },
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              child: const Text("Abbrechen"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_sortTypeLabel(_currentSort)),
                        const Icon(Icons.sort)
                      ],
                    ),
                  ),
                ),
              ),

              // List of Articles
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredEntries.length,
                  itemBuilder: (context, index) =>
                      _buildArticleCard(_filteredEntries[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _sortTypeLabel(SortType type) {
    switch (type) {
      case SortType.ablaufdatum:
        return "Ablaufdatum";
      case SortType.lagerplatz:
        return "Lagerplatz";
      case SortType.alphabetisch:
        return "Alphabetisch";
      case SortType.mindestmengeErreicht:
        return "Mindestmenge erreicht";
    }
  }

  Widget _buildArticleCard(LagerlistenEntry entry) {
    final bool isExpired =
        entry.ablaufdatum != null && DateTime.now().isAfter(entry.ablaufdatum!);
    bool isWhite = localSettingsManagerService.getIsBright();

    final Color ablaufDatumColor = isExpired ? Colors.redAccent : Colors.green;

    final bool isBelowMinimum = (entry.menge != null &&
        entry.mindestMenge != null &&
        entry.menge! < entry.mindestMenge!);
    final Color mengeColor = isBelowMinimum
        ? Colors.redAccent
        : (isWhite ? Colors.grey.shade800 : Colors.white70);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => EditArtikelPage(
                entry: entry,
              ),
            ),
          );
          widget.lagerlistenEntries =
              await GetIt.instance<LagerlistenVerwaltungsService>()
                  .artikelEntries;
          _filterEntries();
          setState(() {});
        },
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            color: isWhite ? Colors.grey[300] : Colors.grey.shade900,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.artikelGWID ?? "Keine ArtikelGWID",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: CupertinoTheme.of(context).primaryColor,
                        ),
                      ),
                      const Icon(
                        Icons.article,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Lagerplatz: ${entry.lagerplatzId ?? 'N/A'}",
                    style: TextStyle(
                        fontSize: 16,
                        color: isWhite ? Colors.grey.shade800 : Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Regal: ${entry.regal ?? 'N/A'}",
                        style: TextStyle(
                            fontSize: 16,
                            color: isWhite
                                ? Colors.grey.shade800
                                : Colors.white70),
                      ),
                      Text(
                        "Fach: ${entry.fach ?? 'N/A'}",
                        style: TextStyle(
                            fontSize: 16,
                            color: isWhite
                                ? Colors.grey.shade800
                                : Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Menge: ${entry.menge?.toString() ?? 'N/A'}",
                        style: TextStyle(fontSize: 16, color: mengeColor),
                      ),
                      Text(
                        "Mindestmenge: ${entry.mindestMenge?.toString() ?? 'N/A'}",
                        style: TextStyle(
                            fontSize: 16,
                            color: isWhite
                                ? Colors.grey.shade800
                                : Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    entry.ablaufdatum != null
                        ? "Ablaufdatum: ${DateFormat.yMd().format(entry.ablaufdatum!)}"
                        : "Ablaufdatum: N/A",
                    style: TextStyle(
                      fontSize: 14,
                      color: ablaufDatumColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
