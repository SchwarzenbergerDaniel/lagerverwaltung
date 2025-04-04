import 'package:flutter/cupertino.dart';
import 'package:lagerverwaltung/provider/backgroundinfoprovider.dart';
import 'dart:math';

import 'package:lagerverwaltung/service/theme_changing_service.dart';
import 'package:provider/provider.dart';

class AnimatedBackground extends StatefulWidget {
  Widget child;
  bool? isAnimated;
  AnimatedBackground({super.key, required this.child, this.isAnimated});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeChangingService = Provider.of<ThemeChangingService>(context);
    final movingBlobs = Provider.of<BackgroundInfoProvider>(context);

    final startColor = themeChangingService.backgroundColor
        .withOpacity(movingBlobs.isBright ? 0.6 : 0.2);
    final hslStart = HSLColor.fromColor(startColor);
    final nextColor =
        hslStart.withLightness(movingBlobs.isBright ? 0.6 : 0.2).toColor();

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                startColor,
                nextColor,
              ],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              children: movingBlobs.isMoving && widget.isAnimated != false
                  ? [
                      _buildMovingCircle(
                          80, 130, 40, 0.15, _animation.value * 30),
                      _buildMovingBlob(80, 300, 0.1, _animation.value),
                      _buildMovingCircle(
                          70, 400, 30, 0.12, _animation.value * 20),
                      _buildMovingBlob(500, 250, 0.08, _animation.value),
                    ]
                  : [],
            );
          },
        ),
        widget.child,
      ],
    );
  }

  Widget _buildMovingCircle(
      double size, double top, double left, double opacity, double movement) {
    return Positioned(
      top: top + movement,
      left: left,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CupertinoColors.white.withOpacity(opacity),
        ),
      ),
    );
  }

  /// Creates a moving rotating blob.
  Widget _buildMovingBlob(
      double top, double left, double opacity, double movement) {
    return Positioned(
      top: top + movement * 20,
      left: left - movement * 20,
      child: Transform.rotate(
        angle: movement * 2 * pi,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: CupertinoColors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }
}
