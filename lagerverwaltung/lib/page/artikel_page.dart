import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/model/LagerlistenEntry.dart';
import 'package:lagerverwaltung/service/lagerlistenverwaltung_service.dart';
import 'package:lagerverwaltung/widget/custom_leading_button.dart';
import 'package:lagerverwaltung/widget/showsnackbar.dart';

class ArtikelPage extends StatefulWidget {
  final LagerListenEntry? entry;
  final bool isEditable;

  ArtikelPage({Key? key, required this.entry, this.isEditable = false})
      : super(key: key);

  @override
  _ArtikelPageState createState() => _ArtikelPageState();
}

class _ArtikelPageState extends State<ArtikelPage> {
  final lagerListenVerwaltungsService =
      GetIt.instance<LagerlistenVerwaltungsService>();
  late TextEditingController fachController;
  late TextEditingController regalController;
  late TextEditingController lagerplatzIdController;
  late TextEditingController artikelGWIDController;
  late TextEditingController arikelFirmenIdController;
  late TextEditingController beschreibungController;
  late TextEditingController kundeController;
  late TextEditingController mengeController;
  late TextEditingController mindestMengeController;
  late TextEditingController ablaufDatumController;
  late bool isEditable = widget.isEditable;

  @override
  void initState() {
    super.initState();
    fachController = TextEditingController(text: widget.entry?.fach ?? '');
    regalController = TextEditingController(text: widget.entry?.regal ?? '');
    lagerplatzIdController =
        TextEditingController(text: widget.entry?.lagerplatzId ?? '');
    artikelGWIDController =
        TextEditingController(text: widget.entry?.artikelGWID ?? '');
    arikelFirmenIdController =
        TextEditingController(text: widget.entry?.arikelFirmenId ?? '');
    beschreibungController =
        TextEditingController(text: widget.entry?.beschreibung ?? '');
    kundeController = TextEditingController(text: widget.entry?.kunde ?? '');
    mengeController =
        TextEditingController(text: widget.entry?.menge?.toString() ?? '');
    mindestMengeController = TextEditingController(
        text: widget.entry?.mindestMenge?.toString() ?? '');
    ablaufDatumController = TextEditingController(
  text: widget.entry?.ablaufdatum != null
      ? widget.entry!.ablaufdatum!.toIso8601String()
      : '',
);
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
            const SizedBox(height: 16),
            _buildReadOnlyField(label:  'Fach', controller: fachController),
            _buildReadOnlyField(label: 'Regal', controller: regalController),
            _buildReadOnlyField(label: 'Lagerplatz ID', controller: lagerplatzIdController),
            _buildReadOnlyField(label:'Artikel GWID', controller: artikelGWIDController),
            _buildReadOnlyField(label:'Artikel Firmen ID', controller: arikelFirmenIdController),
            _buildReadOnlyField(label:'Beschreibung', controller: beschreibungController),
            _buildReadOnlyField(label:'Kunde', controller: kundeController),
            const SizedBox(height: 16),
            _buildReadOnlyField(label: 'Ablaufdatum', controller: ablaufDatumController, inputType: TextInputType.datetime),
            const SizedBox(height: 16),
            _buildReadOnlyField(label: 'Menge', controller: mengeController, inputType: TextInputType.number),
            _buildReadOnlyField(label: 'Mindestmenge', controller: mindestMengeController, inputType: TextInputType.number),
            CupertinoButton(
              child: Text(isEditable ? 'Speichern' : 'Bearbeiten'),
              onPressed: () {
                setState(() {
                  if (isEditable) {
                    if (fachController.text.isEmpty ||
                        regalController.text.isEmpty ||
                        lagerplatzIdController.text.isEmpty ||
                        artikelGWIDController.text.isEmpty ||
                        arikelFirmenIdController.text.isEmpty ||
                        beschreibungController.text.isEmpty ||
                        kundeController.text.isEmpty ||
                        mengeController.text.isEmpty ||
                        mindestMengeController.text.isEmpty ||
                        ablaufDatumController.text.isEmpty) {
                      Showsnackbar.showSnackBar(context, "Felder sind leer!\nKorrigiere diese bitte");
                      return;
                    }

                    // Erstelle einen neuen LagerlistenEntry
                    final lagerlistenEntry = LagerListenEntry(
                      fach: fachController.text,
                      regal: regalController.text,
                      lagerplatzId: lagerplatzIdController.text,
                      artikelGWID: artikelGWIDController.text,
                      arikelFirmenId: arikelFirmenIdController.text,
                      beschreibung: beschreibungController.text,
                      kunde: kundeController.text,
                      menge: int.tryParse(mengeController.text),
                      mindestMenge: int.tryParse(mindestMengeController.text),
                      ablaufdatum: DateTime.tryParse(ablaufDatumController.text),
                    );
                    lagerListenVerwaltungsService
                        .addToLagerliste(lagerlistenEntry);
                  }
                  isEditable = !isEditable;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required TextEditingController controller,
      TextInputType inputType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: CupertinoTheme.of(context).barBackgroundColor,
          ),
        ),
        CupertinoTextField(
          controller: controller,
          placeholder: label,
          keyboardType: inputType,
          enabled: isEditable,
          style: TextStyle(
            color: isEditable
                ? CupertinoColors.label
                : CupertinoColors.inactiveGray,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
