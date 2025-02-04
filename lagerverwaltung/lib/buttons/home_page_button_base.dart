import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePageButtonBase extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const HomePageButtonBase({
    super.key,
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      child: CupertinoButton(
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        borderRadius: BorderRadius.circular(15),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                softWrap: true, // Zeilenumbruch erlauben
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
