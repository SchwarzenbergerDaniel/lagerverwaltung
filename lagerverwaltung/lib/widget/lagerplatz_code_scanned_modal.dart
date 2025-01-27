import 'package:flutter/cupertino.dart';

class LagerplatzCodeScannedModal {
  static Future<bool?> showActionSheet(BuildContext context, String result) async {
    return await showCupertinoModalPopup<bool>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text('Wähle eine Aktion für $result'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context, true); // True = Neuer Artikel
            },
            child: const Text('Neuer Artikel'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, false); // False = Neuer Lagerplatz
            },
            child: const Text('Neuer Lagerplatz'),
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