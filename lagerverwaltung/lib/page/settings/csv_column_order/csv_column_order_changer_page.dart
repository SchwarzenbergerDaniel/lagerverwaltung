import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';
import 'package:lagerverwaltung/widget/custom_leading_button.dart';

enum Columns {
  lagerplatzId,
  fach,
  regal,
  artikelGWID,
  arikelFirmenId,
  beschreibung,
  kunde,
  ablaufdatum,
  menge,
  mindestMenge
}

class CsvColumnOrderChangerPage extends StatefulWidget {
  CsvColumnOrderChangerPage({super.key});

  @override
  _CsvColumnOrderChangerPageState createState() =>
      _CsvColumnOrderChangerPageState();
}

class _CsvColumnOrderChangerPageState extends State<CsvColumnOrderChangerPage> {
  final localSettingsManagerService =
      GetIt.instance<LocalSettingsManagerService>();

  @override
  void initState() {
    super.initState();
    order = List<Columns>.from(localSettingsManagerService.getCsvOrder());
  }

  List<Columns> order = [];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          middle: const Text('Export Spalten Reihenfolge ändern'),
          backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
          leading: CustomBackButton()),
      child: SafeArea(
        child: ReorderableListView(
          padding: const EdgeInsets.all(16),
          children: order.map((column) {
            return Card(
              key: ValueKey(column),
              child: ListTile(
                title: Text(column.name),
                leading: Text(
                  (order.indexOf(column) + 1).toString(),
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              Columns item = order.removeAt(oldIndex);
              order.insert(newIndex, item);
              localSettingsManagerService.setCsvOrder(order);
            });
          },
        ),
      ),
    );
  }
}
