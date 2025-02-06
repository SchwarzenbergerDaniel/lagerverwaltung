import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogNumberInput {
  static Future<int?> getNumber(
      BuildContext context, String title, String hintText) async {
    TextEditingController amountController = TextEditingController();
    return await showCupertinoDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: hintText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text("Abbrechen"),
            ),
            TextButton(
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
