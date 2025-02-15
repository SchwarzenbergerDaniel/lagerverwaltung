import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/model/lagerlistenentry.dart';
import 'package:lagerverwaltung/service/lagerlistenverwaltung_service.dart';
import 'package:lagerverwaltung/utils/showdialog.dart';
import 'package:lagerverwaltung/utils/showsnackbar.dart';

class EditArtikelPage extends StatefulWidget {
  final LagerlistenEntry? entry;
  final bool isEditable;

  const EditArtikelPage(
      {super.key, required this.entry, this.isEditable = false});
  @override
  _EditArtikelPageState createState() => _EditArtikelPageState();
}

class _EditArtikelPageState extends State<EditArtikelPage> {
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

  // Store initial values for change detection
  late final String initialFach;
  late final String initialRegal;
  late final String initialLagerplatzId;
  late final String initialArtikelGWID;
  late final String initialArikelFirmenId;
  late final String initialBeschreibung;
  late final String initialKunde;
  late final String initialMenge;
  late final String initialMindestMenge;
  late final DateTime initialAblaufDatum;

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

    // Initialize initial values for change detection
    initialFach = widget.entry?.fach ?? '';
    initialRegal = widget.entry?.regal ?? '';
    initialLagerplatzId = widget.entry?.lagerplatzId ?? '';
    initialArtikelGWID = widget.entry?.artikelGWID ?? '';
    initialArikelFirmenId = widget.entry?.arikelFirmenId ?? '';
    initialBeschreibung = widget.entry?.beschreibung ?? '';
    initialKunde = widget.entry?.kunde ?? '';
    initialMenge = widget.entry?.menge?.toString() ?? '';
    initialMindestMenge = widget.entry?.mindestMenge?.toString() ?? '';
    initialAblaufDatum = widget.entry?.ablaufdatum ?? ablaufDatum!;
  }

  /// Checks if any field value has been changed.
  bool _hasChanges() {
    return fachController.text != initialFach ||
        regalController.text != initialRegal ||
        lagerplatzIdController.text != initialLagerplatzId ||
        artikelGWIDController.text != initialArtikelGWID ||
        arikelFirmenIdController.text != initialArikelFirmenId ||
        beschreibungController.text != initialBeschreibung ||
        kundeController.text != initialKunde ||
        mengeController.text != initialMenge ||
        mindestMengeController.text != initialMindestMenge ||
        (ablaufDatum != initialAblaufDatum);
  }

  /// Saves the changes if the required fields are filled.
  /// Returns true if saving was successful.
  Future<bool> _saveChanges() async {
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
      return false;
    }

    final lagerlistenEntry = LagerlistenEntry(
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

    await lagerListenVerwaltungsService.updateArtikel(
        lagerlistenEntry.artikelGWID!,
        lagerlistenEntry.lagerplatzId!,
        lagerlistenEntry);
    return true;
  }

  /// This method is called when the back button is pressed.
  /// If any changes are detected, a dialog asks if the user wants to save them.
  Future<void> _onBackPressed() async {
    if (_hasChanges()) {
      bool shouldSave = await ShowDialogTwoOptions.isFirstOptionClicked(
          context,
          "Änderungen speichern?",
          "Möchten Sie Ihre Änderungen speichern?",
          "Speichern",
          "Nicht speichern");
      if (shouldSave) {
        if (isEditable) {
          bool saved = await _saveChanges();
          if (!saved) {
            // If saving fails (e.g. due to validation), do not pop the page.
            return;
          }
        }
      }
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Artikel',
          style: CupertinoTheme.of(context).textTheme.textStyle,
        ),
        // Replace the previous CustomBackButton with one that calls _onBackPressed.
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(Icons.arrow_back),
          onPressed: _onBackPressed,
        ),
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
            speichernBearbeitenButton(),
            deleteButton()
          ],
        ),
      ),
    );
  }

  Widget _abgelaufenPicker() {
    final textColor = isEditable
        ? CupertinoTheme.of(context).primaryColor
        : CupertinoColors.inactiveGray;
    final labelTextColor = isEditable
        ? CupertinoTheme.of(context).textTheme.textStyle.color
        : CupertinoColors.inactiveGray;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ablaufdatum',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: labelTextColor,
          ),
        ),
        CupertinoButton(
          onPressed: isEditable
              ? () => _showDialog(
                    CupertinoDatePicker(
                      initialDateTime: ablaufDatum,
                      mode: CupertinoDatePickerMode.date,
                      use24hFormat: true,
                      onDateTimeChanged: (DateTime newDate) {
                        setState(() => ablaufDatum = newDate);
                      },
                    ),
                  )
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            '${ablaufDatum!.day}-${ablaufDatum!.month}-${ablaufDatum!.year}',
            style: TextStyle(fontSize: 16.0, color: textColor),
          ),
        ),
        const SizedBox(height: 6)
      ],
    );
  }

  Widget _buildLabeledField(String label, TextEditingController controller,
      {TextInputType inputType = TextInputType.text}) {
    // Use a different background and text color when not in edit mode.
    final backgroundColor = isEditable
        ? CupertinoTheme.of(context).scaffoldBackgroundColor
        : CupertinoColors.systemGrey6;
    final textColor = isEditable
        ? CupertinoTheme.of(context).textTheme.textStyle.color
        : CupertinoColors.inactiveGray;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: CupertinoColors.separator.resolveFrom(context)),
            borderRadius: BorderRadius.circular(8),
            color: backgroundColor,
          ),
          child: CupertinoTextField(
            controller: controller,
            placeholder: label,
            keyboardType: inputType,
            enabled: isEditable,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            style: TextStyle(color: textColor),
            decoration: BoxDecoration(color: backgroundColor),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  CupertinoButton speichernBearbeitenButton() {
    return CupertinoButton(
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

            final lagerlistenEntry = LagerlistenEntry(
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

            lagerListenVerwaltungsService.updateArtikel(
                lagerlistenEntry.artikelGWID!,
                lagerlistenEntry.lagerplatzId!,
                lagerlistenEntry);
          }
          isEditable = !isEditable;
        });
      },
    );
  }

  CupertinoButton deleteButton() {
    return CupertinoButton(
      child: Text("Delete",
          style: TextStyle(color: CupertinoColors.destructiveRed)),
      onPressed: () async {
        bool confirmDelete = await ShowDialogTwoOptions.isFirstOptionClicked(
            context,
            "Löschen bestätigen",
            "Möchten Sie diesen Artikel wirklich löschen?",
            "Löschen",
            "Abbrechen");

        if (confirmDelete) {
          try {
            await lagerListenVerwaltungsService.deleteArtikel(
              widget.entry!.artikelGWID!,
              widget.entry!.lagerplatzId!,
            );
            Navigator.pop(context);
          } catch (e) {
            // Handle deletion error if necessary.
          }
        }
      },
    );
  }
}
