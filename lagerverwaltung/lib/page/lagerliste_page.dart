import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:lagerverwaltung/model/lagerlistenentry.dart';
import 'package:lagerverwaltung/page/edit_artikel_page.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';
import 'package:lagerverwaltung/widget/background/animated_background.dart';
import 'package:lagerverwaltung/widget/custom_app_bar.dart';

enum SortType {
  ablaufdatum,
  lagerplatz,
  alphabetisch,
  mindestmengeErreicht,
  regal
}

class LagerlistePage extends StatefulWidget {
  final List<LagerlistenEntry> lagerlistenEntries;

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
        final regal = entry.regal?.toLowerCase() ?? '';
        final fach = entry.fach?.toLowerCase() ?? '';
        return artikelGWID.contains(query) ||
            beschreibung.contains(query) ||
            regal.contains(query) ||
            fach.contains(query);
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
      switch (_currentSort) {
        case SortType.ablaufdatum:
          _filteredEntries.sort((a, b) => _compareByAblaufdatum(a, b));
          break;
        case SortType.lagerplatz:
          _filteredEntries.sort((a, b) => _compareByLagerplatz(a, b));
          break;
        case SortType.alphabetisch:
          _filteredEntries.sort((a, b) => _compareAlphabetically(a, b));
          break;
        case SortType.mindestmengeErreicht:
          _filteredEntries.sort((a, b) => _compareByMindestmengeErreicht(a, b));
          break;
        case SortType.regal:
          _filteredEntries.sort((a, b) {
            int regalComparison = (a.regal ?? '').compareTo(b.regal ?? '');
            if (regalComparison != 0) return regalComparison;
            return (a.fach ?? '').compareTo(b.fach ?? '');
          });
          break;
      }
    });
  }

  void _onEntryTap(LagerlistenEntry entry) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => EditArtikelPage(entry: entry),
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
      case SortType.regal:
        return "Regal";
    }
  }

  /// This keeps your fach design: fach at the top, description below.
  Widget _buildGridItem(LagerlistenEntry entry) {
    bool isWhite = localSettingsManagerService.getIsBright();
    final bool isExpired =
        entry.ablaufdatum != null && DateTime.now().isAfter(entry.ablaufdatum!);
    final Color ablaufDatumColor = isExpired ? Colors.redAccent : Colors.green;
    final bool isBelowMinimum = (entry.menge != null &&
        entry.mindestMenge != null &&
        entry.menge! < entry.mindestMenge!);
    final Color mengeColor =
        isBelowMinimum ? Colors.redAccent : (Colors.grey.shade800);

    // Shorten description to 25 characters
    String shortDescription = entry.beschreibung ?? 'Keine Beschreibung';
    if (shortDescription.length > 25) {
      shortDescription = shortDescription.substring(0, 25) + '...';
    }

    return GestureDetector(
      onTap: () {
        _onEntryTap(entry);
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.fach ?? 'Kein Fach',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                shortDescription,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Menge: ${entry.menge?.toString() ?? 'N/A'}",
                    style: TextStyle(
                      fontSize: 14,
                      color: mengeColor,
                    ),
                  ),
                  Text(
                    "Min: ${entry.mindestMenge?.toString() ?? 'N/A'}",
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isWhite ? Colors.grey.shade800 : Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                entry.ablaufdatum != null
                    ? "Ablauf: ${DateFormat.yMd().format(entry.ablaufdatum!)}"
                    : "Ablauf: N/A",
                style: TextStyle(
                  fontSize: 14,
                  color: ablaufDatumColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticleList() {
    // Group entries by Regal.
    final Map<String, List<LagerlistenEntry>> groupedEntries = {};
    for (var entry in _filteredEntries) {
      final key = entry.regal ?? 'N/A';
      groupedEntries.putIfAbsent(key, () => []).add(entry);
    }
    final sortedKeys = groupedEntries.keys.toList()..sort();

    // Wrap the ListView in a Material widget with a transparent background.
    return Material(
      color: Colors.transparent,
      child: ListView(
        children: sortedKeys.map((regalKey) {
          final groupEntries = groupedEntries[regalKey]!;
          switch (_currentSort) {
            case SortType.ablaufdatum:
              groupEntries.sort((a, b) => _compareByAblaufdatum(a, b));
              break;
            case SortType.lagerplatz:
              groupEntries.sort((a, b) => _compareByLagerplatz(a, b));
              break;
            case SortType.alphabetisch:
              groupEntries.sort((a, b) => _compareAlphabetically(a, b));
              break;
            case SortType.mindestmengeErreicht:
              groupEntries.sort((a, b) => _compareByMindestmengeErreicht(a, b));
              break;
            case SortType.regal:
            default:
              // Sortierung innerhalb des Regals anhand des "fach"-Felds
              groupEntries
                  .sort((a, b) => (a.fach ?? '').compareTo(b.fach ?? ''));
              break;
          }
          return ExpansionTile(
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                regalKey,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white),
              ),
            ),
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: groupEntries
                      .map((entry) => _buildGridItem(entry))
                      .toList(),
                ),
              )
            ],
          );
        }).toList(),
      ),
    );
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
                    placeholder: 'Nach Regal, Fach oder Artikel suchen...'),
              ),
              // Sort Options
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
                              CupertinoActionSheetAction(
                                child: const Text("Regal"),
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _currentSort = SortType.regal;
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
              // Display the article list (or accordion view for regale)
              Expanded(
                child: _buildArticleList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
