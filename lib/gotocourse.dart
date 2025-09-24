import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:provider/provider.dart';

import 'main_layout.dart';
import 'trainingunits.dart';
import 'unit_details.dart';
import 'course_data_manager.dart';
import 'app_state.dart';
import 'theme_provider.dart';

import 'course_models.dart';

class GotoCoursePage extends StatefulWidget {
  final String courseName;
  final String? courseId;
  
  const GotoCoursePage({Key? key, this.courseName = "Strength", this.courseId}) : super(key: key);

  @override
  _GotoCoursePageState createState() => _GotoCoursePageState();
}

class _GotoCoursePageState extends State<GotoCoursePage> with TickerProviderStateMixin {
  int currentSectionIndex = 0;
  bool showSectionOverlay = false;
  bool showUnitsCard = false;
  
  late AnimationController _overlayController;
  late AnimationController _unitController;
  late AnimationController _breathingController;
  late AnimationController _heroController;
  late AnimationController _progressController;
  
  late Animation<double> _overlayAnimation;
  late Animation<double> _unitAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<double> _heroAnimation;
  late Animation<double> _progressAnimation;

  Map<int, Map<int, bool>> unitCompletionStatus = {};

  final CourseDataManager _courseManager = CourseDataManager();
  List<CourseSection> sections = [];

  final Map<int, List<Unit>> sectionUnits = {
    0: [
      Unit("Warm-Up Readiness", "Learn proper activation techniques", UnitStatus.completed, Icons.flash_on),
      Unit("Movement Efficiency", "Master fundamental lifts", UnitStatus.completed, Icons.fitness_center),
      Unit("Form Consistency", "Perfect your technique", UnitStatus.completed, Icons.security),
      Unit("Progressive Load Response", "Understand load progression", UnitStatus.inProgress, Icons.trending_up),
      Unit("Recovery Capacity", "Optimize rest and nutrition", UnitStatus.notStarted, Icons.bedtime),
    ],
    1: [
      Unit("Load Baseline Assessment", "Learn training cycles", UnitStatus.notStarted, Icons.calendar_today),
      Unit("Incremental Load Challenge", "Advance your technique", UnitStatus.notStarted, Icons.fitness_center),
      Unit("Fatigue Resistance Test", "Balance training load", UnitStatus.notStarted, Icons.balance),
      Unit("Maximum Effort Evaluation", "Overcome sticking points", UnitStatus.notStarted, Icons.trending_up),
      Unit("Load Recovery Monitoring", "Support your main lifts", UnitStatus.notStarted, Icons.extension),
    ],
    2: [
      Unit("Explosive Power Assessment", "Combine strength & power", UnitStatus.notStarted, Icons.flash_on),
      Unit("Dynamic Stability Test", "Explosive movement patterns", UnitStatus.notStarted, Icons.directions_run),
      Unit("Advanced Movement Analysis", "Advanced programming", UnitStatus.notStarted, Icons.schedule),
      Unit("Strength Endurance Challenge", "Peak for performance", UnitStatus.notStarted, Icons.emoji_events),
      Unit("Peak Performance Benchmark", "Advanced recovery strategies", UnitStatus.notStarted, Icons.local_hospital),
    ],
    3: [
      Unit("Sport-Specific Power Test", "Targeted training approaches", UnitStatus.notStarted, Icons.sports),
      Unit("Functional Strength Analysis", "Explosive strength training", UnitStatus.notStarted, Icons.bolt),
      Unit("Targeted Muscle Assessment", "Real-world applications", UnitStatus.notStarted, Icons.accessibility_new),
      Unit("Personalized Load Adaptation", "Mindset and focus", UnitStatus.notStarted, Icons.psychology),
      Unit("Specialized Recovery Strategy", "Career planning", UnitStatus.notStarted, Icons.timeline),
    ],
  };

