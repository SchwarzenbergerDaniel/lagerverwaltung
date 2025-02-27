import 'dart:ui';

import 'package:flutter/material.dart';

class PrimaryButtonBase extends StatelessWidget {
  final String title;
  final Color
      accentColor; // Akzentfarbe für Verlauf & Rahmen  final VoidCallback onPressed;
  final VoidCallback onPressed;
  const PrimaryButtonBase({
    super.key,
    required this.title,
    required this.accentColor,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: Stack(
          children: [
            // Gläserner Hintergrund mit Blur-Effekt
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 75,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withOpacity(0.5),
                      accentColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(
                    color: accentColor.withOpacity(0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
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
