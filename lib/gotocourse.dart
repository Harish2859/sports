import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main_layout.dart';
import 'trainingunits.dart';
import 'unit_details.dart';
import 'course_data_manager.dart';
import 'app_state.dart';
import 'theme_provider.dart';

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
  late AnimationController _overlayController;
  late AnimationController _unitController;
  late Animation<double> _overlayAnimation;
  late Animation<double> _unitAnimation;
  
  // Track completion status for each unit in each section
  Map<int, Map<int, bool>> unitCompletionStatus = {
    0: {0: false, 1: false, 2: false, 3: false, 4: false}, // Section 0 units
    1: {0: false, 1: false, 2: false, 3: false, 4: false}, // Section 1 units
    2: {0: false, 1: false, 2: false, 3: false, 4: false}, // Section 2 units
    3: {0: false, 1: false, 2: false, 3: false, 4: false}, // Section 3 units
  };

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
    _overlayController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _unitController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _overlayAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _overlayController, curve: Curves.easeOut),
    );
    _unitAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _unitController, curve: Curves.elasticOut),
    );

    _initializeSections();
    _updateSectionProgress();
    _unitController.forward();
  }
  
  void _initializeSections() {
    final courseId = widget.courseId ?? '1'; // Use provided courseId or default
    final courseSections = _courseManager.getCourseSections(courseId);
    sections = courseSections.map((sectionData) => CourseSection(
      title: sectionData.title,
      description: sectionData.description,
      progress: 0.0,
      color: Color(0xFF2563EB),
    )).toList();
    
    // Initialize sectionUnits from course data
    for (int i = 0; i < courseSections.length; i++) {
      sectionUnits[i] = courseSections[i].units.map((unitData) => Unit(
        unitData.name,
        unitData.description,
        UnitStatus.notStarted,
        Icons.fitness_center,
      )).toList();
    }
  }
  
  // Calculate section progress based on completed units
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
  
  // Get dynamic unit status based on completion and unlocking logic
  UnitStatus _getUnitStatus(int sectionIndex, int unitIndex) {
    // Check if unit is completed
    if (unitCompletionStatus[sectionIndex]?[unitIndex] == true) {
      return UnitStatus.completed;
    }
    
    // Check if unit should be unlocked
    if (_isUnitUnlocked(sectionIndex, unitIndex)) {
      // If it's the next unit to complete, mark as in progress
      if (_isNextUnitToComplete(sectionIndex, unitIndex)) {
        return UnitStatus.inProgress;
      }
      return UnitStatus.inProgress; // Available to start
    }
    
    return UnitStatus.notStarted; // Locked
  }
  
  // Check if a unit should be unlocked
  bool _isUnitUnlocked(int sectionIndex, int unitIndex) {
    // First unit of first section is always unlocked
    if (sectionIndex == 0 && unitIndex == 0) return true;
    
    // For first unit of other sections, check if previous section is completed
    if (unitIndex == 0) {
      if (sectionIndex > 0) {
        return _isSectionCompleted(sectionIndex - 1);
      }
    }
    
    // For other units, check if previous unit is completed
    if (unitIndex > 0) {
      return unitCompletionStatus[sectionIndex]?[unitIndex - 1] == true;
    }
    
    return false;
  }
  
  // Check if this is the next unit to complete
  bool _isNextUnitToComplete(int sectionIndex, int unitIndex) {
    // If previous unit is completed (or this is first unit), this could be next
    if (unitIndex == 0) {
      if (sectionIndex == 0) return true;
      return _isSectionCompleted(sectionIndex - 1);
    }
    
    return unitCompletionStatus[sectionIndex]?[unitIndex - 1] == true;
  }
  
  // Check if a section is completed
  bool _isSectionCompleted(int sectionIndex) {
    Map<int, bool>? sectionUnits = unitCompletionStatus[sectionIndex];
    if (sectionUnits == null) return false;
    
    return sectionUnits.values.every((completed) => completed);
  }
  
  // Mark unit as completed and update progress
  void _completeUnit(int sectionIndex, int unitIndex) {
    if (mounted) {
      setState(() {
        unitCompletionStatus[sectionIndex]?[unitIndex] = true;
        _updateSectionProgress();
      });
    }
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return MainLayout(
      currentIndex: 3, // Course tab
      onTabChanged: (index) {
        if (index != 3) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.grey[900] : Color(0xFFF8FAFE),
        appBar: AppBar(
          title: Text(
            '${widget.courseName} Training',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: sections[currentSectionIndex].color,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () => _showCourseInfo(),
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                _buildSectionBar(),
                Expanded(child: _buildUnitsSection()),
              ],
            ),
            if (showSectionOverlay) _buildSectionOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionBar() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: sections[currentSectionIndex].color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: GestureDetector(
              onTap: _toggleSectionOverlay,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            sections[currentSectionIndex].title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: sections[currentSectionIndex].progress,
                                  backgroundColor: Colors.white.withOpacity(0.3),
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${(sections[currentSectionIndex].progress * 100).toInt()}%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      showSectionOverlay ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(width: 1, color: Colors.white.withOpacity(0.3)),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () => _showActionMenu(),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionOverlay() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return GestureDetector(
      onTap: _toggleSectionOverlay,
      child: AnimatedBuilder(
        animation: _overlayAnimation,
        builder: (context, child) {
          return Container(
            color: Colors.black.withOpacity(0.5 * _overlayAnimation.value),
            child: Column(
              children: [
                SizedBox(height: 80), // Account for section bar
                Expanded(
                  child: Transform.translate(
                    offset: Offset(0, 50 * (1 - _overlayAnimation.value)),
                    child: Opacity(
                      opacity: _overlayAnimation.value.clamp(0.0, 1.0),
                      child: Container(
                        margin: EdgeInsets.all(16),
                        child: ListView.builder(
                          itemCount: sections.length,
                          itemBuilder: (context, index) {
                            return _buildSectionCard(sections[index], index);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(CourseSection section, int index) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    bool isSelected = index == currentSectionIndex;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectSection(index),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isSelected ? Border.all(color: section.color, width: 3) : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: section.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: section.color,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        section.description,
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: section.progress,
                              backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(section.color),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${(section.progress * 100).toInt()}%',
                            style: TextStyle(
                              color: section.color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: section.color,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnitsSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    List<Unit> currentUnits = sectionUnits[currentSectionIndex] ?? [];
    
    return AnimatedBuilder(
      animation: _unitAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Training Units',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: currentUnits.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Transform.translate(
                        offset: Offset(0, 50 * (1 - _unitAnimation.value)),
                        child: Opacity(
                          opacity: _unitAnimation.value.clamp(0.0, 1.0),
                          child: _buildUnitCard(currentUnits[index], index),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUnitCard(Unit unit, int index) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    UnitStatus dynamicStatus = _getUnitStatus(currentSectionIndex, index);
    Color cardColor = _getUnitColor(dynamicStatus, isDarkMode);
    IconData statusIcon = _getStatusIcon(dynamicStatus);
    Color statusColor = _getStatusColor(dynamicStatus);
    bool isUnlocked = _isUnitUnlocked(currentSectionIndex, index);

    return Container(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isUnlocked ? () => _openUnit(unit, index) : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isUnlocked ? [
                BoxShadow(
                  color: statusColor.withOpacity(0.2),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ] : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
              border: dynamicStatus == UnitStatus.inProgress 
                ? Border.all(color: sections[currentSectionIndex].color, width: 2)
                : null,
            ),
            child: Stack(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        unit.icon,
                        color: statusColor,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            unit.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            unit.description,
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        statusIcon,
                        color: statusColor,
                        size: 24,
                      ),

                    ),
                  ],
                ),
                if (!isUnlocked)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.lock,
                          color: isDarkMode ? Colors.white : Colors.grey[600],
                          size: 32,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getUnitColor(UnitStatus status, bool isDarkMode) {
    if (isDarkMode) {
      switch (status) {
        case UnitStatus.completed:
          return Colors.green[900]!;
        case UnitStatus.inProgress:
          return Colors.blue[900]!;
        case UnitStatus.notStarted:
          return Colors.grey[800]!;
      }
    } else {
      switch (status) {
        case UnitStatus.completed:
          return Colors.green[50]!;
        case UnitStatus.inProgress:
          return Colors.blue[50]!;
        case UnitStatus.notStarted:
          return Colors.grey[100]!;
      }
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
        return Colors.green[600]!;
      case UnitStatus.inProgress:
        return sections[currentSectionIndex].color;
      case UnitStatus.notStarted:
        return Colors.grey[500]!;
    }
  }

  void _toggleSectionOverlay() {
    if (!mounted) return;
    setState(() {
      showSectionOverlay = !showSectionOverlay;
    });
    
    if (showSectionOverlay) {
      _overlayController.forward();
    } else {
      _overlayController.reverse();
    }
  }

  void _selectSection(int index) {
    if (!mounted) return;
    setState(() {
      currentSectionIndex = index;
      showSectionOverlay = false;
    });
    _overlayController.reverse();
    _unitController.reset();
    _unitController.forward();
  }

  void _moveToNextSection() {
    if (currentSectionIndex < sections.length - 1) {
      setState(() {
        currentSectionIndex++;
        showSectionOverlay = false;
      });
      _unitController.reset();
      _unitController.forward();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Section completed! Welcome to ${sections[currentSectionIndex].title}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      // All sections completed - generate certificate
      final appState = AppState.instance;
      appState.completeCourse(widget.courseId ?? '1', widget.courseName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Congratulations! You have completed all sections! 🎉\nCertificate earned!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showActionMenu() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.download, color: sections[currentSectionIndex].color),
              title: Text('Download for Offline', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.share, color: sections[currentSectionIndex].color),
              title: Text('Share Course', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.bookmark, color: sections[currentSectionIndex].color),
              title: Text('Bookmark', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showCourseInfo() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Course information'),
        backgroundColor: sections[currentSectionIndex].color,
      ),
    );
  }

  void _openUnit(Unit unit, int unitIndex) async {
    try {
      final courseId = widget.courseId ?? '1';
      final courseSections = _courseManager.getCourseSections(courseId);
      final currentSection = courseSections[currentSectionIndex];
      final currentUnit = currentSection.units[unitIndex];
      
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EnhancedUnitDetailsPage(
            unitName: unit.title,
            unitDescription: unit.description,
            sectionName: sections[currentSectionIndex].title,
            unitIndex: unitIndex,
            sectionIndex: currentSectionIndex,
            totalUnitsInSection: sectionUnits[currentSectionIndex]?.length ?? 0,
            objectives: currentUnit.objectives,
            dos: currentUnit.dos,
            donts: currentUnit.donts,
          ),
        ),
      );
      
      // Handle different completion results
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
      } else if (result == 'section_complete') {
        _completeUnit(currentSectionIndex, unitIndex);
        _moveToNextSection();
      }
    } catch (e) {
      // Handle navigation errors silently
      print('Navigation error: $e');
    }
  }
  
  void _showUnitDialog(Unit unit, int unitIndex) {
    if (!mounted) return;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
          title: Text(unit.title, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(unit.description, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
              SizedBox(height: 16),
              Text(
                'This unit is not yet implemented. Would you like to mark it as completed for demo purposes?',
                style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
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
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: sections[currentSectionIndex].color,
                foregroundColor: Colors.white,
              ),
              child: Text('Mark Complete'),
            ),
          ],
        );
      },
    );
  }
}

// Data Models
class CourseSection {
  final String title;
  final String description;
  final double progress;
  final Color color;

  CourseSection({
    required this.title,
    required this.description,
    required this.progress,
    required this.color,
  });
}

class Unit {
  final String title;
  final String description;
  final UnitStatus status;
  final IconData icon;

  Unit(this.title, this.description, this.status, this.icon);
}

enum UnitStatus { completed, inProgress, notStarted }
