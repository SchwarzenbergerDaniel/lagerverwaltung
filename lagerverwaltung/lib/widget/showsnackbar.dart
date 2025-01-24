import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Showsnackbar {
  static void showSnackBar(BuildContext context, String message) {
    showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: const Text('Meldung'),
      content: Text(
        message,
        style: const TextStyle(color: CupertinoColors.white),
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop(); // Dismiss the dialog
          },
        ),
      ],
    ),
  );
}
}