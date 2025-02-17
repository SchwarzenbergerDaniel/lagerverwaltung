import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';
import 'package:lagerverwaltung/utils/heading_text.dart';
import 'package:lagerverwaltung/widget/background/animated_background.dart';
import 'package:lagerverwaltung/widget/custom_app_bar.dart';

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

class XlsxColumnOrderChangerPage extends StatefulWidget {
  const XlsxColumnOrderChangerPage({super.key});

  @override
  _XlsxColumnOrderChangerPageState createState() =>
      _XlsxColumnOrderChangerPageState();
}

class _XlsxColumnOrderChangerPageState
    extends State<XlsxColumnOrderChangerPage> {
  final localSettingsManagerService =
      GetIt.instance<LocalSettingsManagerService>();

  @override
  void initState() {
    super.initState();
    order = List<Columns>.from(localSettingsManagerService.getXlsxOrder());
  }

  List<Columns> order = [];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomAppBar(title: ""),
      child: SafeArea(
        child: AnimatedBackground(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: HeadingText(
                  text: 'Reihenfolge ändern',
                  addSizedBox: false,
                ),
              ),
              // Expanded widget to give the list proper constraints
              Expanded(
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
                      localSettingsManagerService.setXlsxOrder(order);
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
