import 'package:flutter/cupertino.dart';
import 'package:lagerverwaltung/page/artikel_page.dart';
import '../model/lagerlistenentry.dart';

class QrCodeScannedModal{
  static void showActionSheet(BuildContext context, String result) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text('Wähle eine Aktion für $result'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              //MUSS NOCH LAGERPLATZ SCANNEN
               /* Navigator.push(context,
                  CupertinoPageRoute(builder: (context) => ArtikelPage())); */
            },
            child: const Text('Neuer Artikel'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              //
              //
              //
            },
            child: const Text('Neuer Lagerplatz'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Zurück'),
          ),
        ],
      ),
    );
}
}