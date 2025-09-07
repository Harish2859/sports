import 'package:flutter/material.dart';
import 'dart:math' as math;

class RippleGridBackground extends StatefulWidget {
  final bool enableRainbow;
  final Color gridColor;
  final double rippleIntensity;
  final int gridSize;
  final double gridThickness;
  final bool mouseInteraction;
  final double mouseInteractionRadius;
  final double opacity;

  const RippleGridBackground({
    Key? key,
    this.enableRainbow = false,
    this.gridColor = Colors.white,
    this.rippleIntensity = 0.05,
    this.gridSize = 10,
    this.gridThickness = 15,
    this.mouseInteraction = true,
    this.mouseInteractionRadius = 1.2,
    this.opacity = 0.8,
  }) : super(key: key);

  @override
  State<RippleGridBackground> createState() => _RippleGridBackgroundState();
}

class _RippleGridBackgroundState extends State<RippleGridBackground>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _rippleController;
  
  List<Ripple> _ripples = [];
  Offset? _lastTapPosition;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Add some initial ripples for ambient animation
    _addAmbientRipples();
  }

  void _addAmbientRipples() {
    final random = math.Random();
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 500), () {
        if (mounted) {
          _addRipple(Offset(
            random.nextDouble() * 400,
            random.nextDouble() * 600,
          ));
        }
      });
    }
  }

  void _addRipple(Offset position) {
    setState(() {
      _ripples.add(Ripple(
        position: position,
        startTime: DateTime.now().millisecondsSinceEpoch,
        maxRadius: widget.mouseInteractionRadius * 100,
      ));
    });

    // Remove old ripples
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _ripples.removeWhere((ripple) => 
            DateTime.now().millisecondsSinceEpoch - ripple.startTime > 2000);
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.mouseInteraction ? (details) {
        _addRipple(details.localPosition);
      } : null,
      onPanUpdate: widget.mouseInteraction ? (details) {
        if (_lastTapPosition == null || 
            (details.localPosition - _lastTapPosition!).distance > 50) {
          _addRipple(details.localPosition);
          _lastTapPosition = details.localPosition;
        }
      } : null,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return CustomPaint(
            painter: RippleGridPainter(
              animation: _animationController,
              ripples: _ripples,
              enableRainbow: widget.enableRainbow,
              gridColor: widget.gridColor,
              rippleIntensity: widget.rippleIntensity,
              gridSize: widget.gridSize,
              gridThickness: widget.gridThickness,
              opacity: widget.opacity,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class Ripple {
  final Offset position;
  final int startTime;
  final double maxRadius;

  Ripple({
    required this.position,
    required this.startTime,
    required this.maxRadius,
  });

  double getRadius() {
    final elapsed = DateTime.now().millisecondsSinceEpoch - startTime;
    final progress = (elapsed / 2000.0).clamp(0.0, 1.0);
    return maxRadius * progress;
  }

  double getOpacity() {
    final elapsed = DateTime.now().millisecondsSinceEpoch - startTime;
    final progress = (elapsed / 2000.0).clamp(0.0, 1.0);
    return (1.0 - progress) * 0.8;
  }
}

class RippleGridPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Ripple> ripples;
  final bool enableRainbow;
  final Color gridColor;
  final double rippleIntensity;
  final int gridSize;
  final double gridThickness;
  final double opacity;

  RippleGridPainter({
    required this.animation,
    required this.ripples,
    required this.enableRainbow,
    required this.gridColor,
    required this.rippleIntensity,
    required this.gridSize,
    required this.gridThickness,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Calculate grid spacing
    final cellWidth = size.width / gridSize;
    final cellHeight = size.height / gridSize;

    // Draw grid lines with ripple effects
    for (int i = 0; i <= gridSize; i++) {
      // Vertical lines
      final x = i * cellWidth;
      _drawLineWithRipples(
        canvas,
        Offset(x, 0),
        Offset(x, size.height),
        paint,
        size,
      );

      // Horizontal lines
      final y = i * cellHeight;
      _drawLineWithRipples(
        canvas,
        Offset(0, y),
        Offset(size.width, y),
        paint,
        size,
      );
    }

    // Draw ripple effects
    for (final ripple in ripples) {
      _drawRipple(canvas, ripple, paint, size);
    }
  }

  void _drawLineWithRipples(Canvas canvas, Offset start, Offset end, Paint paint, Size size) {
    const segments = 50;
    final isVertical = start.dx == end.dx;
    
    for (int i = 0; i < segments; i++) {
      final t1 = i / segments;
      final t2 = (i + 1) / segments;
      
      final point1 = Offset.lerp(start, end, t1)!;
      final point2 = Offset.lerp(start, end, t2)!;
      
      // Calculate ripple displacement
      double displacement1 = _calculateRippleDisplacement(point1, size);
      double displacement2 = _calculateRippleDisplacement(point2, size);
      
      // Add ambient wave animation
      final waveOffset1 = math.sin(animation.value * 2 * math.pi + 
          (isVertical ? point1.dy : point1.dx) * 0.01) * 2;
      final waveOffset2 = math.sin(animation.value * 2 * math.pi + 
          (isVertical ? point2.dy : point2.dx) * 0.01) * 2;
      
      displacement1 += waveOffset1;
      displacement2 += waveOffset2;
      
      // Apply displacement perpendicular to line direction
      Offset adjustedPoint1, adjustedPoint2;
      if (isVertical) {
        adjustedPoint1 = Offset(point1.dx + displacement1, point1.dy);
        adjustedPoint2 = Offset(point2.dx + displacement2, point2.dy);
      } else {
        adjustedPoint1 = Offset(point1.dx, point1.dy + displacement1);
        adjustedPoint2 = Offset(point2.dx, point2.dy + displacement2);
      }
      
      // Calculate opacity based on displacement
      final maxDisplacement = math.max(displacement1.abs(), displacement2.abs());
      final segmentOpacity = (opacity * (1.0 + maxDisplacement * rippleIntensity * 2)).clamp(0.0, 1.0);
      
      paint.color = gridColor.withOpacity(segmentOpacity);
      
      if (enableRainbow) {
        final hue = (animation.value * 360 + i * 10) % 360;
        paint.color = HSVColor.fromAHSV(segmentOpacity, hue, 0.7, 0.9).toColor();
      }
      
      canvas.drawLine(adjustedPoint1, adjustedPoint2, paint);
    }
  }

  double _calculateRippleDisplacement(Offset point, Size size) {
    double totalDisplacement = 0;
    
    for (final ripple in ripples) {
      final distance = (point - ripple.position).distance;
      final rippleRadius = ripple.getRadius();
      final rippleOpacity = ripple.getOpacity();
      
      if (distance < rippleRadius && rippleOpacity > 0) {
        final normalizedDistance = distance / rippleRadius;
        final wave = math.sin(normalizedDistance * math.pi * 4) * 
                    math.exp(-normalizedDistance * 3);
        totalDisplacement += wave * rippleIntensity * 50 * rippleOpacity;
      }
    }
    
    return totalDisplacement;
  }

  void _drawRipple(Canvas canvas, Ripple ripple, Paint paint, Size size) {
    final radius = ripple.getRadius();
    final rippleOpacity = ripple.getOpacity();
    
    if (rippleOpacity <= 0) return;
    
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;
    paint.color = gridColor.withOpacity(rippleOpacity * 0.3);
    
    if (enableRainbow) {
      final hue = (animation.value * 360) % 360;
      paint.color = HSVColor.fromAHSV(rippleOpacity * 0.3, hue, 0.7, 0.9).toColor();
    }
    
    canvas.drawCircle(ripple.position, radius, paint);
  }

  @override
  bool shouldRepaint(RippleGridPainter oldDelegate) {
    return animation.value != oldDelegate.animation.value ||
           ripples.length != oldDelegate.ripples.length;
  }
}
