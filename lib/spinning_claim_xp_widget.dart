import 'package:flutter/material.dart';
import 'dart:math' as math;

class SpinningClaimXPWidget extends StatefulWidget {
  final VoidCallback onPressed;
  final bool claimed;

  const SpinningClaimXPWidget({
    Key? key,
    required this.onPressed,
    required this.claimed,
  }) : super(key: key);

  @override
  _SpinningClaimXPWidgetState createState() => _SpinningClaimXPWidgetState();
}

class _SpinningClaimXPWidgetState extends State<SpinningClaimXPWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (!widget.claimed) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SpinningClaimXPWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.claimed && !oldWidget.claimed) {
      _controller.stop();
    } else if (!widget.claimed && oldWidget.claimed) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.claimed ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Opacity(
          opacity: widget.claimed ? 0.5 : 1.0,
          child: Image.asset(
            'assets/images/xp.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
