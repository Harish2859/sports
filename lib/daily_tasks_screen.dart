import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'simple_video_recorder.dart';

class DailyTasksScreen extends StatefulWidget {
  const DailyTasksScreen({super.key});

  @override
  State<DailyTasksScreen> createState() => _DailyTasksScreenState();
}

class _DailyTasksScreenState extends State<DailyTasksScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isAnimating = false;
  int _currentTask = 0;

  final List<DailyTask> _tasks = [
    DailyTask(
      name: 'Push-ups',
      description: '20 reps',
      icon: Icons.fitness_center,
      isCompleted: false,
      dos: ['Keep body straight', 'Control the movement', 'Breathe properly'],
      donts: ['Don\'t arch your back', 'Don\'t rush the reps', 'Don\'t hold breath'],
      tips: ['Start with knee push-ups if needed', 'Focus on form over speed'],
      benefits: ['Builds chest muscles', 'Strengthens core', 'Improves upper body strength'],
    ),
    DailyTask(
      name: 'Running',
      description: '10 minutes',
      icon: Icons.directions_run,
      isCompleted: false,
      dos: ['Warm up first', 'Land on midfoot', 'Keep posture upright'],
      donts: ['Don\'t overstride', 'Don\'t ignore pain', 'Don\'t skip cool down'],
      tips: ['Start slow and build pace', 'Stay hydrated'],
      benefits: ['Improves cardiovascular health', 'Burns calories', 'Boosts mood'],
    ),
    DailyTask(
      name: 'Stretching',
      description: '5 minutes',
      icon: Icons.accessibility_new,
      isCompleted: false,
      dos: ['Hold stretches 15-30 seconds', 'Breathe deeply', 'Stretch both sides'],
      donts: ['Don\'t bounce', 'Don\'t force stretches', 'Don\'t hold breath'],
      tips: ['Stretch after warming up', 'Focus on tight areas'],
      benefits: ['Improves flexibility', 'Reduces injury risk', 'Relieves tension'],
    ),
    DailyTask(
      name: 'Squats',
      description: '15 reps',
      icon: Icons.sports_gymnastics,
      isCompleted: false,
      dos: ['Keep knees behind toes', 'Lower to 90 degrees', 'Keep chest up'],
      donts: ['Don\'t lean forward', 'Don\'t let knees cave in', 'Don\'t rush'],
      tips: ['Start with bodyweight', 'Focus on depth'],
      benefits: ['Strengthens legs', 'Improves mobility', 'Burns calories'],
    ),
    DailyTask(
      name: 'Plank',
      description: '1 minute',
      icon: Icons.timer,
      isCompleted: false,
      dos: ['Keep body straight', 'Engage core', 'Breathe normally'],
      donts: ['Don\'t sag hips', 'Don\'t raise hips too high', 'Don\'t hold breath'],
      tips: ['Start with shorter holds', 'Focus on form'],
      benefits: ['Strengthens core', 'Improves posture', 'Builds endurance'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tasks'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(child: _buildSwipeableTaskCards()),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildSwipeableTaskCards() {
    return Column(
      children: [
        _buildTaskHeader(),
        Expanded(
          child: Row(
            children: [
              Expanded(flex: 50, child: _buildTaskDetails()),
              Expanded(flex: 50, child: _buildTaskStack()),
            ],
          ),
        ),
        _buildTaskActions(),
        _buildPageIndicator(),
      ],
    );
  }

  Widget _buildTaskHeader() {
    final task = _tasks[_currentTask];
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animationController.value * 50, 0),
          child: Opacity(
            opacity: 1 - _animationController.value,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Task ${_currentTask + 1} of ${_tasks.length}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    task.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    task.description,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskDetails() {
    final task = _tasks[_currentTask];
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(-_animationController.value * 30, 0),
          child: Opacity(
            opacity: 1 - _animationController.value,
            child: Container(
              margin: const EdgeInsets.only(left: 16, right: 8),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('Benefits', task.benefits, Colors.green),
                    const SizedBox(height: 16),
                    _buildSection('Do\'s', task.dos, Colors.blue),
                    const SizedBox(height: 16),
                    _buildSection('Don\'ts', task.donts, Colors.red),
                    const SizedBox(height: 16),
                    _buildSection('Tips', task.tips, Colors.orange),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildTaskStack() {
    return GestureDetector(
      onPanUpdate: (details) {
        if (!_isAnimating && details.delta.dx < -10) {
          _nextTask();
        }
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Current card (tall)
            Container(
              width: 120,
              height: 170,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildTaskCard(_tasks[_currentTask], 120, 170, true),
            ),
            // Upcoming card (short)
            Container(
              width: 80,
              height: 120,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildTaskCard(_tasks[(_currentTask + 1) % _tasks.length], 80, 120, false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(DailyTask task, double width, double height, bool isCurrent) {
    final taskIndex = _tasks.indexOf(task);
    final isLocked = taskIndex > 0 && !_tasks[taskIndex - 1].isCompleted;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: task.isCompleted 
            ? Colors.green.withOpacity(0.1) 
            : isLocked 
                ? Colors.black87 
                : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.isCompleted 
              ? Colors.green 
              : isLocked 
                  ? Colors.black 
                  : Colors.grey.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            task.isCompleted 
                ? Icons.check_circle 
                : isLocked 
                    ? Icons.lock 
                    : task.icon,
            size: isCurrent ? 48 : 32,
            color: task.isCompleted 
                ? Colors.green 
                : isLocked 
                    ? Colors.white70 
                    : Colors.blue,
          ),
          const SizedBox(height: 8),
          Text(
            task.name,
            style: TextStyle(
              fontSize: isCurrent ? 14 : 12,
              fontWeight: FontWeight.bold,
              color: isLocked ? Colors.white70 : null,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            isLocked ? 'Locked' : task.description,
            style: TextStyle(
              fontSize: isCurrent ? 12 : 10,
              color: isLocked ? Colors.white54 : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskActions() {
    final task = _tasks[_currentTask];
    final isLocked = _currentTask > 0 && !_tasks[_currentTask - 1].isCompleted;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1 - (_animationController.value * 0.1),
          child: Opacity(
            opacity: 1 - _animationController.value,
            child: Container(
              margin: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: isLocked ? null : () {
                  setState(() {
                    task.isCompleted = !task.isCompleted;
                  });
                  if (task.isCompleted && _currentTask < _tasks.length - 1) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      _nextTask();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: task.isCompleted 
                      ? Colors.green 
                      : isLocked 
                          ? Colors.black54 
                          : Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: Text(
                  task.isCompleted 
                      ? 'Completed ✓' 
                      : isLocked 
                          ? '🔒 Complete Previous Task' 
                          : 'Mark Complete',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_tasks.length, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: _currentTask == index ? Colors.blue : Colors.grey,
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: _uploadVideo,
            icon: const Icon(Icons.videocam),
            label: const Text('Upload Performance Video'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _submitTasks,
            child: const Text('Submit Daily Tasks'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  void _nextTask() {
    if (!_isAnimating) {
      _isAnimating = true;
      setState(() {
        _currentTask = (_currentTask + 1) % _tasks.length;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        _isAnimating = false;
      });
    }
  }

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
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete at least one task'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class DailyTask {
  final String name;
  final String description;
  final IconData icon;
  bool isCompleted;
  final List<String> dos;
  final List<String> donts;
  final List<String> tips;
  final List<String> benefits;

  DailyTask({
    required this.name,
    required this.description,
    required this.icon,
    required this.isCompleted,
    required this.dos,
    required this.donts,
    required this.tips,
    required this.benefits,
  });
}