import 'package:flutter/cupertino.dart';

class NewLagerplatzCodeScannedModal {
  static Future<bool?> showActionSheet(
      BuildContext context, String lagerplatzID) async {
    return await showCupertinoModalPopup<bool>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text('Wähle eine Aktion für $lagerplatzID'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context, true); // True = Neuer Artikel
            },
            child: const Text('Lagerplatz mit Artikel befüllen'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, false); // False = Neuer Lagerplatz
            },
            child: const Text('Lagerplatz leer anlegen'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context, null); // Null = Exit
          },
          child: const Text('Zurück'),
        ),
      ),
    );
  }
}
