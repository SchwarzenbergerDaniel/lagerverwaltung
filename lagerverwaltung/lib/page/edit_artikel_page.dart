import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/config/constants.dart';
import 'package:lagerverwaltung/model/lagerlistenentry.dart';
import 'package:lagerverwaltung/service/codescanner_service.dart';
import 'package:lagerverwaltung/service/lagerlistenverwaltung_service.dart';
import 'package:lagerverwaltung/utils/showdialog.dart';
import 'package:lagerverwaltung/utils/showsnackbar.dart';
import 'package:lagerverwaltung/widget/background/animated_background.dart';
import 'package:lagerverwaltung/widget/custom_app_bar.dart';

class EditArtikelPage extends StatefulWidget {
  final LagerlistenEntry? entry;

  const EditArtikelPage({super.key, required this.entry});
  @override
  _EditArtikelPageState createState() => _EditArtikelPageState();
}

class _EditArtikelPageState extends State<EditArtikelPage> {
  final lagerListenVerwaltungsService =
      GetIt.instance<LagerlistenVerwaltungsService>();
  final codeScannerService = GetIt.instance<CodeScannerService>();

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

  Future<void> _onBackPressed() async {
    if (_hasChanges()) {
      bool shouldSave = await ShowDialogTwoOptions.isFirstOptionClicked(
          context,
          "Änderungen speichern?",
          "Möchten Sie Ihre Änderungen speichern?",
          "Speichern",
          "Nicht speichern");
      if (shouldSave) {
        bool saved = await _saveChanges();
        if (!saved) {
          return;
        }
      }
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomAppBar(
        title: 'Artikel',
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _onBackPressed,
          child: const Icon(Icons.arrow_back),
        ),
      ),
      child: AnimatedBackground(
        isAnimated: false,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 16),
              _buildLabeledField('Fach', fachController),
              _buildLabeledField('Regal', regalController),
              _buildLabeledField('Lagerplatz ID', lagerplatzIdController,
                  isQRCodeField: true, isLagerplatzIdField: true),
              _buildLabeledField('Artikel GWID', artikelGWIDController,
                  isQRCodeField: true),
              _buildLabeledField('Artikel Firmen ID', arikelFirmenIdController),
              _buildLabeledField('Beschreibung', beschreibungController),
              _buildLabeledField('Kunde', kundeController),
              _abgelaufenPicker(),
              _buildLabeledField('Menge', mengeController,
                  inputType: TextInputType.number),
              _buildLabeledField('Mindestmenge', mindestMengeController,
                  inputType: TextInputType.number),
              speichernButton(),
              deleteButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget _abgelaufenPicker() {
    final textColor = CupertinoTheme.of(context).primaryColor;
    final labelTextColor = CupertinoTheme.of(context).textTheme.textStyle.color;

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
            style: TextStyle(fontSize: 16.0, color: textColor),
          ),
        ),
        const SizedBox(height: 6)
      ],
    );
  }

  Widget _buildLabeledField(String label, TextEditingController controller,
      {TextInputType inputType = TextInputType.text,
      bool isQRCodeField = false,
      bool isLagerplatzIdField = false}) {
    // Use a different background and text color when not in edit mode.
    final backgroundColor = CupertinoTheme.of(context).barBackgroundColor;
    final textColor = CupertinoTheme.of(context).textTheme.textStyle.color;

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
          child: Row(
            children: [
              // Expanded CupertinoTextField so it takes available space
              Expanded(
                child: CupertinoTextField(
                  controller: controller,
                  placeholder: label,
                  keyboardType: inputType,
                  enabled: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  style: TextStyle(color: textColor),
                  decoration: BoxDecoration(color: backgroundColor),
                ),
              ),
              if (isQRCodeField)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(Icons.qr_code, color: CupertinoColors.activeBlue),
                  onPressed: () async {
                    final id =
                        await codeScannerService.getCodeByScan(context, "Scan");
                    if (id == null || id == Constants.EXIT_RETURN_VALUE) {
                      return;
                    }
                    if (isLagerplatzIdField &&
                        !await lagerListenVerwaltungsService
                            .lagerplatzExist(id)) {
                      // check if lagerplatz exists
                      Showsnackbar.showSnackBar(context,
                          "Lagerplatz mit der Id $id existiert nicht, lege ihn zuerst an!");
                      return;
                    }
                    // Setze text
                    controller.text = id;
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  CupertinoButton speichernButton() {
    return CupertinoButton(
      child: Text('Speichern'),
      onPressed: () async {
        bool isOkay = await _saveChanges();
        if (isOkay) {
          Navigator.pop(context);
        }
      },
    );
  }

  CupertinoButton deleteButton() {
    return CupertinoButton(
      child: Text("Delete",
          style: TextStyle(color: CupertinoColors.destructiveRed)),
      onPressed: () async {
        bool isCancel = await ShowDialogTwoOptions.isFirstOptionClicked(
            context,
            "Löschen bestätigen",
            "Möchten Sie diesen Artikel wirklich löschen?",
            "Abbrechen",
            "Löschen");

        if (!isCancel) {
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
