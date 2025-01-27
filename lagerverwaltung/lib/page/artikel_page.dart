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
  DateTime? ablaufDatum;
  late bool isEditable = widget.isEditable;

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

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
    ablaufDatum = widget.entry?.ablaufdatum ?? DateTime.now();
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
            _buildLabeledField('Fach', fachController),
            _buildLabeledField('Regal', regalController),
            _buildLabeledField('Lagerplatz ID', lagerplatzIdController),
            _buildLabeledField('Artikel GWID', artikelGWIDController),
            _buildLabeledField('Artikel Firmen ID', arikelFirmenIdController),
            _buildLabeledField('Beschreibung', beschreibungController),
            _buildLabeledField('Kunde', kundeController),
            _abgelaufenPicker(),
            _buildLabeledField('Menge', mengeController,
                inputType: TextInputType.number),
            _buildLabeledField('Mindestmenge', mindestMengeController,
                inputType: TextInputType.number),
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
                        ablaufDatum == null) {
                      Showsnackbar.showSnackBar(
                          context, "Felder sind leer!\nKorrigiere diese bitte");
                      return;
                    }

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
                      ablaufdatum: ablaufDatum,
                    );
                    //TODO
                    // Wenn das Produkt schon existiert, dann nicht ein neues erstellen, sondern updaten!!!!
                    //
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

  Widget _abgelaufenPicker() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Ablaufdatum',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: CupertinoColors.systemGrey5),),
      CupertinoButton(
        onPressed: () => _showDialog(
          CupertinoDatePicker(
            initialDateTime: ablaufDatum,
            mode: CupertinoDatePickerMode.date,
            use24hFormat: true,
            onDateTimeChanged: (DateTime newDate) {
              setState(() => ablaufDatum = newDate);
            },
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Text(
          '${ablaufDatum!.day}-${ablaufDatum!.month}-${ablaufDatum!.year}',
          style: TextStyle(fontSize: 16.0, color: isEditable ? CupertinoTheme.of(context).primaryColor : CupertinoTheme.of(context).primaryColor.withValues(alpha: 0.6))
        ),
      ),
      const SizedBox(height: 6)
    ]);
  }

  Widget _buildLabeledField(String label, TextEditingController controller,
      {TextInputType inputType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: CupertinoColors.systemGrey5),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: CupertinoColors.separator.resolveFrom(context)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CupertinoTextField(
            controller: controller,
            placeholder: label,
            keyboardType: inputType,
            enabled: isEditable,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            style: TextStyle(
              color: isEditable
                  ? CupertinoColors.label
                  : CupertinoColors.inactiveGray,
            ),
            decoration: null,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}