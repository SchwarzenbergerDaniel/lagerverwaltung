import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FertigButton extends StatelessWidget {
  VoidCallback? onPressed;

  FertigButton({super.key, onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: CupertinoButton.filled(
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        onPressed: () {
          if (onPressed != null) {
            onPressed!.call();
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
    );
  }
}
