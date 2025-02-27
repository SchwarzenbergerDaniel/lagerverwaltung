import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lagerverwaltung/service/theme_changing_service.dart';
import 'package:provider/provider.dart';

class BaseButton extends StatelessWidget {
  final String title;
  final Color accentColor;
  final VoidCallback onPressed;
  final bool isPrimary;

  const BaseButton({
    super.key,
    required this.title,
    required this.accentColor,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeChangingService>(context);
    bool isBunt = themeService.istBunt;
    Color effectiveColor = isBunt ? accentColor : themeService.primaryColor;

    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: isPrimary ? 10 : 8,
                sigmaY: isPrimary ? 10 : 8,
              ),
              child: Container(
                height: isPrimary ? 75 : 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      effectiveColor.withOpacity(0.5),
                      effectiveColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  color: isPrimary
                      ? Colors.white.withOpacity(0.1)
                      : effectiveColor.withOpacity(0.1),
                  border: Border.all(
                    color: effectiveColor.withOpacity(isPrimary ? 0.5 : 0.8),
                    width: isPrimary ? 1.5 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: isPrimary ? 8 : 6,
                      offset: Offset(0, isPrimary ? 4 : 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isPrimary ? 18 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
