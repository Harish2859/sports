import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'theme_provider.dart';

class PerformanceSummaryPage extends StatefulWidget {
  final String unitName;
  final int unitIndex;
  final int sectionIndex;
  final int totalUnitsInSection;
  final bool hasMalpractice;

  const PerformanceSummaryPage({
    Key? key,
    required this.unitName,
    required this.unitIndex,
    required this.sectionIndex,
    required this.totalUnitsInSection,
    required this.hasMalpractice,
  }) : super(key: key);

  @override
  _PerformanceSummaryPageState createState() => _PerformanceSummaryPageState();
}

class _PerformanceSummaryPageState extends State<PerformanceSummaryPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _xpClaimed = false;
  int _xpEarned = 0;
  String _performanceLevel = '';
  int _performancePercentage = 0;
  String _completionTime = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _generatePerformanceData();
    _animationController.forward();
  }

  void _generatePerformanceData() {
    if (widget.hasMalpractice) {
      _xpEarned = 50;
      _performanceLevel = 'Good';
      _performancePercentage = 65;
      _completionTime = '18:45';
    } else {
      _xpEarned = 100;
      _performanceLevel = 'Excellent';
      _performancePercentage = 92;
      _completionTime = '12:30';
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
      backgroundColor: isDarkMode ? Colors.grey[900] : Color(0xFFF8FAFE),
      appBar: AppBar(
        title: Text('Performance Summary', style: TextStyle(color: Colors.white)),
        backgroundColor: isDarkMode ? Colors.grey[800] : Color(0xFF2563EB),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildHeader(),
                    SizedBox(height: 24),
                    _buildPerformanceCards(),
                    SizedBox(height: 24),
                    _buildXPCard(),
                    SizedBox(height: 32),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.emoji_events, size: 64, color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Unit Completed!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            widget.unitName,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildPerformanceCard()),
            SizedBox(width: 16),
            Expanded(child: _buildSpeedCard()),
          ],
        ),
        SizedBox(height: 16),
        _buildAccuracyCard(),
      ],
    );
  }

  Widget _buildPerformanceCard() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    Color cardColor = _performanceLevel == 'Excellent' ? Colors.green : Colors.orange;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.star, size: 40, color: cardColor),
          SizedBox(height: 12),
          Text(
            'Performance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _performanceLevel,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: cardColor,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '$_performancePercentage%',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedCard() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.timer, size: 40, color: isDarkMode ? Colors.blue[300] : Color(0xFF2563EB)),
          SizedBox(height: 12),
          Text(
            'Speed',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _completionTime,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.blue[300] : Color(0xFF2563EB),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'minutes',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyCard() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.gps_fixed, size: 48, color: Colors.purple),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Form Accuracy',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _performancePercentage / 100,
                        backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                        minHeight: 8,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      '$_performancePercentage%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXPCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber[400]!, Colors.orange[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.military_tech, size: 48, color: Colors.white),
          SizedBox(height: 16),
          Text(
            'XP Earned',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '+$_xpEarned XP',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _xpClaimed ? null : _claimXP,
            child: Text(_xpClaimed ? 'XP Claimed!' : 'Claim XP'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _xpClaimed ? Colors.grey : Colors.white,
              foregroundColor: _xpClaimed ? Colors.white : Colors.orange,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    bool isLastUnit = widget.unitIndex == widget.totalUnitsInSection - 1;
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Back to Course'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDarkMode ? Colors.blue[300] : Color(0xFF2563EB),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _proceedToNext,
            child: Text(isLastUnit ? 'Go to Next Section' : 'Go to Next Unit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? Colors.blue[300] : Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _claimXP() {
    final appState = AppState.instance;
    appState.addXP(_xpEarned);
    
    setState(() {
      _xpClaimed = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 $_xpEarned XP added to your account! Total: ${appState.totalXP} XP'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _proceedToNext() {
    bool isLastUnit = widget.unitIndex == widget.totalUnitsInSection - 1;
    
    // Pop back to analysis results with the result
    Navigator.pop(context, isLastUnit ? 'section_complete' : 'next');
  }
}