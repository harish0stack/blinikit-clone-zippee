// lib/core/widgets/payment_status_animations.dart
// Micro-interaction animations for Payment Success (Green Tick) and Payment Failure (Red Cross)
// Built with pure Flutter CustomPainter (zero external Lottie/asset dependencies)
import 'dart:math';
import 'package:flutter/material.dart';

/// Animated Success Indicator: Radial burst + Scale-bounce green circle + Checkmark drawing
class PaymentSuccessAnimation extends StatefulWidget {
  final VoidCallback? onComplete;
  final double size;

  const PaymentSuccessAnimation({
    super.key,
    this.onComplete,
    this.size = 140,
  });

  @override
  State<PaymentSuccessAnimation> createState() =>
      _PaymentSuccessAnimationState();
}

class _PaymentSuccessAnimationState extends State<PaymentSuccessAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _circleScale;
  late final Animation<double> _checkProgress;
  late final Animation<double> _burstProgress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    // Circle pops in first (0–40%)
    _circleScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.40, curve: Curves.easeOutBack),
    );

    // Checkmark draws in next (30–75%)
    _checkProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.30, 0.75, curve: Curves.easeOut),
    );

    // Soft radial burst plays alongside checkmark (50–100%)
    _burstProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.50, 1.0, curve: Curves.easeOut),
    );

    _controller.forward().whenComplete(() {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF16A34A); // Blinkit brand green

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _SuccessPainter(
              circleScale: _circleScale.value,
              checkProgress: _checkProgress.value,
              burstProgress: _burstProgress.value,
              color: green,
            ),
          ),
        );
      },
    );
  }
}

class _SuccessPainter extends CustomPainter {
  final double circleScale;
  final double checkProgress;
  final double burstProgress;
  final Color color;

  _SuccessPainter({
    required this.circleScale,
    required this.checkProgress,
    required this.burstProgress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    // 1. Radial burst (8 short rays fading outward)
    if (burstProgress > 0) {
      final rayPaint = Paint()
        ..color = color.withValues(alpha: (1 - burstProgress) * 0.6)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < 8; i++) {
        final angle = (i / 8) * 2 * pi;
        final start = center + Offset(cos(angle), sin(angle)) * (radius + 4);
        final end = center +
            Offset(cos(angle), sin(angle)) * (radius + 4 + 14 * burstProgress);
        canvas.drawLine(start, end, rayPaint);
      }
    }

    // 2. Filled Circle scaling in with bounce
    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * circleScale, circlePaint);

    // 3. Progressive Checkmark path drawing
    if (checkProgress > 0) {
      final checkPath = Path();
      final p1 = center + Offset(-radius * 0.45, 0);
      final p2 = center + Offset(-radius * 0.12, radius * 0.35);
      final p3 = center + Offset(radius * 0.48, -radius * 0.32);

      checkPath.moveTo(p1.dx, p1.dy);
      checkPath.lineTo(p2.dx, p2.dy);
      checkPath.lineTo(p3.dx, p3.dy);

      for (final metric in checkPath.computeMetrics()) {
        final extractPath = metric.extractPath(0, metric.length * checkProgress);
        final checkPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(extractPath, checkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SuccessPainter oldDelegate) => true;
}

/// Animated Failure Indicator: Red circle scale-bounce + Progressive Cross drawing
class PaymentFailureAnimation extends StatefulWidget {
  final VoidCallback? onComplete;
  final double size;

  const PaymentFailureAnimation({
    super.key,
    this.onComplete,
    this.size = 140,
  });

  @override
  State<PaymentFailureAnimation> createState() =>
      _PaymentFailureAnimationState();
}

class _PaymentFailureAnimationState extends State<PaymentFailureAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _circleScale;
  late final Animation<double> _crossProgress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _circleScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
    );

    _crossProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );

    _controller.forward().whenComplete(() {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFDC2626);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _FailurePainter(
              circleScale: _circleScale.value,
              crossProgress: _crossProgress.value,
              color: red,
            ),
          ),
        );
      },
    );
  }
}

class _FailurePainter extends CustomPainter {
  final double circleScale;
  final double crossProgress;
  final Color color;

  _FailurePainter({
    required this.circleScale,
    required this.crossProgress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    // Filled Circle scaling in
    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * circleScale, circlePaint);

    // Cross ✕ lines
    if (crossProgress > 0) {
      final crossPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.5
        ..strokeCap = StrokeCap.round;

      final arm = radius * 0.35;

      // Stroke 1: Top-left to bottom-right
      final p1 = center + Offset(-arm, -arm);
      final p2 = center + Offset(arm, arm);
      final currentP2 = Offset.lerp(p1, p2, (crossProgress * 1.5).clamp(0.0, 1.0))!;
      canvas.drawLine(p1, currentP2, crossPaint);

      // Stroke 2: Top-right to bottom-left
      if (crossProgress > 0.4) {
        final normProg = ((crossProgress - 0.4) / 0.6).clamp(0.0, 1.0);
        final p3 = center + Offset(arm, -arm);
        final p4 = center + Offset(-arm, arm);
        final currentP4 = Offset.lerp(p3, p4, normProg)!;
        canvas.drawLine(p3, currentP4, crossPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FailurePainter oldDelegate) => true;
}
