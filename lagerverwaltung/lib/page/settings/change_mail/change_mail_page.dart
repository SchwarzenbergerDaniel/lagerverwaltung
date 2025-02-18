import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';
import 'package:lagerverwaltung/utils/heading_text.dart';
import 'package:lagerverwaltung/widget/background/animated_background.dart';
import 'package:lagerverwaltung/widget/custom_app_bar.dart';
import 'package:lagerverwaltung/utils/showsnackbar.dart';
import 'package:lagerverwaltung/widget/fertig_button.dart';

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
      navigationBar: CustomAppBar(title: "Empfänger verwalten"),
      child: AnimatedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                HeadingText(text: "Empfänger-EMail"),
                CupertinoTextField(
                  controller: textController,
                  keyboardType: TextInputType.emailAddress,
                  placeholder: "E-Mail eingeben...",
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CupertinoColors.white,
                      width: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FertigButton(
                    onPressed: () => _onFertigPressed(textController, context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onFertigPressed(
      TextEditingController textController, BuildContext context) {
    String email = textController.text.trim();
    if (_isValidEmail(email)) {
      localSettingsManagerService.setMail(email);
      Navigator.pop(context);
    } else {
      Showsnackbar.showSnackBar(
          context, "Bitte eine gültige E-Mail-Adresse eingeben.");
    }
  }
}
