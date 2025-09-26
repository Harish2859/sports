import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:math'; // Imported for confetti animation
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';

// Mocks for demonstration purposes
import 'app_state.dart';
import 'theme_provider.dart';


class AchievementsPage extends StatefulWidget {
  @override
  _AchievementsPageState createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage>
    with TickerProviderStateMixin {
  // REFINED: Combined animations for a more fluid effect
  late AnimationController _animationController;
  late ConfettiController _confettiController;

  // REFINED: A single sorted list of badges for logical progression
  final List<Map<String, dynamic>> badges = [
    {'name': 'First Steps', 'image': 'beginner.png', 'requiredXP': 10, 'description': 'Complete your first task', 'color': Colors.green},
    {'name': 'Rising Star', 'image': 'blue.png', 'requiredXP': 50, 'description': 'Earn 50 XP points', 'color': Colors.blue},
    {'name': 'Champion', 'image': 'champ.png', 'requiredXP': 100, 'description': 'Reach 100 XP milestone', 'color': Colors.purple},
    {'name': 'Elite Player', 'image': 'silver.png', 'requiredXP': 200, 'description': 'Join the elite ranks', 'color': Colors.grey[400]!},
    {'name': 'Intermediate', 'image': 'intermediate.png', 'requiredXP': 300, 'description': 'Intermediate skill level', 'color': Colors.orange},
    {'name': 'Diamond Master', 'image': 'dimond.png', 'requiredXP': 500, 'description': 'Master level achievement', 'color': Colors.cyan},
    {'name': 'Pro Level', 'image': 'white.png', 'requiredXP': 750, 'description': 'Professional achievement', 'color': Colors.indigo},
    {'name': 'Ruby Legend', 'image': 'ruby.png', 'requiredXP': 1000, 'description': 'Legendary status unlocked', 'color': Colors.red},
  ]..sort((a, b) => a['requiredXP'].compareTo(b['requiredXP'])); // IMPORTANT: Sort the list

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }
  
  // NEW: Refactored logic to be cleaner
  int _getUnlockedBadgesCount(int totalXP) {
    return badges.where((badge) => totalXP >= badge['requiredXP']).length;
  }
  
