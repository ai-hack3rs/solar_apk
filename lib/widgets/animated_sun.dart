import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedSun extends StatefulWidget {
  final double size;
  const AnimatedSun({super.key, this.size = 80});

  @override
  State<AnimatedSun> createState() => _AnimatedSunState();
}

class _AnimatedSunState extends State<AnimatedSun>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _SunPainter(_controller.value),
        );
      },
    );
  }
}

class _SunPainter extends CustomPainter {
  final double progress;
  _SunPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFD54F).withValues(alpha: 0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, glowPaint);

    // Draw rays
    final rayPaint = Paint()
      ..color = const Color(0xFFFFB300).withValues(alpha: 0.7)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    const numRays = 12;
    const innerR = 0.38;
    const outerR = 0.50;
    for (int i = 0; i < numRays; i++) {
      final angle = (i / numRays) * 2 * math.pi + progress * 2 * math.pi;
      final p1 = Offset(
        center.dx + math.cos(angle) * radius * innerR,
        center.dy + math.sin(angle) * radius * innerR,
      );
      final p2 = Offset(
        center.dx + math.cos(angle) * radius * outerR,
        center.dy + math.sin(angle) * radius * outerR,
      );
      canvas.drawLine(p1, p2, rayPaint);
    }

    // Draw core circle
    final corePaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFEE58), Color(0xFFFFB300)],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.32));
    canvas.drawCircle(center, radius * 0.30, corePaint);
  }

  @override
  bool shouldRepaint(_SunPainter old) => old.progress != progress;
}

class PulsingGlow extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  const PulsingGlow({super.key, required this.child, required this.glowColor});

  @override
  State<PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<PulsingGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: widget.glowColor.withValues(alpha: _anim.value * 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ],
        ),
        child: child,
      ),
      child: widget.child,
    );
  }
}
