import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'performance_summary.dart';
import 'theme_provider.dart';
import 'app_state.dart';

class AnalysisResultsPage extends StatefulWidget {
  final String unitName;
  final int unitIndex;
  final int sectionIndex;
  final int totalUnitsInSection;
  final bool hasMalpractice;
  final String analysisResult;

  const AnalysisResultsPage({
    Key? key,
    required this.unitName,
    required this.unitIndex,
    required this.sectionIndex,
    required this.totalUnitsInSection,
    required this.hasMalpractice,
    required this.analysisResult,
  }) : super(key: key);

  @override
  _AnalysisResultsPageState createState() => _AnalysisResultsPageState();
}

class _AnalysisResultsPageState extends State<AnalysisResultsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _resultController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    _resultController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.easeOut),
    );

    _startAnalysis();
  }

  void _startAnalysis() async {
    _animationController.forward();
    await Future.delayed(Duration(seconds: 3));
    setState(() {
      _showResults = true;
    });
    _resultController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Color(0xFFF8FAFE),
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text('AI Analysis', style: TextStyle(color: Colors.white))),
            themeProvider.buildXPBadge(appState.totalXP),
            const SizedBox(width: 8),
            SizedBox(
              width: 30,
              height: 30,
              child: themeProvider.buildLottieAnimation(),
            ),
          ],
        ),
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
      body: _showResults ? _buildResults() : _buildAnalysisAnimation(),
    );
  }

  Widget _buildAnalysisAnimation() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 200,
                  height: 200,
                  child: themeProvider.buildLottieAnimation(),
                ),
              );
            },
          ),
          SizedBox(height: 32),
          Text(
            'AI Analyzing Your Performance',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Please wait while our AI evaluates\nyour form and technique...', 
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return AnimatedBuilder(
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
                  _buildResultHeader(),
                  SizedBox(height: 24),
                  _buildScoreCard(),
                  SizedBox(height: 24),
                  _buildDetailedAnalysis(),
                  SizedBox(height: 24),
                  _buildRecommendations(),
                  SizedBox(height: 32),
                  _buildNavigationButtons(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.hasMalpractice
              ? [Colors.red[400]!, Colors.red[600]!]
              : [Colors.green[400]!, Colors.green[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (widget.hasMalpractice ? Colors.red : Colors.green)
                .withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            widget.hasMalpractice ? Icons.warning_rounded : Icons.check_circle_rounded,
            size: 64,
            color: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            widget.hasMalpractice ? 'Issues Detected' : 'Excellent Performance!',
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
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    int score = widget.hasMalpractice ? 65 : 92;

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Performance Score',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '$score/100',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: widget.hasMalpractice ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 8,
              backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.hasMalpractice ? Colors.red : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedAnalysis() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Analysis',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Text(
            widget.analysisResult,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              height: 1.5,
            ),
          ),
          SizedBox(height: 16),
          _buildAnalysisMetrics(),
        ],
      ),
    );
  }

  Widget _buildAnalysisMetrics() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    List<Map<String, dynamic>> metrics = widget.hasMalpractice
        ? [
            {'label': 'Form Accuracy', 'value': 0.6, 'color': Colors.red},
            {'label': 'Technique', 'value': 0.7, 'color': Colors.orange},
            {'label': 'Safety', 'value': 0.5, 'color': Colors.red},
          ]
        : [
            {'label': 'Form Accuracy', 'value': 0.95, 'color': Colors.green},
            {'label': 'Technique', 'value': 0.9, 'color': Colors.green},
            {'label': 'Safety', 'value': 0.92, 'color': Colors.green},
          ];

    return Column(
      children: metrics.map((metric) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(metric['label'], style: TextStyle(fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white : Colors.black87)),
                  Text('${(metric['value'] * 100).toInt()}%', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
                ],
              ),
              SizedBox(height: 4),
              LinearProgressIndicator(
                value: metric['value'],
                backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(metric['color']),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecommendations() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    List<String> recommendations = widget.hasMalpractice
        ? [
            'Focus on maintaining proper posture throughout the movement',
            'Slow down the movement to ensure correct form',
            'Review the instructional video before retaking',
          ]
        : [
            'Great job! Continue with this excellent form',
            'You can progress to the next difficulty level',
            'Consider increasing the intensity slightly',
          ];

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommendations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          ...recommendations.map((rec) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: isDarkMode ? Colors.blue[300]! : Color(0xFF2563EB),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        rec,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Back to Course'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDarkMode ? Colors.blue[300]! : Color(0xFF2563EB),
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
            onPressed: widget.hasMalpractice ? _retakeUnit : _goToNextUnit,
            child: Text(widget.hasMalpractice ? 'Retake Unit' : 'Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.hasMalpractice ? Colors.red : (isDarkMode ? Colors.blue[300]! : Color(0xFF2563EB)),
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

  void _retakeUnit() {
    Navigator.pop(context, 'retake');
  }

  bool _isLastUnitInSection() {
    return widget.unitIndex == widget.totalUnitsInSection - 1;
  }

  void _goToNextUnit() async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PerformanceSummaryPage(
            unitName: widget.unitName,
            unitIndex: widget.unitIndex,
            sectionIndex: widget.sectionIndex,
            totalUnitsInSection: widget.totalUnitsInSection,
            hasMalpractice: widget.hasMalpractice,
          ),
        ),
      );
      if (mounted) {
        Navigator.pop(context, 'next');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context, 'next');
      }
    }
  }
}