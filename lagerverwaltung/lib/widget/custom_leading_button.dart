import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lagerverwaltung/config/constants.dart';

//Weil die automatischen Cupertino Icons nicht funktionieren
class CustomBackButton extends StatefulWidget {
  final VoidCallback? onPressed;

  const CustomBackButton({super.key, this.onPressed});

  @override
  _CustomBackButtonState createState() => _CustomBackButtonState();
}

class _CustomBackButtonState extends State<CustomBackButton> {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      color: CupertinoColors.transparent,
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(20),
      onPressed: widget.onPressed ??
          () {
            Navigator.of(context).pop(Constants.EXIT_RETURN_VALUE);
          },
      child: Icon(
        Icons.arrow_back,
        color: CupertinoTheme.of(context).primaryColor,
      ),
    );
  }
}
