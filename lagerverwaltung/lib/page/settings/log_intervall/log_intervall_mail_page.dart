import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';
import 'package:lagerverwaltung/utils/heading_text.dart';
import 'package:lagerverwaltung/widget/background/animated_background.dart';
import 'package:lagerverwaltung/widget/custom_leading_button.dart';
import 'package:lagerverwaltung/utils/showsnackbar.dart';
import 'package:lagerverwaltung/widget/fertig_button.dart';

class LogConigPage extends StatelessWidget {
  LogConigPage({super.key});

  final localSettingsManagerService =
      GetIt.instance<LocalSettingsManagerService>();

  late TextEditingController logIntervallController;
  late TextEditingController deleteAfterDaysController;
  @override
  Widget build(BuildContext context) {
    logIntervallController = TextEditingController(
        text: localSettingsManagerService.getIntervallLogMailDays().toString());

    deleteAfterDaysController = TextEditingController(
        text: localSettingsManagerService.getDeleteLogsAfterDays().toString());

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Log-Konfigurationen',
          style: CupertinoTheme.of(context).textTheme.textStyle,
        ),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        leading: CustomBackButton(),
      ),
      child: AnimatedBackground(
        child: Center(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  HeadingText(text: "Log-Konfigurationen"),
                  const SizedBox(height: 25),
                  const Text(
                    "Maximales Intervall für die letzte Log-Mail (Tage):",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(logIntervallController),
                  const SizedBox(height: 20),
                  const Text(
                    "Einträge nach Tagen löschen:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(deleteAfterDaysController),
                  const SizedBox(height: 25),
                  FertigButton(
                    onPressed: () => _onFertigPressed(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onFertigPressed(BuildContext context) {
    int? logIntervallDays = int.tryParse(logIntervallController.text);
    int? deleteDays = int.tryParse(deleteAfterDaysController.text);

    if (logIntervallDays != null) {
      localSettingsManagerService.setIntervallLogMailDays(logIntervallDays);
    } else {
      Showsnackbar.showSnackBar(
          context, "Bitte eine gültige Zahl für das Intervall eingeben.");
      return;
    }

    if (deleteDays != null) {
      localSettingsManagerService.setDeleteLogsAfterDays(deleteDays);
    } else {
      Showsnackbar.showSnackBar(
          context, "Bitte eine gültige Zahl für das Löschen eingeben.");
      return;
    }
  }

  Widget _buildTextField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.white,
          width: 1.0,
        ),
      ),
      child: CupertinoTextField(
        controller: controller,
        keyboardType: TextInputType.number,
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
