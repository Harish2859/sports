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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    if (!widget.claimed) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(SpinningClaimXPWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.claimed && !oldWidget.claimed) {
      _controller.stop();
    } else if (!widget.claimed && oldWidget.claimed) {
      _controller.repeat();
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
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = widget.claimed ? 0.0 : _controller.value * 2 * math.pi;
          final isShowingFront = (angle % (2 * math.pi)) < math.pi;
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle.toDouble()),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.claimed ? Colors.grey : Colors.amber,
                  width: 6,
                ),
                boxShadow: widget.claimed ? [] : [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.6),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: ClipOval(
                child: isShowingFront
                    ? ColorFiltered(
                        colorFilter: widget.claimed 
                          ? ColorFilter.mode(Colors.grey, BlendMode.saturation)
                          : ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                        child: Image.asset(
                          'assets/images/xp.png.png',
                          fit: BoxFit.cover,
                        ),
                      )
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: widget.claimed 
                                ? [Colors.grey[400]!, Colors.grey[600]!]
                                : [Colors.amber[300]!, Colors.orange[600]!],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '100\nXP',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    offset: Offset(1, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}