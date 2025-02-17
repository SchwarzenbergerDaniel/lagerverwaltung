import 'package:flutter/cupertino.dart';

class DialogStringInput {
  static Future<String?> getString(BuildContext context, String title,
      String hintText, String? defaultText) async {
    final TextEditingController textController =
        TextEditingController(text: defaultText ?? "");

    return await showCupertinoDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16),
              CupertinoTextField(
                controller: textController,
                keyboardType: TextInputType.text,
                placeholder: hintText,
                padding: const EdgeInsets.all(12),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text("Abbrechen"),
            ),
            CupertinoDialogAction(
              onPressed: () {
                String inputText = textController.text.trim();
                Navigator.of(context)
                    .pop(inputText.isNotEmpty ? inputText : null);
              },
              child: Text("Bestätigen"),
            ),
          ],
        );
      },
    );
  }
}