  Map<String, dynamic>? _getNextBadge(int totalXP) {
    try {
      return badges.firstWhere((badge) => totalXP < badge['requiredXP']);
    } catch (e) {
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final appState = Provider.of<AppState>(context); // Using Provider for AppState
    final int totalXP = appState.totalXP;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF121212) : Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Achievements',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // NEW: The dynamic progress header
          _buildProgressHeader(totalXP, badges.length, isDarkMode),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.8,
              ),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                final badge = badges[index];
                final isUnlocked = totalXP >= badge['requiredXP'];
                double progress = 0;
                if (!isUnlocked) {
                  int previousBadgeXP = index > 0 ? badges[index - 1]['requiredXP'] : 0;
                  int requiredForThis = badge['requiredXP'] - previousBadgeXP;
                  int earnedForThis = totalXP - previousBadgeXP;
                  progress = (earnedForThis / requiredForThis).clamp(0.0, 1.0);
                }
                return _buildEnhancedBadge(badge, isUnlocked, isDarkMode, progress);
              },
            ),
          ),
        ],
      ),
    );
  }

  // REFINED: Progress header is now much more informative
  Widget _buildProgressHeader(int totalXP, int totalBadges, bool isDarkMode) {
    final unlockedCount = _getUnlockedBadgesCount(totalXP);
    final nextBadge = _getNextBadge(totalXP);
    double progressToNext = 0;
    int requiredForNext = 0;
    
    if (nextBadge != null) {
      int previousBadgeXP = 0;
      try {
        previousBadgeXP = badges.lastWhere((b) => totalXP >= b['requiredXP'])['requiredXP'];
      } catch (e) {
        previousBadgeXP = 0;
      }
      requiredForNext = nextBadge['requiredXP'] - previousBadgeXP;
      final currentProgress = totalXP - previousBadgeXP;
      progressToNext = (currentProgress / requiredForNext).clamp(0.0, 1.0);
    } else {
      progressToNext = 1; // All badges unlocked
    }

    return Container(
      margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode 
            ? [Color(0xFF2A2D3E), Color(0xFF35374B)]
            : [Colors.deepPurple, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Progress',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '$totalXP XP',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber, size: 24),
              SizedBox(width: 8),
              Text(
                '$unlockedCount of $totalBadges Unlocked',
                style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 15),
          if (nextBadge != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progressToNext,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: 8,
              ),
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Next: ${nextBadge['name']} (${totalXP}/${nextBadge['requiredXP']})',
                style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 12),
              ),
            ),
          ]
        ],
      ),
    );
  }

  // REFINED: The main badge card widget with enhanced UI and animations
  Widget _buildEnhancedBadge(Map<String, dynamic> badge, bool isUnlocked, bool isDarkMode, double progress) {
    final badgeColor = badge['color'] as Color;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final rotationValue = sin(_animationController.value * 2 * pi) * 0.05;
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(isUnlocked ? rotationValue : 0),
          alignment: FractionalOffset.center,
          child: GestureDetector(
            onTap: () {
              if (isUnlocked) _confettiController.play();
              _showBadgeDetail(badge, isUnlocked, isDarkMode);
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isUnlocked
                    ? [badgeColor.withOpacity(isDarkMode ? 0.3 : 0.5), badgeColor.withOpacity(isDarkMode ? 0.1 : 0.2)]
                    : [Colors.grey[800]!.withOpacity(0.3), Colors.grey[900]!.withOpacity(0.4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isUnlocked ? badgeColor.withOpacity(0.5) : Colors.grey[700]!,
                  width: 1.5,
                ),
                boxShadow: isUnlocked
                    ? [
                        BoxShadow(
                          color: badgeColor.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: Offset(0, 8),
                        )
                      ]
                    : [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildBadgeIcon(badge, isUnlocked, isDarkMode),
                        Text(
                          badge['name'],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: isUnlocked ? (isDarkMode ? Colors.white : Colors.black87) : Colors.grey[400],
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if (!isUnlocked)
                          Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.grey.withOpacity(0.3),
                                  valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${badge['requiredXP']} XP',
                                style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 12),
                              ),
                            ],
                          )
                        else
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('UNLOCKED', style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // REFINED: Badge icon with a breathing animation
  Widget _buildBadgeIcon(Map<String, dynamic> badge, bool isUnlocked, bool isDarkMode) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final scaleValue = 1.0 + sin(_animationController.value * 2 * pi) * 0.05;
        return Transform.scale(
          scale: scaleValue,
          child: Container(
            width: 70,
            height: 70,
            child: isUnlocked
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: Image.asset(
                      'assets/images/${badge['image']}',
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.emoji_events, color: badge['color'], size: 40),
                    ),
                  )
                : Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(35),
                    ),
                    child: Icon(Icons.lock, color: Colors.grey[400], size: 35),
                  ),
          ),
        );
      },
    );
  }

  // REFINED: The detail dialog is now a celebration!
  void _showBadgeDetail(Map<String, dynamic> badge, bool isUnlocked, bool isDarkMode) {
    final badgeColor = badge['color'] as Color;

    showDialog(
      context: context,
      builder: (context) => Stack(
        alignment: Alignment.topCenter,
        children: [
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
            contentPadding: EdgeInsets.zero,
            content: Container(
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isUnlocked
                          ? [badgeColor.withOpacity(0.8), badgeColor]
                          : [Colors.grey[700]!, Colors.grey[800]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isUnlocked ? badgeColor : Colors.black).withOpacity(0.4),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: isUnlocked
                      ? Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Image.asset(
                            'assets/images/${badge['image']}',
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.emoji_events, color: Colors.white, size: 60),
                          ),
                        )
                      : Icon(Icons.lock, color: Colors.white, size: 60),
                  ),
                  SizedBox(height: 25),
                  Text(
                    badge['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? badgeColor : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    badge['description'],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 24),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUnlocked ? badgeColor : Colors.grey[500],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      isUnlocked ? 'EARNED' : 'Requires ${badge['requiredXP']} XP',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            numberOfParticles: 20,
            gravity: 0.1,
            colors: const [
              Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple
            ],
          ),
        ],
      ),
    );
  }
}