  @override
  void initState() {
    super.initState();
    _initializeSections();
    _updateSectionProgress();
    
    _overlayController = AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _unitController = AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _breathingController = AnimationController(vsync: this, duration: Duration(seconds: 3))..repeat(reverse: true);
    _heroController = AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _progressController = AnimationController(vsync: this, duration: Duration(milliseconds: 1200));
    
    _overlayAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _overlayController, curve: Curves.easeInOut));
    _unitAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _unitController, curve: Curves.elasticOut));
    _breathingAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut));
    _heroAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _heroController, curve: Curves.easeOutBack));
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeInOut));

    _unitController.forward();
    _heroController.forward();
    _progressController.forward();
  }

  void _initializeSections() {
    final courseId = widget.courseId ?? '1';
    final courseSections = _courseManager.getCourseSections(courseId);
    sections = courseSections.map((sectionData) => CourseSection(
      title: sectionData.title,
      description: sectionData.description,
      progress: 0.0,
      color: Color(0xFF2563EB),
    )).toList();
    
    for (int i = 0; i < courseSections.length; i++) {
      sectionUnits[i] = courseSections[i].units.map((unitData) => Unit(
        unitData.name,
        unitData.description,
        UnitStatus.notStarted,
        Icons.fitness_center,
      )).toList();
      
      unitCompletionStatus[i] = {};
      for (int j = 0; j < sectionUnits[i]!.length; j++) {
        unitCompletionStatus[i]![j] = false;
      }
    }
  }
  
  void _updateSectionProgress() {
    for (int sectionIndex = 0; sectionIndex < sections.length; sectionIndex++) {
      int completedUnits = 0;
      int totalUnits = sectionUnits[sectionIndex]?.length ?? 0;
      
      unitCompletionStatus[sectionIndex]?.forEach((unitIndex, isCompleted) {
        if (isCompleted) completedUnits++;
      });
      
      double progress = totalUnits > 0 ? completedUnits / totalUnits : 0.0;
      sections[sectionIndex] = CourseSection(
        title: sections[sectionIndex].title,
        description: sections[sectionIndex].description,
        progress: progress,
        color: sections[sectionIndex].color,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final isStrengthAssessment = widget.courseId == '3';

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFF8FAFE),
      body: CustomScrollView(
        slivers: [
          
          SliverAppBar(
            backgroundColor: isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFF8FAFE),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.more_vert, color: isDarkMode ? Colors.white : Colors.black),
                onPressed: _showActionMenu,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                if (isStrengthAssessment) ...[
                  _buildStrengthAssessmentHeader(isDarkMode),
                  _buildSingleUnitCard(isDarkMode),
                ] else ...[
                  _buildHeroSection(isDarkMode),
                  _buildProgressOverview(isDarkMode),
                  _buildSectionSelector(isDarkMode),
                  _buildUnitsSection(isDarkMode),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedAppBar(bool isDarkMode) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      stretch: true,
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFF2563EB),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode 
                    ? [const Color(0xFF1A1A1A), const Color(0xFF2D2D2D)]
                    : [const Color(0xFF2563EB), const Color(0xFF3B82F6)],
                ),
              ),
            ),
            Positioned(
              right: -50,
              top: -50,
              child: AnimatedBuilder(
                animation: _breathingAnimation,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _breathingAnimation.value,
                    child: child,
                  );
                },
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: AnimatedBuilder(
                animation: _heroAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - _heroAnimation.value)),
                    child: Opacity(
                      opacity: _heroAnimation.value.clamp(0.0, 1.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Text(
                              'TRAINING MODULE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.courseName} Training',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showActionMenu,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _heroAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _heroAnimation.value)),
          child: Opacity(
            opacity: _heroAnimation.value.clamp(0.0, 1.0),
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode 
                    ? [const Color(0xFF1F1F1F), const Color(0xFF2A2A2A)]
                    : [Colors.white, const Color(0xFFF8FAFE)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF2563EB), const Color(0xFF3B82F6)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Progress',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sections[currentSectionIndex].title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                    ),
                    child: Text(
                      '${(sections[currentSectionIndex].progress * 100).toInt()}%',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressOverview(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _progressAnimation.value)),
          child: Opacity(
            opacity: _progressAnimation.value.clamp(0.0, 1.0),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: sections[currentSectionIndex].progress * _progressAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${currentSectionIndex + 1}/${sections.length}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionSelector(bool isDarkMode) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final isSelected = index == currentSectionIndex;
          final isUnlocked = _isSectionUnlocked(index);
          final isCompleted = _isSectionCompleted(index);
          
          return GestureDetector(
            onTap: () => _selectSection(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected 
                  ? const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF3B82F6)])
                  : null,
                color: !isSelected 
                  ? (isDarkMode ? const Color(0xFF1F1F1F) : Colors.white)
                  : null,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected 
                    ? Colors.transparent
                    : (isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.3)),
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ] : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isCompleted)
                    const Icon(Icons.check_circle, size: 18, color: Colors.white)
                  else if (!isUnlocked)
                    Icon(Icons.lock, size: 18, color: isSelected ? Colors.white : Colors.grey)
                  else
                    Icon(Icons.play_circle_fill, size: 18, color: isSelected ? Colors.white : const Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  Text(
                    'Section ${index + 1}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : (isDarkMode ? Colors.white : Colors.black87),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUnitsSection(bool isDarkMode) {
    List<Unit> currentUnits = sectionUnits[currentSectionIndex] ?? [];
    
    return AnimatedBuilder(
      animation: _unitAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.list_alt, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Training Units',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currentUnits.length,
                itemBuilder: (context, index) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - _unitAnimation.value)),
                    child: Opacity(
                      opacity: _unitAnimation.value.clamp(0.0, 1.0),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: _buildEnhancedUnitCard(currentUnits[index], index, isDarkMode),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnhancedUnitCard(Unit unit, int index, bool isDarkMode) {
    UnitStatus dynamicStatus = _getUnitStatus(currentSectionIndex, index);
    Color statusColor = _getStatusColor(dynamicStatus);
    IconData statusIcon = _getStatusIcon(dynamicStatus);
    bool isUnlocked = _isUnitUnlocked(currentSectionIndex, index);

    return Container(
      decoration: BoxDecoration(
        gradient: isUnlocked 
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode 
                ? [const Color(0xFF1F1F1F), const Color(0xFF2A2A2A)]
                : [Colors.white, const Color(0xFFF8FAFE)],
            )
          : null,
        color: !isUnlocked 
          ? (isDarkMode ? const Color(0xFF151515) : Colors.grey[100])
          : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: dynamicStatus == UnitStatus.inProgress 
            ? statusColor
            : (isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2)),
          width: dynamicStatus == UnitStatus.inProgress ? 2 : 1,
        ),
        boxShadow: isUnlocked ? [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ] : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isUnlocked ? () => _openUnit(unit, index) : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: isUnlocked 
                      ? LinearGradient(colors: [statusColor, statusColor.withOpacity(0.8)])
                      : null,
                    color: !isUnlocked ? Colors.grey : null,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isUnlocked ? [
                      BoxShadow(
                        color: statusColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ] : [],
                  ),
                  child: Icon(
                    isUnlocked ? unit.icon : Icons.lock,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unit.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked 
                            ? (isDarkMode ? Colors.white : Colors.black87)
                            : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unit.description,
                        style: TextStyle(
                          color: isUnlocked 
                            ? (isDarkMode ? Colors.grey[400] : Colors.grey[600])
                            : Colors.grey,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods remain the same
  UnitStatus _getUnitStatus(int sectionIndex, int unitIndex) {
    if (unitCompletionStatus[sectionIndex]?[unitIndex] == true) {
      return UnitStatus.completed;
    }
    if (_isUnitUnlocked(sectionIndex, unitIndex)) {
      if (_isNextUnitToComplete(sectionIndex, unitIndex)) {
        return UnitStatus.inProgress;
      }
      return UnitStatus.inProgress;
    }
    return UnitStatus.notStarted;
  }
  
  bool _isUnitUnlocked(int sectionIndex, int unitIndex) {
    if (sectionIndex == 0 && unitIndex == 0) return true;
    if (unitIndex == 0) {
      if (sectionIndex > 0) {
        return _isSectionCompleted(sectionIndex - 1);
      }
    }
    if (unitIndex > 0) {
      return unitCompletionStatus[sectionIndex]?[unitIndex - 1] == true;
    }
    return false;
  }
  
  bool _isNextUnitToComplete(int sectionIndex, int unitIndex) {
    if (unitIndex == 0) {
      if (sectionIndex == 0) return true;
      return _isSectionCompleted(sectionIndex - 1);
    }
    return unitCompletionStatus[sectionIndex]?[unitIndex - 1] == true;
  }
  
  bool _isSectionCompleted(int sectionIndex) {
    Map<int, bool>? sectionUnits = unitCompletionStatus[sectionIndex];
    if (sectionUnits == null || sectionUnits.isEmpty) return false;
    
    int totalUnits = this.sectionUnits[sectionIndex]?.length ?? 0;
    if (totalUnits == 0) return false;
    
    for (int i = 0; i < totalUnits; i++) {
      if (sectionUnits[i] != true) {
        return false;
      }
    }
    return true;
  }
  
  bool _isSectionUnlocked(int sectionIndex) {
    if (sectionIndex == 0) return true;
    return _isSectionCompleted(sectionIndex - 1);
  }
  
  void _completeUnit(int sectionIndex, int unitIndex) {
    if (mounted) {
      setState(() {
        if (unitCompletionStatus[sectionIndex] == null) {
          unitCompletionStatus[sectionIndex] = {};
        }
        unitCompletionStatus[sectionIndex]![unitIndex] = true;
        _updateSectionProgress();
        
        if (_isSectionCompleted(sectionIndex)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 Section ${sectionIndex + 1} completed! Next section unlocked!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
    }
  }

  IconData _getStatusIcon(UnitStatus status) {
    switch (status) {
      case UnitStatus.completed:
        return Icons.check_circle;
      case UnitStatus.inProgress:
        return Icons.play_circle_fill;
      case UnitStatus.notStarted:
        return Icons.lock_outline;
    }
  }

  Color _getStatusColor(UnitStatus status) {
    switch (status) {
      case UnitStatus.completed:
        return const Color(0xFF10B981);
      case UnitStatus.inProgress:
        return const Color(0xFF2563EB);
      case UnitStatus.notStarted:
        return Colors.grey[500]!;
    }
  }

  void _selectSection(int index) {
    if (!mounted) return;
    
    if (index == currentSectionIndex) return;
    
    if (!_isSectionUnlocked(index)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Complete the previous section to unlock this one!'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    setState(() {
      currentSectionIndex = index;
    });
    
    _unitController.reset();
    _unitController.forward();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opened ${sections[index].title}! Start your training.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showActionMenu() {
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).themeMode == ThemeMode.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.download, color: const Color(0xFF2563EB)),
              title: Text('Download for Offline', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.share, color: const Color(0xFF2563EB)),
              title: Text('Share Course', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.bookmark, color: const Color(0xFF2563EB)),
              title: Text('Bookmark', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _openUnit(Unit unit, int unitIndex) async {
    try {
      final courseId = widget.courseId ?? '1';
      final courseSections = _courseManager.getCourseSections(courseId);
      final currentSection = courseSections[currentSectionIndex];
      final currentUnit = currentSection.units[unitIndex];
      
      String? videoUrl;
      if (widget.courseName.toLowerCase().contains('javelin') && 
          currentSectionIndex == 0 && unitIndex == 0) {
        videoUrl = 'assets/videos/video.mp4';
      }
      
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UnitDetailsPage(
            unitName: unit.title,
            unitDescription: unit.description,
            sectionName: sections[currentSectionIndex].title,
            unitIndex: unitIndex,
            sectionIndex: currentSectionIndex,
            totalUnitsInSection: sectionUnits[currentSectionIndex]?.length ?? 0,
            objectives: currentUnit.objectives,
            dos: currentUnit.dos,
            donts: currentUnit.donts,
            videoUrl: videoUrl,
          ),
        ),
      );
      
      if (result == true) {
        _completeUnit(currentSectionIndex, unitIndex);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${unit.title} completed! 🎉'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('Navigation error: $e');
    }
  }

  Widget _buildStrengthAssessmentHeader(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF2563EB), const Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Strength Assessment',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your baseline assessment',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleUnitCard(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: _buildEnhancedUnitCard(
        Unit("Assessment Test", "Complete your strength assessment", UnitStatus.inProgress, Icons.assessment),
        0,
        isDarkMode,
      ),
    );
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _unitController.dispose();
    _breathingController.dispose();
    _heroController.dispose();
    _progressController.dispose();
    super.dispose();
  }
}