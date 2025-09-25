import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'theme_provider.dart';
import 'unit_details.dart';

class CourseUnitsPage extends StatefulWidget {
  final String courseName;
  final String courseId;

  const CourseUnitsPage({
    Key? key,
    required this.courseName,
    required this.courseId,
  }) : super(key: key);

  @override
  _CourseUnitsPageState createState() => _CourseUnitsPageState();
}

class _CourseUnitsPageState extends State<CourseUnitsPage>
    with TickerProviderStateMixin {
  int currentSectionIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Section completion status
  Map<int, Map<int, bool>> unitCompletionStatus = {};

  // Define 5 sections with 5 units each
  final List<CourseSection> sections = [
    CourseSection(
      title: "Foundation Skills",
      description: "Master the basic techniques and fundamentals",
      color: Color(0xFF2563EB),
      units: [
        CourseUnit("Warm-Up Readiness", "Learn proper activation techniques", Icons.flash_on),
        CourseUnit("Movement Efficiency", "Master fundamental movements", Icons.fitness_center),
        CourseUnit("Form Consistency", "Perfect your technique", Icons.security),
        CourseUnit("Progressive Load Response", "Understand load progression", Icons.trending_up),
        CourseUnit("Recovery Capacity", "Optimize rest and nutrition", Icons.bedtime),
      ],
    ),
    CourseSection(
      title: "Intermediate Training",
      description: "Build upon foundation with advanced techniques",
      color: Color(0xFF10B981),
      units: [
        CourseUnit("Load Baseline Assessment", "Establish training baselines", Icons.assessment),
        CourseUnit("Incremental Load Challenge", "Progressive overload principles", Icons.add_circle),
        CourseUnit("Fatigue Resistance Test", "Build endurance capacity", Icons.battery_charging_full),
        CourseUnit("Maximum Effort Evaluation", "Peak performance testing", Icons.speed),
        CourseUnit("Load Recovery Monitoring", "Advanced recovery tracking", Icons.monitor_heart),
      ],
    ),
    CourseSection(
      title: "Advanced Performance",
      description: "Elite-level training and performance optimization",
      color: Color(0xFFF59E0B),
      units: [
        CourseUnit("Explosive Power Assessment", "Develop explosive strength", Icons.flash_auto),
        CourseUnit("Dynamic Stability Test", "Advanced balance training", Icons.balance),
        CourseUnit("Advanced Movement Analysis", "Biomechanical optimization", Icons.analytics),
        CourseUnit("Strength Endurance Challenge", "Combined strength training", Icons.fitness_center),
        CourseUnit("Peak Performance Benchmark", "Performance measurement", Icons.emoji_events),
      ],
    ),
    CourseSection(
      title: "Sport-Specific Training",
      description: "Specialized training for competitive performance",
      color: Color(0xFF8B5CF6),
      units: [
        CourseUnit("Sport-Specific Power Test", "Event-specific training", Icons.sports),
        CourseUnit("Functional Strength Analysis", "Real-world applications", Icons.accessibility_new),
        CourseUnit("Targeted Muscle Assessment", "Muscle-specific training", Icons.psychology),
        CourseUnit("Personalized Load Adaptation", "Individual optimization", Icons.person),
        CourseUnit("Specialized Recovery Strategy", "Advanced recovery methods", Icons.spa),
      ],
    ),
    CourseSection(
      title: "Competition Preparation",
      description: "Final preparation for competitive events",
      color: Color(0xFFEF4444),
      units: [
        CourseUnit("Competition Simulation", "Practice under pressure", Icons.timer),
        CourseUnit("Mental Preparation", "Psychological readiness", Icons.psychology),
        CourseUnit("Peak Conditioning", "Final conditioning phase", Icons.trending_up),
        CourseUnit("Strategy Implementation", "Tactical preparation", Icons.sports_kabaddi),
        CourseUnit("Performance Validation", "Final assessment", Icons.verified),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeCompletionStatus();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  void _initializeCompletionStatus() {
    for (int i = 0; i < sections.length; i++) {
      unitCompletionStatus[i] = {};
      for (int j = 0; j < sections[i].units.length; j++) {
        unitCompletionStatus[i]![j] = false;
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF0A0A0A) : Color(0xFFF8FAFE),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(isDarkMode),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProgressOverview(isDarkMode),
                _buildUnitsGrid(isDarkMode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDarkMode) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      stretch: true,
      backgroundColor: isDarkMode ? Color(0xFF1A1A1A) : Color(0xFF2563EB),
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
                      ? [Color(0xFF1A1A1A), Color(0xFF2D2D2D)]
                      : [Color(0xFF2563EB), Color(0xFF3B82F6)],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'TRAINING MODULES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${widget.courseName} Units',
                          style: TextStyle(
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
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<int>(
                          value: currentSectionIndex,
                          dropdownColor: isDarkMode ? Color(0xFF1F1F1F) : Colors.white,
                          underline: SizedBox(),
                          icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
                          items: sections.asMap().entries.map((entry) {
                            int index = entry.key;
                            CourseSection section = entry.value;
                            bool isUnlocked = _isSectionUnlocked(index);
                            return DropdownMenuItem<int>(
                              value: index,
                              child: Row(
                                children: [
                                  Icon(
                                    isUnlocked ? Icons.play_circle_fill : Icons.lock,
                                    color: isUnlocked ? section.color : Colors.grey,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Section ${index + 1}',
                                    style: TextStyle(
                                      color: isUnlocked ? (isDarkMode ? Colors.white : Colors.black87) : Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _selectSection(value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildProgressOverview(bool isDarkMode) {
    double overallProgress = _calculateOverallProgress();
    
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1F1F1F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.school, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'Course Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
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
                    widthFactor: overallProgress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Text(
                '${(overallProgress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '${_getCompletedUnitsCount()} of ${_getTotalUnitsCount()} units completed',
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSelector(bool isDarkMode) {
    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          final isSelected = index == currentSectionIndex;
          final isUnlocked = _isSectionUnlocked(index);
          final isCompleted = _isSectionCompleted(index);

          return GestureDetector(
            onTap: () => _selectSection(index),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.only(right: 12),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: [section.color, section.color.withOpacity(0.8)])
                    : null,
                color: !isSelected
                    ? (isDarkMode ? Color(0xFF1F1F1F) : Colors.white)
                    : null,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.3)),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: section.color.withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isCompleted)
                    Icon(Icons.check_circle, size: 18, color: Colors.white)
                  else if (!isUnlocked)
                    Icon(Icons.lock, size: 18, color: isSelected ? Colors.white : Colors.grey)
                  else
                    Icon(Icons.play_circle_fill, size: 18, color: isSelected ? Colors.white : section.color),
                  SizedBox(width: 8),
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

  Widget _buildUnitsGrid(bool isDarkMode) {
    final currentSection = sections[currentSectionIndex];
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [currentSection.color, currentSection.color.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.list_alt, color: Colors.white, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentSection.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        currentSection.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: currentSection.units.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: _buildUnitCard(currentSection.units[index], index, isDarkMode),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitCard(CourseUnit unit, int index, bool isDarkMode) {
    final section = sections[currentSectionIndex];
    final isUnlocked = _isUnitUnlocked(currentSectionIndex, index);
    final isCompleted = unitCompletionStatus[currentSectionIndex]?[index] ?? false;
    final isInProgress = isUnlocked && !isCompleted;

    Color statusColor = isCompleted
        ? Color(0xFF10B981)
        : isInProgress
            ? section.color
            : Colors.grey;

    return Container(
      decoration: BoxDecoration(
        gradient: isUnlocked
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [Color(0xFF1F1F1F), Color(0xFF2A2A2A)]
                    : [Colors.white, Color(0xFFF8FAFE)],
              )
            : null,
        color: !isUnlocked
            ? (isDarkMode ? Color(0xFF151515) : Colors.grey[100])
            : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isInProgress
              ? statusColor
              : (isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2)),
          width: isInProgress ? 2 : 1,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: statusColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isUnlocked ? () => _openUnit(unit, index) : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(16),
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
                    boxShadow: isUnlocked
                        ? [
                            BoxShadow(
                              color: statusColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    isUnlocked ? unit.icon : Icons.lock,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unit ${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
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
                      SizedBox(height: 4),
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
                SizedBox(width: 16),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        isCompleted
                            ? 'Completed'
                            : isInProgress
                                ? 'In Progress'
                                : 'Locked',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Icon(
                      isCompleted
                          ? Icons.check_circle
                          : isInProgress
                              ? Icons.play_circle_fill
                              : Icons.lock_outline,
                      color: statusColor,
                      size: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods
  bool _isSectionUnlocked(int sectionIndex) {
    if (sectionIndex == 0) return true;
    return _isSectionCompleted(sectionIndex - 1);
  }

  bool _isSectionCompleted(int sectionIndex) {
    final sectionUnits = unitCompletionStatus[sectionIndex];
    if (sectionUnits == null) return false;
    
    for (int i = 0; i < sections[sectionIndex].units.length; i++) {
      if (sectionUnits[i] != true) return false;
    }
    return true;
  }

  bool _isUnitUnlocked(int sectionIndex, int unitIndex) {
    if (sectionIndex == 0 && unitIndex == 0) return true;
    if (unitIndex == 0) {
      return sectionIndex > 0 ? _isSectionCompleted(sectionIndex - 1) : true;
    }
    return unitCompletionStatus[sectionIndex]?[unitIndex - 1] == true;
  }

  double _calculateOverallProgress() {
    int totalUnits = 0;
    int completedUnits = 0;
    
    for (int i = 0; i < sections.length; i++) {
      totalUnits += sections[i].units.length;
      final sectionUnits = unitCompletionStatus[i];
      if (sectionUnits != null) {
        completedUnits += sectionUnits.values.where((completed) => completed).length;
      }
    }
    
    return totalUnits > 0 ? completedUnits / totalUnits : 0.0;
  }

  int _getCompletedUnitsCount() {
    int completedUnits = 0;
    for (int i = 0; i < sections.length; i++) {
      final sectionUnits = unitCompletionStatus[i];
      if (sectionUnits != null) {
        completedUnits += sectionUnits.values.where((completed) => completed).length;
      }
    }
    return completedUnits;
  }

  int _getTotalUnitsCount() {
    return sections.fold(0, (total, section) => total + section.units.length);
  }

  void _selectSection(int index) {
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
    
    _animationController.reset();
    _animationController.forward();
  }

  void _openUnit(CourseUnit unit, int unitIndex) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnitDetailsPage(
          unitName: unit.title,
          unitDescription: unit.description,
          sectionName: sections[currentSectionIndex].title,
          unitIndex: unitIndex,
          sectionIndex: currentSectionIndex,
          totalUnitsInSection: sections[currentSectionIndex].units.length,
          objectives: [
            "Master the fundamental techniques",
            "Understand proper form and execution",
            "Build strength and endurance",
            "Develop muscle memory",
          ],
          dos: [
            "Maintain proper posture throughout",
            "Focus on controlled movements",
            "Breathe naturally during exercises",
            "Listen to your body",
          ],
          donts: [
            "Don't rush through movements",
            "Avoid holding your breath",
            "Don't ignore pain signals",
            "Don't skip warm-up",
          ],
        ),
      ),
    );
    
    if (result == true) {
      setState(() {
        unitCompletionStatus[currentSectionIndex]![unitIndex] = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${unit.title} completed! 🎉'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// Data models
class CourseSection {
  final String title;
  final String description;
  final Color color;
  final List<CourseUnit> units;

  CourseSection({
    required this.title,
    required this.description,
    required this.color,
    required this.units,
  });
}

class CourseUnit {
  final String title;
  final String description;
  final IconData icon;

  CourseUnit(this.title, this.description, this.icon);
}