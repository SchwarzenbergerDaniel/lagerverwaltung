import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogNumberInput {
  static Future<int?> getNumber(
      BuildContext context, String title, String hintText) async {
    TextEditingController amountController = TextEditingController();
    return await showCupertinoDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16),
              CupertinoTextField(
                controller: amountController,
                keyboardType: TextInputType.number,
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
                int? amount = int.tryParse(amountController.text);
                Navigator.of(context).pop(amount);
              },
              child: Text("Bestätigen"),
            ),
          ],
        );
      },
    );
  }
}
