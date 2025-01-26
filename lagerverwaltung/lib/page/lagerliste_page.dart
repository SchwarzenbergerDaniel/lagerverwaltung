import 'package:flutter/cupertino.dart';
import 'package:lagerverwaltung/model/LagerlistenEntry.dart';
import 'package:lagerverwaltung/widget/custom_leading_button.dart';
import 'package:lagerverwaltung/page/artikel_page.dart';

class LagerlistePage extends StatefulWidget {
  final List<LagerListenEntry> entries;

  const LagerlistePage({Key? key, required this.entries}) : super(key: key);

  @override
  _LagerlistePageState createState() => _LagerlistePageState();
}

class _LagerlistePageState extends State<LagerlistePage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Lagerliste'),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        leading: CustomBackButton(),
      ),
      child: SafeArea(
        child: Column(
          children: [
            CupertinoButton.filled(
              onPressed: () async {
                /*
                final result = await QrCodeScannedModal.showActionSheet(context, 'Neuer Artikel');
                if (result == true) {
                  final newEntry = LagerListenEntry();
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => ArtikelPage(entry: newEntry),
                    ),
                  ).then((savedEntry) {
                    if (savedEntry != null && savedEntry is LagerListenEntry) {
                      setState(() {
                        widget.entries.add(savedEntry);
                      });
                    }
                  });
                } */
              },
              child: const Text('Neuen Artikel hinzufügen'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.entries.length,
                itemBuilder: (context, index) {
                  final entry = widget.entries[index];
                  return CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => ArtikelPage(entry: entry),
                        ),
                      ).then((updatedEntry) {
                        if (updatedEntry != null && updatedEntry is LagerListenEntry) {
                          setState(() {
                            widget.entries[index] = updatedEntry;
                          });
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                            entry.beschreibung ?? 'Unbenannt',
                            style: const TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.black,
                            ),
                          ),
                          const Icon(
                            CupertinoIcons.right_chevron,
                            color: CupertinoColors.systemGrey,
                          ),
                        ],
                      ),
                    ),
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