import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'course_models.dart';

// Enum to track gamified theme state
enum GamifiedThemeState {
  disabled,
  enabled,
}

class GamifiedIconProvider with ChangeNotifier {
  GamifiedThemeState _gamifiedState = GamifiedThemeState.disabled;
  
  GamifiedThemeState get gamifiedState => _gamifiedState;
  
  void enableGamifiedTheme() {
    _gamifiedState = GamifiedThemeState.enabled;
    notifyListeners();
  }
  
  void disableGamifiedTheme() {
    _gamifiedState = GamifiedThemeState.disabled;
    notifyListeners();
  }
  
  bool get isGamified => _gamifiedState == GamifiedThemeState.enabled;
}

// Floating Medal Icon - for last units in sections
class FloatingMedalIcon extends StatefulWidget {
  final bool isCompleted;
  final double size;
  final VoidCallback? onTap;
  
  const FloatingMedalIcon({
    Key? key,
    required this.isCompleted,
    this.size = 60.0,
    this.onTap,
  }) : super(key: key);

  @override
  _FloatingMedalIconState createState() => _FloatingMedalIconState();
}

class _FloatingMedalIconState extends State<FloatingMedalIcon>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _floatingController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    
    // Slow spinning animation
    _rotationController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    // Floating up/down animation
    _floatingController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    _floatingAnimation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotationAnimation, _floatingAnimation]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatingAnimation.value),
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ColorFiltered(
                  colorFilter: widget.isCompleted
                      ? ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                      : ColorFilter.matrix([
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0, 0, 0, 1, 0,
                        ]),
                  child: Image.asset(
                    'assets/images/medal.png',
                    width: widget.size,
                    height: widget.size,
                    fit: BoxFit.contain,
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

// Breathing Star Icon - for completed sections
class BreathingStarIcon extends StatefulWidget {
  final double size;
  final VoidCallback? onTap;
  final bool isSilver;
  
  const BreathingStarIcon({
    Key? key,
    this.size = 60.0,
    this.onTap,
    this.isSilver = false,
  }) : super(key: key);

  @override
  _BreathingStarIconState createState() => _BreathingStarIconState();
}

class _BreathingStarIconState extends State<BreathingStarIcon>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _floatingController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    
    // Breathing scale animation
    _breathingController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    // Floating animation
    _floatingController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _breathingAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    
    _floatingAnimation = Tween<double>(
      begin: -3.0,
      end: 3.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_breathingAnimation, _floatingAnimation]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatingAnimation.value),
            child: Transform.scale(
              scale: _breathingAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.isSilver 
                          ? Colors.grey.withOpacity(0.4)
                          : Colors.yellow.withOpacity(0.4),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ColorFiltered(
                  colorFilter: widget.isSilver
                      ? ColorFilter.matrix([
                          0.5, 0.5, 0.5, 0, 0,
                          0.5, 0.5, 0.5, 0, 0,
                          0.5, 0.5, 0.5, 0, 0,
                          0, 0, 0, 1, 0,
                        ])
                      : ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                  child: Image.asset(
                    'assets/images/star.png',
                    width: widget.size,
                    height: widget.size,
                    fit: BoxFit.contain,
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

// Floating Treasure Icon - for locked units/sections
class FloatingTreasureIcon extends StatefulWidget {
  final double size;
  final VoidCallback? onTap;
  
  const FloatingTreasureIcon({
    Key? key,
    this.size = 60.0,
    this.onTap,
  }) : super(key: key);

  @override
  _FloatingTreasureIconState createState() => _FloatingTreasureIconState();
}

class _FloatingTreasureIconState extends State<FloatingTreasureIcon>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _bobController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _bobAnimation;

  @override
  void initState() {
    super.initState();
    
    // Main floating animation
    _floatingController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    // Secondary bobbing animation
    _bobController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    _floatingAnimation = Tween<double>(
      begin: -8.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
    
    _bobAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _bobController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _bobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_floatingAnimation, _bobAnimation]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatingAnimation.value + _bobAnimation.value),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/tressure.png',
                width: widget.size,
                height: widget.size,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}

// Zigzag Course Map Widget
class ZigzagCourseMap extends StatefulWidget {
  final List<CourseSection> sections;
  final int currentSectionIndex;
  final Function(int) onSectionTap;
  final Map<int, Map<int, bool>> unitCompletionStatus;
  final Map<int, List<Unit>> sectionUnits;
  
  const ZigzagCourseMap({
    Key? key,
    required this.sections,
    required this.currentSectionIndex,
    required this.onSectionTap,
    required this.unitCompletionStatus,
    required this.sectionUnits,
  }) : super(key: key);

  @override
  _ZigzagCourseMapState createState() => _ZigzagCourseMapState();
}

class _ZigzagCourseMapState extends State<ZigzagCourseMap>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _pathController;
  late Animation<double> _pathAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _pathController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _pathAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pathController, curve: Curves.easeInOut),
    );
    _pathController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 400,
              child: CustomPaint(
                painter: ZigzagPathPainter(
                  sections: widget.sections,
                  currentSectionIndex: widget.currentSectionIndex,
                  pathAnimation: _pathAnimation,
                ),
                child: Stack(
                  children: _buildSectionNodes(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSectionNodes() {
    List<Widget> nodes = [];
    double screenWidth = MediaQuery.of(context).size.width;
    double nodeSpacing = 100.0;
    
    for (int i = 0; i < widget.sections.length; i++) {
      // Calculate zigzag position
      double x = (i % 2 == 0) ? screenWidth * 0.2 : screenWidth * 0.8;
      double y = 50.0 + (i * nodeSpacing);
      
      bool isCompleted = _isSectionCompleted(i);
      
      bool isUnlocked = _isSectionUnlocked(i);
      
      Widget icon;
      if (isCompleted) {
        // Use star for completed sections
        icon = BreathingStarIcon(
          size: 80,
          onTap: () => widget.onSectionTap(i),
        );
      } else if (isUnlocked) {
        // Use colorful treasure for unlocked incomplete sections
        icon = FloatingTreasureIcon(
          size: 80,
          onTap: () => widget.onSectionTap(i),
        );
      } else {
        // Use black and white treasure for locked sections
        icon = ColorFiltered(
          colorFilter: ColorFilter.matrix([
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0, 0, 0, 1, 0,
          ]),
          child: FloatingTreasureIcon(
            size: 80,
            onTap: () => widget.onSectionTap(i),
          ),
        );
      }
      
      nodes.add(
        Positioned(
          left: x - 40,
          top: y,
          child: Column(
            children: [
              icon,
              SizedBox(height: 8),
              Container(
                width: 120,
                child: Text(
                  widget.sections[i].title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.black87 : Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return nodes;
  }

  bool _isSectionCompleted(int sectionIndex) {
    Map<int, bool>? sectionUnits = widget.unitCompletionStatus[sectionIndex];
    if (sectionUnits == null) return false;
    return sectionUnits.values.every((completed) => completed);
  }

  bool _isSectionUnlocked(int sectionIndex) {
    if (sectionIndex == 0) return true;
    return _isSectionCompleted(sectionIndex - 1);
  }

  bool _isLastUnitInSection(int sectionIndex) {
    List<Unit>? units = widget.sectionUnits[sectionIndex];
    return units != null && units.isNotEmpty;
  }
}

// Custom painter for zigzag path
class ZigzagPathPainter extends CustomPainter {
  final List<CourseSection> sections;
  final int currentSectionIndex;
  final Animation<double> pathAnimation;

  ZigzagPathPainter({
    required this.sections,
    required this.currentSectionIndex,
    required this.pathAnimation,
  }) : super(repaint: pathAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final completedPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    Path path = Path();
    double nodeSpacing = 100.0;
    
    for (int i = 0; i < sections.length - 1; i++) {
      double startX = (i % 2 == 0) ? size.width * 0.2 : size.width * 0.8;
      double startY = 50.0 + (i * nodeSpacing);
      double endX = ((i + 1) % 2 == 0) ? size.width * 0.2 : size.width * 0.8;
      double endY = 50.0 + ((i + 1) * nodeSpacing);
      
      if (i == 0) {
        path.moveTo(startX, startY);
      }
      
      // Create curved zigzag path
      double controlX = (startX + endX) / 2;
      double controlY = (startY + endY) / 2;
      path.quadraticBezierTo(controlX, controlY, endX, endY);
      
      // Draw completed sections in green
      if (i <= currentSectionIndex) {
        canvas.drawPath(path, completedPaint);
      } else {
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(ZigzagPathPainter oldDelegate) {
    return oldDelegate.currentSectionIndex != currentSectionIndex ||
           oldDelegate.pathAnimation != pathAnimation;
  }
}

// Import the existing classes from gotocourse.dart
// Unit, UnitStatus, and CourseSection are already defined in gotocourse.dart
