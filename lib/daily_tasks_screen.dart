import 'dart:ui'; // Needed for ImageFilter
import 'package:flutter/material.dart';
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

// --- PROFESSIONAL UI SCREEN ---
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
  DateTime _selectedDate = DateTime.now();

  // Define a professional color palette
  static const Color _backgroundColor = Color(0xFF0D1117); // GitHub Dark
  static const Color _surfaceColor = Color(0xFF161B22);
  static const Color _primaryColor = Color(0xFF58A6FF);
  static const Color _accentColor = Color(0xFF3FB950); // Green for success

  // Define date range for calendar
  final int _calendarDayRange = 30; // Show 15 days past, 15 days future
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
       benefits: ['Prevents soreness', 'Improves recovery', 'Reduces injury risk'],
       dos: ['Stretch all worked muscles', 'Breathe deeply', 'Take your time'],
       donts: ['Don\'t skip this step', 'Don\'t rush', 'Don\'t stretch cold muscles'],
       tips: ['Hold stretches longer', 'Use foam roller', 'Practice mindfulness']),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pageController = PageController(viewportFraction: 0.85);
    _scrollController = ScrollController();
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
        title: const Text('Daily Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.white),
      ),
      body: SafeArea(
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
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                'You have a ${appState.streakCount} day streak 🔥',
                style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
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
                        backgroundColor: _surfaceColor,
                        valueColor: const AlwaysStoppedAnimation<Color>(_accentColor),
                      ),
                    ),
                    Text(
                      '${(value * 100).toInt()}%',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: SizedBox(
        height: 85,
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: _calendarDayRange,
          itemBuilder: (context, index) {
            final now = DateTime.now();
            final day = now.add(Duration(days: index - _initialDateIndex));
            final isSelected = day.day == _selectedDate.day && day.month == _selectedDate.month;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = day;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isSelected ? 70 : 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isSelected ? _primaryColor : _surfaceColor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEE').format(day).toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: Colors.white.withOpacity(isSelected ? 1.0 : 0.7),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      day.day.toString(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
        return _buildRichTaskCard(task, isLocked);
      },
    );
  }

  Widget _buildRichTaskCard(DailyTask task, bool isLocked) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isLocked ? _surfaceColor.withOpacity(0.5) : _surfaceColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.1))
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    isLocked ? Icons.lock_outline : (task.isCompleted ? Icons.check_circle : task.icon),
                    size: 40,
                    color: isLocked ? Colors.white54 : (task.isCompleted ? _accentColor : _primaryColor),
                  ),
                  if (!isLocked)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: task.isCompleted ? _accentColor.withOpacity(0.1) : _primaryColor.withOpacity(0.1),
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
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                isLocked ? 'Complete the previous task to unlock.' : task.description,
                style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7), height: 1.5),
              ),
              const SizedBox(height: 20),
              if (!isLocked) ...[
                _buildSection('Benefits', task.benefits, Icons.star_border, Colors.amber),
                _buildSection('Do\'s', task.dos, Icons.check, Colors.green),
                _buildSection('Don\'ts', task.donts, Icons.close, Colors.red),
                _buildSection('Tips', task.tips, Icons.lightbulb_outline, Colors.orange),
              ] else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30.0),
                    child: Column(
                      children: [
                        Icon(Icons.lock, size: 60, color: Colors.white.withOpacity(0.3)),
                        const SizedBox(height: 10),
                        Text(
                          'Task Locked',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items, IconData icon, Color color) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      iconColor: color,
      collapsedIconColor: color.withOpacity(0.7),
      title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      children: items.map((item) => ListTile(
        contentPadding: const EdgeInsets.only(left: 4, bottom: 4),
        leading: Icon(icon, size: 20, color: color),
        title: Text(item, style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.8), height: 1.4)),
      )).toList(),
    );
  }

  Widget _buildActionButtons() {
    final task = _tasks[_currentTaskIndex];
    final bool isLocked = _currentTaskIndex > 0 && !_tasks[_currentTaskIndex - 1].isCompleted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: isLocked ? null : () {
              setState(() => task.isCompleted = !task.isCompleted);
              if (task.isCompleted && _currentTaskIndex < _tasks.length - 1) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  _pageController.nextPage(
                    duration: _animationController.duration!,
                    curve: Curves.easeInOut,
                  );
                });
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 55),
              backgroundColor: task.isCompleted ? _accentColor : _primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              disabledBackgroundColor: Colors.grey.shade800,
            ),
            child: Text(
              task.isCompleted ? 'Completed ✓' : (isLocked ? '🔒 Task Locked' : 'Mark as Complete'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: isLocked ? null : _uploadVideo,
            icon: const Icon(Icons.videocam_outlined, size: 22),
            label: const Text('Upload Performance Video'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1.5),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              disabledForegroundColor: Colors.white30,
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
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Row(
        children: [
          _buildSummaryCard(
            icon: Icons.local_fire_department_outlined,
            label: 'Streak',
            value: '${appState.streakCount} Days',
            color: Colors.orangeAccent,
          ),
          const SizedBox(width: 10),
          _buildSummaryCard(
            icon: Icons.check_circle_outline,
            label: 'Tasks Done',
            value: '$completedCount / ${_tasks.length}',
            color: Colors.tealAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({required IconData icon, required String label, required String value, required Color color}) {
    return Expanded(
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }

  // --- Helper Methods ---
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