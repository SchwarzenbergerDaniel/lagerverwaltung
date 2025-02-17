import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FertigButton extends StatelessWidget {
  VoidCallback onPressed;

  FertigButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor.computeLuminance() > 0.5
        ? CupertinoColors.black
        : CupertinoColors.white;
    return Align(
      alignment: Alignment.center,
      child: CupertinoButton.filled(
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        onPressed: () {
          onPressed.call();
          Navigator.pop(context);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 20, color: color),
            SizedBox(width: 8),
            Text(
              "Speichern",
              style: TextStyle(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
