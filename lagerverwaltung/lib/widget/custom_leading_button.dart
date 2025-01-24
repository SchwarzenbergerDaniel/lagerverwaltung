import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//Weil die automatischen Cupertino Icons nicht funktionieren
class CustomBackButton extends StatefulWidget{
  final VoidCallback? onPressed;

  const CustomBackButton({Key? key, this.onPressed}) : super(key: key);

  @override
  _CustomBackButtonState createState() => _CustomBackButtonState();
}

class _CustomBackButtonState extends State<CustomBackButton> {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      color: CupertinoTheme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(20),
      onPressed: widget.onPressed ??
          () {
            Navigator.of(context).pop("-exit");
          },
      child: Icon(
        Icons.arrow_back,
        color: CupertinoTheme.of(context).primaryColor,
      ),
    );
  }
}