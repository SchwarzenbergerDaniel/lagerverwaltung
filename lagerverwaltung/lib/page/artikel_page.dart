import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lagerverwaltung/model/LagerlistenEntry.dart';
import 'package:lagerverwaltung/widget/custom_leading_button.dart';

class ArtikelPage extends StatefulWidget {
  final LagerListenEntry? entry;
  final bool isEditable;

  ArtikelPage({Key? key, required this.entry, this.isEditable = false}) : super(key: key);

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
            const SizedBox(height: 16),
            _buildReadOnlyField('Fach', fachController),
            _buildReadOnlyField('Regal', regalController),
            _buildReadOnlyField('Lagerplatz ID', lagerplatzIdController),
            _buildReadOnlyField('Artikel GWID', artikelGWIDController),
            _buildReadOnlyField('Artikel Firmen ID', arikelFirmenIdController),
            _buildReadOnlyField('Beschreibung', beschreibungController),
            _buildReadOnlyField('Kunde', kundeController),
            const SizedBox(height: 16),
            Text(
              'Ablaufdatum',
              style: TextStyle(
                fontSize: 12,
                color: CupertinoTheme.of(context).barBackgroundColor,
              ),
            ),
            Text(
              ablaufdatum != null
                  ? 'Ablaufdatum: ${ablaufdatum!.toLocal().toIso8601String().split('T')[0]}'
                  : 'Kein Ablaufdatum festgelegt',
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.inactiveGray,
              ),
            ),
            const SizedBox(height: 16),
            _buildReadOnlyField('Menge', mengeController),
            _buildReadOnlyField('Mindestmenge', mindestMengeController),
            CupertinoButton(
              child: Text(isEditable ? 'Speichern' : 'Bearbeiten'),
              onPressed: () {
                setState(() {
                  if(isEditable){
                    //TO DO AUFRUF DER METHODE ZUM ABSPEICHERN UND ERSETZEN/EINFÜGEN IN LOCALSTORAGE
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

  Widget _buildReadOnlyField(String label, TextEditingController controller) {
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