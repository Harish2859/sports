import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'simple_video_recorder.dart';
import 'package:intl/intl.dart'; // For date formatting

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

class DailyTasksScreen extends StatefulWidget {
  const DailyTasksScreen({super.key});

  @override
  State<DailyTasksScreen> createState() => _DailyTasksScreenState();
}

class _DailyTasksScreenState extends State<DailyTasksScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late PageController _pageController; // For new swipeable task view
  bool _isAnimating = false;
  int _currentTaskIndex = 0; // Renamed for clarity
  DateTime _selectedDate = DateTime.now(); // For calendar interaction

  final List<DailyTask> _tasks = [
    DailyTask(
      name: 'Morning Warm-up',
      description: 'Start your day with light stretching and breathing exercises',
      icon: Icons.wb_sunny,
      benefits: ['Improves flexibility', 'Boosts energy', 'Reduces stress'],
      dos: ['Hold stretches for 15-30 seconds', 'Breathe deeply', 'Start slowly'],
      donts: ['Don\'t bounce while stretching', 'Don\'t hold your breath', 'Don\'t overstretch'],
      tips: ['Use a yoga mat', 'Play calming music', 'Focus on major muscle groups'],
    ),
    DailyTask(
      name: 'Cardio Workout',
      description: '20-minute cardiovascular exercise to boost heart health',
      icon: Icons.favorite,
      benefits: ['Strengthens heart', 'Burns calories', 'Improves endurance'],
      dos: ['Maintain steady pace', 'Stay hydrated', 'Monitor heart rate'],
      donts: ['Don\'t skip warm-up', 'Don\'t overexert', 'Don\'t ignore pain'],
      tips: ['Choose activities you enjoy', 'Track your progress', 'Mix different exercises'],
    ),
    DailyTask(
      name: 'Strength Training',
      description: 'Build muscle strength with bodyweight or weight exercises',
      icon: Icons.fitness_center,
      benefits: ['Builds muscle', 'Increases metabolism', 'Strengthens bones'],
      dos: ['Use proper form', 'Rest between sets', 'Progress gradually'],
      donts: ['Don\'t lift too heavy too soon', 'Don\'t skip rest days', 'Don\'t ignore form'],
      tips: ['Start with bodyweight', 'Focus on compound movements', 'Get adequate protein'],
    ),
    DailyTask(
      name: 'Cool Down',
      description: 'End your workout with gentle stretching and relaxation',
      icon: Icons.self_improvement,
      benefits: ['Prevents soreness', 'Improves recovery', 'Reduces injury risk'],
      dos: ['Stretch all worked muscles', 'Breathe deeply', 'Take your time'],
      donts: ['Don\'t skip this step', 'Don\'t rush', 'Don\'t stretch cold muscles'],
      tips: ['Hold stretches longer', 'Use foam roller', 'Practice mindfulness'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400), // Slightly longer animation
      vsync: this,
    );
    _pageController = PageController(viewportFraction: 0.9); // Make tasks slightly off-center
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // --- UI Build Methods ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tasks'),
        backgroundColor: Colors.blue.shade700, // Darker blue
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildTopHeader(),           // New: Hello, Streak, Avatar
          _buildCalendarView(),       // New: Interactive horizontal calendar
          Expanded(
            child: _buildSwipeableTaskView(), // Enhanced swipeable tasks
          ),
          _buildActionButtons(),      // Mark Complete, Upload Video
          _buildBottomSummaryCards(), // New: Streak, Total Tasks, etc.
        ],
      ),
    );
  }

  // --- NEW / ENHANCED WIDGETS ---

  Widget _buildTopHeader() {
    final appState = Provider.of<AppState>(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor, // Use app primary color
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hello John!', // Replace with actual user name
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You have ${appState.streakCount} days streak 🔥', // Dynamic streak
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.person, color: Colors.white), // Placeholder avatar
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    // This is a simplified calendar. A full implementation would involve
    // a more complex widget to display multiple days and handle selection.
    // Inspired by Image 6, Image 5.
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final day = DateTime.now().subtract(Duration(days: 3 - index));
          final isToday = day.day == DateTime.now().day && day.month == DateTime.now().month && day.year == DateTime.now().year;
          // Example: Check if all tasks were completed on this day (requires historical data)
          final bool allTasksCompletedForDay = (index == 3 && _tasks.every((t) => t.isCompleted)); // Placeholder logic for today

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = day;
                // In a real app, this would trigger loading tasks for _selectedDate
              });
            },
            child: Column(
              children: [
                Text(
                  DateFormat('EEE').format(day), // Mon, Tue, Wed
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isToday ? Theme.of(context).primaryColor : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isToday ? Theme.of(context).primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isToday ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                if (allTasksCompletedForDay) // Visual indicator for completion
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSwipeableTaskView() {
    // Using PageView for a smoother swipe experience for the main task cards.
    // Each page will contain a single task's details and actions.
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
        
        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            double value = 1.0;
            if (_pageController.position.haveDimensions) {
              value = (_pageController.page ?? 0) - index;
              value = (1 - (value.abs() * 0.3)).clamp(0.8, 1.0); // Scale effect for non-active cards
            }
            return Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5 * value, // Dynamic height based on scale
                width: MediaQuery.of(context).size.width * 0.8 * value,
                child: Transform.scale(
                  scale: value,
                  child: _buildRichTaskCard(task, isLocked),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRichTaskCard(DailyTask task, bool isLocked) {
    // This replaces _buildTaskCard and _buildTaskDetails
    Color cardColor = isLocked ? Colors.grey.shade800 : (task.isCompleted ? Colors.green.shade50 : Colors.white);
    Color iconColor = isLocked ? Colors.white70 : (task.isCompleted ? Colors.green : Theme.of(context).primaryColor);
    Color textColor = isLocked ? Colors.white70 : Colors.black87;
    Color subtextColor = isLocked ? Colors.white54 : Colors.grey.shade600;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: isLocked ? Colors.black.withOpacity(0.3) : Colors.blue.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  task.isCompleted
                      ? Icons.check_circle
                      : isLocked
                          ? Icons.lock
                          : task.icon,
                  size: 40,
                  color: iconColor,
                ),
                if (!isLocked) // Only show completion status for unlocked tasks
                  Text(
                    task.isCompleted ? 'Completed!' : 'Active',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: task.isCompleted ? Colors.green : Theme.of(context).primaryColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              task.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              isLocked ? 'Complete previous task to unlock' : task.description,
              style: TextStyle(
                fontSize: 15,
                color: subtextColor,
              ),
            ),
            const SizedBox(height: 20),
            if (!isLocked) ...[ // Only show details if not locked
              _buildSection('Benefits', task.benefits, Colors.green),
              const SizedBox(height: 15),
              _buildSection('Do\'s', task.dos, Colors.blue),
              const SizedBox(height: 15),
              _buildSection('Don\'ts', task.donts, Colors.red),
              const SizedBox(height: 15),
              _buildSection('Tips', task.tips, Colors.orange),
            ] else ...[ // Show a locked message if locked
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.lock_outline, size: 60, color: Colors.white38),
                    const SizedBox(height: 10),
                    Text(
                      'This task is locked. Complete the previous task to unlock it.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white54),
                    ),
                  ],
                ),
              )
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6, right: 8),
                width: 4,
                height: 4,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildActionButtons() {
    final task = _tasks[_currentTaskIndex];
    final bool isLocked = _currentTaskIndex > 0 && !_tasks[_currentTaskIndex - 1].isCompleted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: isLocked ? null : () {
              setState(() {
                task.isCompleted = !task.isCompleted;
              });
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
              backgroundColor: task.isCompleted
                  ? Colors.green.shade600
                  : isLocked
                      ? Colors.grey.shade400
                      : Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 5,
            ),
            child: Text(
              task.isCompleted
                  ? 'Completed ✓'
                  : isLocked
                      ? '🔒 Complete Previous Task'
                      : 'Mark Complete',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: isLocked ? null : _uploadVideo, // Upload video only if not locked
            icon: const Icon(Icons.videocam, size: 20),
            label: const Text('Upload Performance Video'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
              side: BorderSide(color: Theme.of(context).primaryColor),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummaryCards() {
    final appState = Provider.of<AppState>(context);
    final completedCount = _tasks.where((task) => task.isCompleted).length;
    final totalTasks = _tasks.length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryCard(
            icon: Icons.local_fire_department,
            label: 'Current Streak',
            value: '${appState.streakCount} Days',
            color: Colors.orange.shade700,
          ),
          _buildSummaryCard(
            icon: Icons.check_circle_outline,
            label: 'Tasks Done Today',
            value: '$completedCount / $totalTasks',
            color: Colors.teal.shade700,
          ),
          _buildSubmitButton(), // Submit button as a summary card
        ],
      ),
    );
  }

  Widget _buildSummaryCard({required IconData icon, required String label, required String value, required Color color}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: ElevatedButton(
          onPressed: _submitTasks,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 90), // Make it a bit larger
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.send_rounded, size: 28),
              SizedBox(height: 5),
              Text('Submit Tasks', textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }


  // --- Helper Methods (unchanged or slightly adjusted) ---
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
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating, // More modern snackbar
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

