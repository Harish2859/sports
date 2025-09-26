import 'dart:ui'; // Needed for ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'app_state.dart';
import 'simple_video_recorder.dart';

// --- DATA CLASS (No changes needed here) ---
class DailyTask {
  final String name;
  final String description;
  final IconData icon;
  final List<String> benefits;
  final List<String> dos;
  final List<String> donts;
  final List<String> tips;
  bool isCompleted;

  DailyTask({
    required this.name,
    required this.description,
    required this.icon,
    required this.benefits,
    required this.dos,
    required this.donts,
    required this.tips,
    this.isCompleted = false,
  });
}

// --- PROFESSIONAL UI SCREEN (ENHANCED) ---
class DailyTasksScreen extends StatefulWidget {
  const DailyTasksScreen({super.key});

  @override
  State<DailyTasksScreen> createState() => _DailyTasksScreenState();
}

class _DailyTasksScreenState extends State<DailyTasksScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late PageController _pageController;
  late ScrollController _scrollController;

  int _currentTaskIndex = 0;
  double _currentPageValue = 0.0; // ENHANCED: For 3D card effect
  DateTime _selectedDate = DateTime.now();

  // ENHANCED: Refined color palette for a richer look
  static const Color _backgroundColor = Color(0xFFF8F9FA);
  static const Color _surfaceColor = Color(0xFFFFFFFF);
  static const Color _primaryColor = Color(0xFF007BFF);
  static const Color _accentColor = Color(0xFF28A745);
  static const Color _textColor = Color(0xFF343A40);
  static const Color _subtleTextColor = Color(0xFF6C757D);

  // Define date range for calendar
  final int _calendarDayRange = 31; // Show 15 days past, today, 15 days future
  final int _initialDateIndex = 15;

  final List<DailyTask> _tasks = [
      DailyTask(
        name: 'Morning Warm-up',
        description: 'Start your day with light stretching and breathing exercises.',
        icon: Icons.wb_sunny_outlined,
        benefits: ['Improves flexibility', 'Boosts energy', 'Reduces stress'],
        dos: ['Hold stretches for 15-30 seconds', 'Breathe deeply', 'Start slowly'],
        donts: ['Don\'t bounce while stretching', 'Don\'t hold your breath', 'Don\'t overstretch'],
        tips: ['Use a yoga mat', 'Play calming music', 'Focus on major muscle groups']),
      DailyTask(
        name: 'Cardio Workout',
        description: '20-minute cardiovascular exercise to boost heart health.',
        icon: Icons.favorite_border,
        benefits: ['Strengthens heart', 'Burns calories', 'Improves endurance'],
        dos: ['Maintain steady pace', 'Stay hydrated', 'Monitor heart rate'],
        donts: ['Don\'t skip warm-up', 'Don\'t overexert', 'Don\'t ignore pain'],
        tips: ['Choose activities you enjoy', 'Track your progress', 'Mix different exercises']),
      DailyTask(
        name: 'Strength Training',
        description: 'Build muscle strength with bodyweight or weight exercises.',
        icon: Icons.fitness_center_outlined,
        benefits: ['Builds muscle', 'Increases metabolism', 'Strengthens bones'],
        dos: ['Use proper form', 'Rest between sets', 'Progress gradually'],
        donts: ['Don\'t lift too heavy too soon', 'Don\'t skip rest days', 'Don\'t ignore form'],
        tips: ['Start with bodyweight', 'Focus on compound movements', 'Get adequate protein']),
      DailyTask(
        name: 'Cool Down',
        description: 'End your workout with gentle stretching and relaxation.',
        icon: Icons.self_improvement_outlined,
        benefits: ['Prevents soreness', 'Improoves recovery', 'Reduces injury risk'],
        dos: ['Stretch all worked muscles', 'Breathe deeply', 'Take your time'],
        donts: ['Don\'t skip this step', 'Don\'t rush', 'Don\'t stretch cold muscles'],
        tips: ['Hold stretches longer', 'Use foam roller', 'Practice mindfulness']),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pageController = PageController(viewportFraction: 0.85)
      ..addListener(() { // ENHANCED: Listener for 3D card effect
        setState(() {
          _currentPageValue = _pageController.page!;
        });
      });
    _scrollController = ScrollController();

    // ENHANCED: Scroll calendar to today's date after the first frame is built
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final double initialOffset = _initialDateIndex * 64.0 - (MediaQuery.of(context).size.width / 2) + 32;
      _scrollController.jumpTo(initialOffset);
    });

    _animationController.forward(); // ENHANCED: Start fade-in animation
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        title: const Text('Daily Plan', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: _textColor),
      ),
      body: SafeArea(
        // ENHANCED: Fade in the entire screen content for a smooth entry
        child: FadeTransition(
          opacity: _animationController,
          child: Column(
            children: [
              _buildTopHeader(),
              _buildCalendarView(),
              Expanded(child: _buildSwipeableTaskView()),
              _buildActionButtons(),
              _buildBottomSummaryCards(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    final appState = Provider.of<AppState>(context);
    final completedCount = _tasks.where((task) => task.isCompleted).length;
    final progress = _tasks.isEmpty ? 0.0 : completedCount / _tasks.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hello John!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _textColor),
              ),
              const SizedBox(height: 4),
              Text(
                'You have a ${appState.streakCount} day streak 🔥',
                style: const TextStyle(fontSize: 16, color: _subtleTextColor),
              ),
            ],
          ),
          SizedBox(
            width: 60,
            height: 60,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 5,
                        backgroundColor: Colors.grey.shade200, // ENHANCED: Better background color
                        valueColor: const AlwaysStoppedAnimation<Color>(_accentColor),
                      ),
                    ),
                    Text(
                      '${(value * 100).toInt()}%',
                      style: const TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    // ENHANCED: UI for the calendar slider
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: SizedBox(
        height: 90, // Increased height for better look
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: _calendarDayRange,
          itemBuilder: (context, index) {
            final now = DateTime.now();
            final day = now.add(Duration(days: index - _initialDateIndex));
            final isSelected = day.day == _selectedDate.day &&
                day.month == _selectedDate.month &&
                day.year == _selectedDate.year;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = day;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  // ENHANCED: Gradient and shadow for selected item
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF007BFF), Color(0xFF0056B3)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : _surfaceColor,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _primaryColor.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEE').format(day).toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white70 : _subtleTextColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      day.day.toString(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : _textColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSwipeableTaskView() {
    return PageView.builder(
      controller: _pageController,
      itemCount: _tasks.length,
      onPageChanged: (index) {
        setState(() {
          _currentTaskIndex = index;
        });
      },
      itemBuilder: (context, index) {
        final task = _tasks[index];
        final bool isLocked = index > 0 && !_tasks[index - 1].isCompleted;

        // ENHANCED: 3D scaling effect for cards
        Matrix4 matrix = Matrix4.identity();
        double scale;
        if (index == _currentPageValue.floor()) {
          scale = 1 - (_currentPageValue - index) * 0.15;
        } else if (index == _currentPageValue.floor() + 1) {
          scale = 0.85 + (_currentPageValue - index + 1) * 0.15;
        } else {
          scale = 0.85;
        }
        matrix.setEntry(3, 2, 0.001); // Perspective
        matrix.scale(scale);

        return Transform(
          transform: matrix,
          alignment: Alignment.center,
          child: _buildRichTaskCard(task, isLocked),
        );
      },
    );
  }

  Widget _buildRichTaskCard(DailyTask task, bool isLocked) {
    // ENHANCED: UI for the task card
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack( // Use Stack to overlay the blur effect when locked
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        task.isCompleted ? Icons.check_circle : task.icon,
                        size: 40,
                        color: task.isCompleted ? _accentColor : _primaryColor,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: task.isCompleted
                              ? _accentColor.withOpacity(0.1)
                              : _primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          task.isCompleted ? 'Completed' : 'Active',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: task.isCompleted ? _accentColor : _primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    task.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _textColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    task.description,
                    style: const TextStyle(fontSize: 16, color: _subtleTextColor, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.black12, thickness: 1),
                  _buildCombinedSection(task),
                ],
              ),
            ),
            // ENHANCED: Frosted glass lock effect
            if (isLocked)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline, size: 60, color: _textColor.withOpacity(0.7)),
                        const SizedBox(height: 10),
                        const Text(
                          'Task Locked',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              color: _textColor,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Complete previous task to unlock',
                          style: TextStyle(fontSize: 14, color: _subtleTextColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCombinedSection(DailyTask task) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      iconColor: _primaryColor,
      collapsedIconColor: _primaryColor.withOpacity(0.7),
      title: const Text('Task Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textColor)),
      children: [
        _buildSubSection('Benefits', task.benefits, Icons.star_border, Colors.amber.shade700),
        _buildSubSection('Do\'s', task.dos, Icons.check_circle_outline, Colors.green),
        _buildSubSection('Don\'ts', task.donts, Icons.highlight_off, Colors.red),
        _buildSubSection('Tips', task.tips, Icons.lightbulb_outline, Colors.orange),
      ],
    );
  }

  Widget _buildSubSection(String title, List<String> items, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textColor)),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(left: 26, bottom: 4),
            child: Text('• $item', style: const TextStyle(fontSize: 14, color: _subtleTextColor, height: 1.4)),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final task = _tasks[_currentTaskIndex];
    final bool isLocked = _currentTaskIndex > 0 && !_tasks[_currentTaskIndex - 1].isCompleted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // ENHANCED: Button with gradient and better styling
          ElevatedButton.icon(
            onPressed: isLocked ? null : () {
              setState(() => task.isCompleted = !task.isCompleted);
              if (task.isCompleted && _currentTaskIndex < _tasks.length - 1) {
                Future.delayed(const Duration(milliseconds: 300), () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                });
              }
            },
            icon: Icon(task.isCompleted ? Icons.check_circle_outline : Icons.check, size: 22),
            label: Text(
              task.isCompleted ? 'Completed!' : 'Mark as Complete',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 55),
              foregroundColor: Colors.white,
              backgroundColor: isLocked ? Colors.grey.shade400 : (task.isCompleted ? _accentColor : _primaryColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 4,
              shadowColor: isLocked ? Colors.transparent : _primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: isLocked ? null : _uploadVideo,
            icon: const Icon(Icons.videocam_outlined, size: 22),
            label: const Text('Upload Performance Video'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _textColor,
              side: BorderSide(color: Colors.grey.shade300, width: 1.5),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              disabledForegroundColor: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummaryCards() {
    final appState = Provider.of<AppState>(context);
    final completedCount = _tasks.where((task) => task.isCompleted).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Row(
        children: [
          _buildSummaryCard(
            icon: Icons.local_fire_department_outlined,
            label: 'Streak',
            value: '${appState.streakCount} Days',
            color: Colors.orange,
          ),
          const SizedBox(width: 15),
          _buildSummaryCard(
            icon: Icons.check_circle_outline,
            label: 'Tasks Done',
            value: '$completedCount / ${_tasks.length}',
            color: Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({required IconData icon, required String label, required String value, required Color color}) {
    // ENHANCED: UI for summary cards
    return Expanded(
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textColor)),
                const SizedBox(height: 4),
                Text(label, style: const TextStyle(fontSize: 12, color: _subtleTextColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Methods (No changes needed) ---
  void _uploadVideo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SimpleVideoRecorder()),
    );
  }

  void _submitTasks() {
    final completedTasks = _tasks.where((task) => task.isCompleted).length;
    if (completedTasks > 0) {
      Provider.of<AppState>(context, listen: false).updateStreak();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$completedTasks tasks completed! Streak updated!'),
          backgroundColor: _accentColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete at least one task'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}