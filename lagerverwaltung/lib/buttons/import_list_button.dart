import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/buttons/base/secondary_button_base.dart';
import 'package:lagerverwaltung/service/lagerlistenverwaltung_service.dart';
import 'package:lagerverwaltung/utils/showsnackbar.dart';

class ImportListButton extends StatelessWidget {
  ImportListButton({super.key});
  final lagerListenVerwaltungsService =
      GetIt.instance<LagerlistenVerwaltungsService>();

  @override
  Widget build(BuildContext context) {
    return SecondaryButtonBase(
        title: "Importieren",
        accentColor: Color.fromRGBO(231, 218, 112, 1),
        onPressed: () => import(context));
  }

  void import(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      String importMessage =
          lagerListenVerwaltungsService.importFromFile(filePath);
      Showsnackbar.showSnackBar(context, importMessage);
    } else {
      Showsnackbar.showSnackBar(context, "Es wurde keine File ausgewählt.");
    }
  }
}
