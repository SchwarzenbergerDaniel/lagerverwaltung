import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/provider/colormodeprovider.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';
import 'package:provider/provider.dart';

class HomePageButtonBase extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onPressed;

  final localSettingsManagerService =
      GetIt.instance<LocalSettingsManagerService>();

  HomePageButtonBase({
    super.key,
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isBunt = Provider.of<ColorModeProvider>(context).isBunt;

    return Container(
      height: 90,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      child: CupertinoButton(
        color: isBunt ? backgroundColor : Theme.of(context).primaryColor,
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
                softWrap: true,
                style: const TextStyle(
                  fontSize: 14,
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
