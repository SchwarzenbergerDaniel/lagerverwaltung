import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';
import 'package:lagerverwaltung/widget/custom_leading_button.dart';
import 'package:lagerverwaltung/utils/showsnackbar.dart';

class EMailEmpfaengerAendernPage extends StatelessWidget {
  EMailEmpfaengerAendernPage({super.key});

  final localSettingsManagerService =
      GetIt.instance<LocalSettingsManagerService>();

  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController(
      text: localSettingsManagerService.getMail(),
    );

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Gradwohl Logo ändern',
          style: CupertinoTheme.of(context).textTheme.textStyle,
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
                "Neue E-Mail-Adresse:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CupertinoTextField(
                  controller: textController,
                  keyboardType: TextInputType.emailAddress,
                  placeholder: "E-Mail eingeben...",
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: CupertinoButton.filled(
                  borderRadius: BorderRadius.circular(12),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  onPressed: () {
                    String email = textController.text.trim();
                    if (_isValidEmail(email)) {
                      localSettingsManagerService.setMail(email);
                      Navigator.pop(context);
                    } else {
                      Showsnackbar.showSnackBar(context,
                          "Bitte eine gültige E-Mail-Adresse eingeben.");
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Speichern",
                        style: CupertinoTheme.of(context).textTheme.textStyle,
                      ),
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
}
