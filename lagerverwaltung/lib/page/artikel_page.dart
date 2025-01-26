import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lagerverwaltung/model/LagerlistenEntry.dart';
import 'package:lagerverwaltung/widget/custom_leading_button.dart';

class ArtikelPage extends StatefulWidget {
  final LagerListenEntry? entry;

  ArtikelPage({Key? key, required this.entry}) : super(key: key);

  @override
  _ArtikelPageState createState() => _ArtikelPageState();
}

class _ArtikelPageState extends State<ArtikelPage> {
  late TextEditingController fachController;
  late TextEditingController regalController;
  late TextEditingController lagerplatzIdController;
  late TextEditingController artikelGWIDController;
  late TextEditingController arikelFirmenIdController;
  late TextEditingController beschreibungController;
  late TextEditingController kundeController;
  late TextEditingController mengeController;
  late TextEditingController mindestMengeController;

  DateTime? ablaufdatum;

  @override
  void initState() {
    super.initState();
    fachController = TextEditingController(text: widget.entry?.fach ?? '');
    regalController = TextEditingController(text: widget.entry?.regal ?? '');
    lagerplatzIdController = TextEditingController(text: widget.entry?.lagerplatzId ?? '');
    artikelGWIDController = TextEditingController(text: widget.entry?.artikelGWID ?? '');
    arikelFirmenIdController = TextEditingController(text: widget.entry?.arikelFirmenId ?? '');
    beschreibungController = TextEditingController(text: widget.entry?.beschreibung ?? '');
    kundeController = TextEditingController(text: widget.entry?.kunde ?? '');
    mengeController = TextEditingController(text: widget.entry?.menge?.toString() ?? '');
    mindestMengeController = TextEditingController(text: widget.entry?.mindestMenge?.toString() ?? '');
    ablaufdatum = widget.entry?.ablaufdatum;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Artikel'),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        leading: CustomBackButton(),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            CupertinoTextField(
              controller: fachController,
              placeholder: 'Fach',
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: regalController,
              placeholder: 'Regal',
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: lagerplatzIdController,
              placeholder: 'Lagerplatz ID',
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: artikelGWIDController,
              placeholder: 'Artikel GWID',
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: arikelFirmenIdController,
              placeholder: 'Artikel Firmen ID',
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: beschreibungController,
              placeholder: 'Beschreibung',
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: kundeController,
              placeholder: 'Kunde',
            ),
            const SizedBox(height: 16),
            CupertinoButton(
              onPressed: () async {
                DateTime? pickedDate = await showCupertinoModalPopup<DateTime>(
                  context: context,
                  builder: (context) => Container(
                    height: 250,
                    color: CupertinoColors.systemBackground,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: ablaufdatum ?? DateTime.now(),
                      onDateTimeChanged: (DateTime date) {
                        setState(() {
                          ablaufdatum = date;
                        });
                      },
                    ),
                  ),
                );

                if (pickedDate != null) {
                  setState(() {
                    ablaufdatum = pickedDate;
                  });
                }
              },
              child: Text(ablaufdatum != null
                  ? 'Ablaufdatum: ${ablaufdatum!.toLocal().toIso8601String().split('T')[0]}'
                  : 'Ablaufdatum auswählen'),
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: mengeController,
              placeholder: 'Menge',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: mindestMengeController,
              placeholder: 'Mindestmenge',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            CupertinoButton.filled(
              onPressed: () {
                
              },
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }
}