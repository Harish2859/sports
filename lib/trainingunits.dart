import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:provider/provider.dart';
import 'training_unit_models.dart';
import 'theme_provider.dart';

class TrainingUnitsPage extends StatefulWidget {
  final String sectionName;
  
  const TrainingUnitsPage({Key? key, this.sectionName = "Foundations"}) : super(key: key);

  @override
  _TrainingUnitsPageState createState() => _TrainingUnitsPageState();
}

class _TrainingUnitsPageState extends State<TrainingUnitsPage> with TickerProviderStateMixin {
  int currentUnitIndex = 0;
  UnitStage currentStage = UnitStage.overview;
  bool isRecording = false;
  bool isAnalyzing = false;
  bool fraudDetected = false;
  String analysisResult = "";
  Timer? _analysisTimer;
  
  late AnimationController _pulseController;
  late AnimationController _analysisController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _analysisAnimation;

  final List<TrainingUnit> units = [
    TrainingUnit(
      name: "Warm-Up Readiness",
      description: "Assess your body\'s readiness for training through dynamic movement patterns and joint mobility evaluation.",
      dos: [
        "Perform movements smoothly and controlled",
        "Follow the demonstrated range of motion",
        "Keep your core engaged throughout",
        "Breathe naturally during assessment"
      ],
      donts: [
        "Don\'t rush through the movements",
        "Avoid forcing ranges you can\'t achieve",
        "Don\'t hold your breath",
        "Don\'t perform if experiencing pain"
      ],
      icon: Icons.flash_on,
      color: Colors.orange,
    ),
    TrainingUnit(
      name: "Movement Efficiency",
      description: "Evaluate your movement quality and coordination through fundamental movement patterns.",
      dos: [
        "Maintain proper posture alignment",
        "Execute movements with precision",
        "Focus on quality over speed",
        "Keep movements symmetrical"
      ],
      donts: [
        "Don\'t compensate with incorrect patterns",
        "Avoid excessive speed or momentum",
        "Don\'t ignore pain or discomfort",
        "Don\'t perform with poor form"
      ],
      icon: Icons.timeline,
      color: Colors.blue,
    ),
    TrainingUnit(
      name: "Form Consistency",
      description: "Test your ability to maintain proper form across multiple repetitions of key exercises.",
      dos: [
        "Maintain consistent technique",
        "Control both eccentric and concentric phases",
        "Keep proper breathing pattern",
        "Focus on muscle activation cues"
      ],
      donts: [
        "Don\'t sacrifice form for repetitions",
        "Avoid bouncing or using momentum",
        "Don\'t ignore fatigue-induced form breakdown",
        "Don\'t continue with compromised technique"
      ],
      icon: Icons.check_circle_outline,
      color: Colors.green,
    ),
    TrainingUnit(
      name: "Progressive Load Response",
      description: "Assess how your body responds to increasing training loads and intensity.",
      dos: [
        "Start with appropriate baseline load",
        "Progress gradually as instructed",
        "Monitor your body\'s response",
        "Maintain technical proficiency"
      ],
      donts: [
        "Don\'t jump to heavy loads immediately",
        "Avoid ignoring warning signs",
        "Don\'t progress if form deteriorates",
        "Don\'t push through sharp pain"
      ],
      icon: Icons.trending_up,
      color: Colors.purple,
    ),
    TrainingUnit(
      name: "Recovery Capacity",
      description: "Evaluate your body\'s ability to recover between training sessions and exercises.",
      dos: [
        "Monitor heart rate recovery",
        "Assess subjective recovery feelings",
        "Note any residual muscle tension",
        "Track energy levels accurately"
      ],
      donts: [
        "Don\'t ignore persistent fatigue",
        "Avoid training when severely fatigued",
        "Don\'t rush recovery protocols",
        "Don\'t neglect hydration and nutrition"
      ],
      icon: Icons.bedtime,
      color: Colors.teal,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _analysisController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _analysisAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _analysisController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _analysisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Color(0xFFF8FAFE),
      appBar: AppBar(
        title: Text(
          '${widget.sectionName} Assessment',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: units[currentUnitIndex].color,
        elevation: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${currentUnitIndex + 1}/${units.length}',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: _buildCurrentStage(),
    );
  }

  Widget _buildCurrentStage() {
    switch (currentStage) {
      case UnitStage.overview:
        return _buildTaskOverview();
      case UnitStage.recording:
        return _buildRecordingView();
      case UnitStage.analysis:
        return _buildAnalysisView();
      case UnitStage.results:
        return _buildResultsView();
      case UnitStage.completed:
        return _buildCompletionView();
    }
  }

  Widget _buildTaskOverview() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    TrainingUnit currentUnit = units[currentUnitIndex];
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: currentUnit.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    currentUnit.icon,
                    color: currentUnit.color,
                    size: 40,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  currentUnit.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  currentUnit.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24),
          
          // Dos Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.green[900] : Colors.green[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green[200]!, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[600], size: 24),
                    SizedBox(width: 8),
                    Text(
                      'DO\'S',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.green[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ...currentUnit.dos.map((item) => Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check, color: Colors.green[600], size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.green[800],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // Don'ts Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.red[900] : Colors.red[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red[200]!, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red[600], size: 24),
                    SizedBox(width: 8),
                    Text(
                      'DON\'TS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.red[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ...currentUnit.donts.map((item) => Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.close, color: Colors.red[600], size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.red[800],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
          
          SizedBox(height: 32),
          
          // Take Record Button
          Container(
            width: double.infinity,
            height: 60,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        colors: [currentUnit.color, currentUnit.color.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: currentUnit.color.withOpacity(0.4),
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _startRecording,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videocam, size: 28),
                          SizedBox(width: 12),
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [Colors.white, Colors.white.withOpacity(0.8)],
                            ).createShader(bounds),
                            child: Text(
                              'Take Record',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRecordingView() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Camera Preview Placeholder
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey[900]!, Colors.black],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.videocam,
                  color: Colors.white,
                  size: 100,
                ),
                SizedBox(height: 20),
                Text(
                  isRecording ? 'Recording...' : 'Camera View',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isRecording) ...[
                  SizedBox(height: 10),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Recording Controls
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancel Button
                GestureDetector(
                  onTap: () => _cancelRecording(),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 30),
                  ),
                ),
                
                // Record Button
                GestureDetector(
                  onTap: isRecording ? _stopRecording : _startActualRecording,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isRecording ? Colors.red : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Icon(
                      isRecording ? Icons.stop : Icons.fiber_manual_record,
                      color: isRecording ? Colors.white : Colors.red,
                      size: 40,
                    ),
                  ),
                ),
                
                // Gallery Button (placeholder)
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.photo_library, color: Colors.white, size: 30),
                  ),
                ),
              ],
            ),
          ),
          
          // Recording Timer
          if (isRecording)
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '00:15', // Dummy timer
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnalysisView() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // AI Analysis Animation
          AnimatedBuilder(
            animation: _analysisAnimation,
            builder: (context, child) {
              return Container(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Ring
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: units[currentUnitIndex].color.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                    // Middle Ring
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: units[currentUnitIndex].color.withOpacity(0.5),
                          width: 3,
                        ),
                      ),
                    ),
                    // Inner Circle with Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: units[currentUnitIndex].color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.psychology,
                        color: units[currentUnitIndex].color,
                        size: 50,
                      ),
                    ),
                    // Scanning Wave Effect
                    Positioned.fill(
                      child: Transform.rotate(
                        angle: _analysisAnimation.value * 2 * pi,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                Colors.transparent,
                                units[currentUnitIndex].color.withOpacity(0.3),
                                Colors.transparent,
                              ],
                              stops: [0.0, 0.3, 1.0],
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
          
          SizedBox(height: 40),
          
          Text(
            'AI Analysis in Progress',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          
          SizedBox(height: 16),
          
          Text(
            'Our advanced AI is analyzing your movement patterns, form consistency, and performance metrics...',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 40),
          
          // Progress Steps
          Column(
            children: [
              _buildAnalysisStep('Movement Detection', true),
              _buildAnalysisStep('Form Analysis', isAnalyzing),
              _buildAnalysisStep('Performance Evaluation', false),
              _buildAnalysisStep('Fraud Detection', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisStep(String title, bool isActive) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? units[currentUnitIndex].color.withOpacity(0.1) : (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
        borderRadius: BorderRadius.circular(12),
        border: isActive ? Border.all(color: units[currentUnitIndex].color, width: 1) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isActive ? units[currentUnitIndex].color : (isDarkMode ? Colors.grey[600] : Colors.grey[400]),
              shape: BoxShape.circle,
            ),
            child: isActive 
              ? SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(Icons.check, color: Colors.white, size: 12),
          ),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: isActive ? units[currentUnitIndex].color : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          if (fraudDetected) ...[
            // Fraud Detection Alert
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.red[900] : Colors.red[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red[200]!, width: 2),
              ),
              child: Column(
                children: [
                  Icon(Icons.warning, color: Colors.red[600], size: 60),
                  SizedBox(height: 16),
                  Text(
                    'Fraud Detected',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.red[800],
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Our AI detected potential issues with your video submission. Please retake the assessment.',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.red[700],
                      fontSize: 16,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _retakeVideo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text('Retake Video'),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Success Results
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green[600],
                    size: 80,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Analysis Complete',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Your ${units[currentUnitIndex].name.toLowerCase()} assessment has been successfully analyzed.',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 16,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Performance Metrics
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance Metrics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildMetricRow('Form Quality', '92%', Colors.green),
                  _buildMetricRow('Movement Efficiency', '87%', Colors.blue),
                  _buildMetricRow('Consistency', '94%', Colors.green),
                  _buildMetricRow('Overall Score', '91%', Colors.orange),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // AI Feedback
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: units[currentUnitIndex].color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: units[currentUnitIndex].color.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: units[currentUnitIndex].color),
                      SizedBox(width: 8),
                      Text(
                        'AI Feedback',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: units[currentUnitIndex].color,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    _getAIFeedback(),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 32),
            
            // Complete Button
            Container(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _completeUnit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: units[currentUnitIndex].color,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: units[currentUnitIndex].color.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Complete Assessment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
    Widget _buildCompletionView() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.green[900] : Colors.green[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events,
              color: Colors.green[600],
              size: 80,
            ),
          ),
          
          SizedBox(height: 32),
          
          Text(
            'Unit Completed!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          
          SizedBox(height: 16),
          
          Text(
            'Great job completing the ${units[currentUnitIndex].name} assessment!',
            style: TextStyle(
              fontSize: 18,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 48),
          
          if (currentUnitIndex < units.length - 1) ...[
            // Go to Next Unit Button
            Container(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _goToNextUnit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: units[currentUnitIndex].color,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: units[currentUnitIndex].color.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_forward, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Next Unit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Finish Training Button
            Container(
              width: double.infinity,
              height: 60,
              child: OutlinedButton(
                onPressed: _finishAndReturn,
                style: OutlinedButton.styleFrom(
                  foregroundColor: units[currentUnitIndex].color,
                  side: BorderSide(color: units[currentUnitIndex].color, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Finish Training',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // All Units Completed Message
            Text(
              'You have completed all training units in this section.',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            // Finish Training Button
            Container(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _finishAndReturn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: Colors.green.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Complete Training',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _goToNextUnit() {
    setState(() {
      if (currentUnitIndex < units.length - 1) {
        currentUnitIndex++;
        currentStage = UnitStage.overview;
        isRecording = false;
        isAnalyzing = false;
        fraudDetected = false;
        analysisResult = "";
        _pulseController.repeat(reverse: true);
      }
    });
  }

  void _startRecording() {
    setState(() {
      currentStage = UnitStage.recording;
      isRecording = false;
    });
  }

  void _startActualRecording() {
    setState(() {
      isRecording = true;
    });
  }

  void _stopRecording() {
    setState(() {
      isRecording = false;
      currentStage = UnitStage.analysis;
      isAnalyzing = true;
      _pulseController.stop();
      _analysisController.repeat();

      // Simulate AI analysis delay
      _analysisTimer = Timer(Duration(seconds: 5), () {
        setState(() {
          isAnalyzing = false;
          _analysisController.stop();
          currentStage = UnitStage.results;

          // Randomly simulate fraud detection for demo
          fraudDetected = Random().nextBool() && currentUnitIndex % 2 == 0;

          analysisResult = fraudDetected ? "Fraud Detected" : "Analysis Complete";
        });
      });
    });
  }

  void _cancelRecording() {
    setState(() {
      currentStage = UnitStage.overview;
      isRecording = false;
      _pulseController.repeat(reverse: true);
    });
  }

  void _retakeVideo() {
    setState(() {
      currentStage = UnitStage.recording;
      isRecording = false;
      fraudDetected = false;
      _pulseController.stop();
    });
  }

  void _completeUnit() {
    setState(() {
      currentStage = UnitStage.completed;
    });
  }
  
  void _finishAndReturn() {
    // Return true to indicate completion
    Navigator.pop(context, true);
  }

  String _getAIFeedback() {
    switch (currentUnitIndex) {
      case 0:
        return "Your readiness level is strong. Maintain smoothness and control in movements.";
      case 1:
        return "Good coordination and posture detected. Focus on eliminating compensations.";
      case 2:
        return "Form consistency is impressive. Remember to control both movement phases.";
      case 3:
        return "Progressive load response is steady. Avoid jumping to heavy loads too fast.";
      case 4:
        return "Recovery capacity is adequate. Stay attentive to persistent fatigue signs.";
      default:
        return "Feedback unavailable.";
    }
  }
}