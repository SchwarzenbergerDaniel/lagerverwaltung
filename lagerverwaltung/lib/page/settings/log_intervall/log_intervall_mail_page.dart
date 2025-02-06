import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';
import 'package:lagerverwaltung/widget/custom_leading_button.dart';
import 'package:lagerverwaltung/utils/showsnackbar.dart';

class LogConigPage extends StatelessWidget {
  LogConigPage({super.key});

  final localSettingsManagerService =
      GetIt.instance<LocalSettingsManagerService>();

  @override
  Widget build(BuildContext context) {
    final TextEditingController logIntervallController = TextEditingController(
        text: localSettingsManagerService.getIntervallLogMailDays().toString());

    final TextEditingController deleteAfterDaysController =
        TextEditingController(
            text: localSettingsManagerService
                .getDeleteLogsAfterDays()
                .toString());

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Log-Konfigurationen',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        leading: CustomBackButton(),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Maximales Intervall für die letzte Log-Mail (Tage):",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
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
              Align(
                alignment: Alignment.center,
                child: CupertinoButton.filled(
                  borderRadius: BorderRadius.circular(12),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  onPressed: () {
                    int? logIntervallDays =
                        int.tryParse(logIntervallController.text);
                    int? deleteDays =
                        int.tryParse(deleteAfterDaysController.text);

                    if (logIntervallDays != null) {
                      localSettingsManagerService
                          .setIntervallLogMailDays(logIntervallDays);
                    } else {
                      Showsnackbar.showSnackBar(context,
                          "Bitte eine gültige Zahl für das Intervall eingeben.");
                      return;
                    }

                    if (deleteDays != null) {
                      localSettingsManagerService
                          .setDeleteLogsAfterDays(deleteDays);
                    } else {
                      Showsnackbar.showSnackBar(context,
                          "Bitte eine gültige Zahl für das Löschen eingeben.");
                      return;
                    }

                    Navigator.pop(context);
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, size: 20),
                      SizedBox(width: 8),
                      Text("Speichern"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
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
