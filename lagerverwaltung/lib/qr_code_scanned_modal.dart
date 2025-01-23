import 'package:flutter/cupertino.dart';

class QrCodeScannedModal{
  static void showActionSheet(BuildContext context, String result) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text('Wähle aus für $result'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Zeige Informationen'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Neuer Lagerplatz'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
}
}