import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'analysis_results.dart';
import 'theme_provider.dart';

class EnhancedUnitDetailsPage extends StatefulWidget {
  final String unitName;
  final String unitDescription;
  final String sectionName;
  final int unitIndex;
  final int sectionIndex;
  final int totalUnitsInSection;
  final List<String> objectives;
  final List<String> dos;
  final List<String> donts;

  const EnhancedUnitDetailsPage({
    Key? key,
    required this.unitName,
    required this.unitDescription,
    required this.sectionName,
    required this.unitIndex,
    required this.sectionIndex,
    required this.totalUnitsInSection,
    required this.objectives,
    required this.dos,
    required this.donts,
  }) : super(key: key);

  @override
  _EnhancedUnitDetailsPageState createState() => _EnhancedUnitDetailsPageState();
}

class _EnhancedUnitDetailsPageState extends State<EnhancedUnitDetailsPage> {
  bool _isRecording = false;
  bool _isAnalyzing = false;
  bool _hasRecording = false;
  String? _analysisResult;
  bool _hasMalpractice = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      decoration: themeProvider.isGamified
          ? const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1a237e), Color(0xFF000000)],
              ),
            )
          : null,
      child: Scaffold(
        backgroundColor: themeProvider.isGamified ? Colors.transparent : (isDarkMode ? Colors.grey[900] : Color(0xFFF8FAFE)),
        appBar: AppBar(
          title: Text('Unit Details', style: TextStyle(color: Colors.white)),
          backgroundColor: themeProvider.isGamified ? Colors.transparent : (isDarkMode ? Colors.grey[800] : Color(0xFF2563EB)),
          flexibleSpace: themeProvider.isGamified
              ? Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1a237e), Color(0xFF000000)],
                    ),
                  ),
                )
              : null,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: themeProvider.isGamified
              ? Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1a237e), Color(0xFF000000)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(padding: EdgeInsets.all(20), child: _buildGamifiedUnitHeader()),
                      Padding(padding: EdgeInsets.all(20), child: _buildGamifiedVideoSection()),
                      Padding(padding: EdgeInsets.all(20), child: _buildGamifiedObjectives()),
                      Padding(padding: EdgeInsets.all(20), child: _buildGamifiedDosAndDonts()),
                      Padding(padding: EdgeInsets.all(20), child: _buildGamifiedRecordingSection()),
                      SizedBox(height: 32),
                      _buildNavigationButtons(),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUnitHeader(),
                    SizedBox(height: 24),
                    _buildVideoSection(),
                    SizedBox(height: 24),
                    _buildObjectives(),
                    SizedBox(height: 24),
                    _buildDosAndDonts(),
                    SizedBox(height: 24),
                    _buildRecordingSection(),
                    SizedBox(height: 32),
                    _buildNavigationButtons(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildUnitHeader() {
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
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            widget.unitName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Text(
            widget.unitDescription,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              height: 1.5,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.access_time, color: isDarkMode ? Colors.blue[300] : Color(0xFF2563EB), size: 20),
              SizedBox(width: 8),
              Text(
                'Estimated time: 15-20 minutes',
                style: TextStyle(
                  color: isDarkMode ? Colors.blue[300] : Color(0xFF2563EB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
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
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instructional Video',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_outline, size: 64, color: isDarkMode ? Colors.blue[300] : Color(0xFF2563EB)),
                  SizedBox(height: 8),
                  Text(
                    'Video demonstration coming soon',
                    style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Watch this video for an overview and demonstration of key concepts for ${widget.unitName}.',
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectives() {
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
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning Objectives',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          ...widget.objectives.map((objective) => _buildObjectiveItem(objective)),
        ],
      ),
    );
  }

  Widget _buildObjectiveItem(String objective) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: isDarkMode ? Colors.blue[300] : Color(0xFF2563EB), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              objective,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDosAndDonts() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Do\'s',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ...widget.dos.map((item) => Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.arrow_right, color: Colors.green, size: 16),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Don\'ts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ...widget.donts.map((item) => Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.arrow_right, color: Colors.red, size: 16),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingSection() {
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
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Record Your Performance',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam, size: 48, color: isDarkMode ? Colors.grey[400] : Colors.grey[500]),
                  SizedBox(height: 8),
                  Text(
                    'Tap to record your performance',
                    style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          if (_isAnalyzing)
            Column(
              children: [
                CircularProgressIndicator(color: isDarkMode ? Colors.blue[300] : Color(0xFF2563EB)),
                SizedBox(height: 12),
                Text('AI analyzing your performance...', style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
              ],
            )
          else if (_hasRecording && !_isAnalyzing)
            Column(
              children: [
                if (_hasMalpractice)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.red[900] : Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Issues Detected', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(_analysisResult ?? '', style: TextStyle(color: isDarkMode ? Colors.white : Colors.red[700])),
                        SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _retakeRecording,
                          child: Text('Retake Recording'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.green[900] : Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Great Performance!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(_analysisResult ?? '', style: TextStyle(color: isDarkMode ? Colors.white : Colors.green[700])),
                      ],
                    ),
                  ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitRecording,
                  child: Text('Submit Recording'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? Colors.blue[300] : Color(0xFF2563EB),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _toggleRecording,
                  icon: Icon(_isRecording ? Icons.stop : Icons.fiber_manual_record),
                  label: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording ? Colors.red : (isDarkMode ? Colors.blue[300] : Color(0xFF2563EB)),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showRecordingTips(),
                  icon: Icon(Icons.info_outline),
                  label: Text('Tips'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDarkMode ? Colors.blue[300] : Color(0xFF2563EB),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Back to Course'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDarkMode ? Colors.blue[300] : Color(0xFF2563EB),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: (_hasRecording && !_hasMalpractice) ? () => _goToNextUnit() : null,
            child: Text(_isLastUnitInSection() ? 'Go to Next Section' : 'Go to Next Unit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: (_hasRecording && !_hasMalpractice) ? (isDarkMode ? Colors.blue[300] : Color(0xFF2563EB)) : Colors.grey,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
    
    if (!_isRecording) {
      _startAnalysis();
    }
  }

  void _startAnalysis() async {
    setState(() {
      _isAnalyzing = true;
      _hasRecording = true;
    });

    await Future.delayed(Duration(seconds: 3));

    bool hasMalpractice = DateTime.now().millisecond % 3 == 0;
    
    setState(() {
      _isAnalyzing = false;
      _hasMalpractice = hasMalpractice;
      _analysisResult = hasMalpractice 
        ? 'Improper form detected. Please maintain proper posture and follow the demonstrated technique.'
        : 'Excellent form and technique! Your movement patterns are correct.';
    });
  }

  void _retakeRecording() {
    setState(() {
      _hasRecording = false;
      _hasMalpractice = false;
      _analysisResult = null;
      _isRecording = false;
    });
  }

  void _submitRecording() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisResultsPage(
          unitName: widget.unitName,
          unitIndex: widget.unitIndex,
          sectionIndex: widget.sectionIndex,
          totalUnitsInSection: widget.totalUnitsInSection,
          hasMalpractice: _hasMalpractice,
          analysisResult: _analysisResult ?? '',
        ),
      ),
    );

    if (result == 'retake') {
      _retakeRecording();
    } else if (result == 'next') {
      _goToNextUnit();
    } else if (result == 'section_complete') {
      Navigator.pop(context, 'section_complete');
    }
  }

  bool _isLastUnitInSection() {
    return widget.unitIndex == widget.totalUnitsInSection - 1;
  }

  void _goToNextUnit() {
    String message = _isLastUnitInSection() 
        ? 'Section completed! Moving to next section...'
        : 'Unit completed! Moving to next unit...';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    Navigator.pop(context, _isLastUnitInSection() ? 'section_complete' : true);
  }

  void _showRecordingTips() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        title: Text('Recording Tips', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Ensure good lighting', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
            Text('• Keep camera steady', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
            Text('• Record full movement', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
            Text('• Focus on proper form', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
            Text('• Record multiple angles if needed', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildGamifiedUnitHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome to', style: TextStyle(fontSize: 16, color: Colors.white70)),
        SizedBox(height: 8),
        Text(widget.unitName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 16),
        Text(widget.unitDescription, style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
        SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.access_time, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Estimated time: 15-20 minutes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildGamifiedVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Instructional Video', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
                SizedBox(height: 8),
                Text('Video demonstration coming soon', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
        SizedBox(height: 12),
        Text('Watch this video for an overview and demonstration of key concepts for ${widget.unitName}.', style: TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }

  Widget _buildGamifiedObjectives() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Learning Objectives', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 16),
        ...widget.objectives.map((objective) => Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(child: Text(objective, style: TextStyle(fontSize: 16, color: Colors.white70))),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildGamifiedDosAndDonts() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text('Do\'s', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
              SizedBox(height: 12),
              ...widget.dos.map((item) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.arrow_right, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Expanded(child: Text(item, style: TextStyle(fontSize: 14, color: Colors.white70))),
                  ],
                ),
              )),
            ],
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.cancel, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Don\'ts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              ),
              SizedBox(height: 12),
              ...widget.donts.map((item) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.arrow_right, color: Colors.red, size: 16),
                    SizedBox(width: 4),
                    Expanded(child: Text(item, style: TextStyle(fontSize: 14, color: Colors.white70))),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGamifiedRecordingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Record Your Performance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.videocam, size: 48, color: Colors.white70),
                SizedBox(height: 8),
                Text('Tap to record your performance', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        if (_isAnalyzing)
          Column(
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 12),
              Text('AI analyzing your performance...', style: TextStyle(color: Colors.white70)),
            ],
          )
        else if (_hasRecording && !_isAnalyzing)
          Column(
            children: [
              if (_hasMalpractice)
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Issues Detected', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(_analysisResult ?? '', style: TextStyle(color: Colors.white)),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _retakeRecording,
                        child: Text('Retake Recording'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Great Performance!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(_analysisResult ?? '', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitRecording,
                child: Text('Submit Recording'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF1a237e),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _toggleRecording,
                icon: Icon(_isRecording ? Icons.stop : Icons.fiber_manual_record),
                label: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRecording ? Colors.red : Colors.white,
                  foregroundColor: _isRecording ? Colors.white : Color(0xFF1a237e),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showRecordingTips(),
                icon: Icon(Icons.info_outline),
                label: Text('Tips'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class UnitDetailsPage extends StatefulWidget {
  final String unitName;
  final String unitDescription;
  final String sectionName;
  final int unitIndex;
  final int sectionIndex;
  final int totalUnitsInSection;
  final List<String> objectives;
  final List<String> dos;
  final List<String> donts;

  const UnitDetailsPage({
    Key? key,
    required this.unitName,
    required this.unitDescription,
    required this.sectionName,
    required this.unitIndex,
    required this.sectionIndex,
    required this.totalUnitsInSection,
    required this.objectives,
    required this.dos,
    required this.donts,
  }) : super(key: key);

  @override
  _UnitDetailsPageState createState() => _UnitDetailsPageState();
}

class _UnitDetailsPageState extends State<UnitDetailsPage> {
  bool _isRecording = false;
  bool _isAnalyzing = false;
  bool _hasRecording = false;
  String? _analysisResult;
  bool _hasMalpractice = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Color(0xFFF8FAFE),
      appBar: AppBar(
        title: Text('Unit Details', style: TextStyle(color: Colors.white)),
        backgroundColor: isDarkMode ? Colors.grey[800] : Color(0xFF2563EB),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUnitHeader(),
            SizedBox(height: 24),
            _buildVideoSection(),
            SizedBox(height: 24),
            _buildObjectives(),
            SizedBox(height: 24),
            _buildRecordingSection(),
            SizedBox(height: 32),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitHeader() {
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
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            widget.unitName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Text(
            widget.unitDescription,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              height: 1.5,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.access_time, color: isDarkMode ? Colors.blue[300] : Color(0xFF2563EB), size: 20),
              SizedBox(width: 8),
              Text(
                'Estimated time: 15-20 minutes',
                style: TextStyle(
                  color: isDarkMode ? Colors.blue[300] : Color(0xFF2563EB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
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
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instructional Video',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_outline, size: 64, color: isDarkMode ? Colors.blue[300] : Color(0xFF2563EB)),
                  SizedBox(height: 8),
                  Text(
                    'Video demonstration coming soon',
                    style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Watch this video for an overview and demonstration of key concepts for ${widget.unitName}.',
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectives() {
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
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning Objectives',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          _buildObjectiveItem('Master proper form and technique'),
          _buildObjectiveItem('Understand progression principles'),
          _buildObjectiveItem('Apply safety guidelines'),
          _buildObjectiveItem('Record and track your performance'),
        ],
      ),
    );
  }

  Widget _buildObjectiveItem(String objective) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: isDarkMode ? Colors.blue[300] : Color(0xFF2563EB), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              objective,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingSection() {
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
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Record Your Performance',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam, size: 48, color: isDarkMode ? Colors.grey[400] : Colors.grey[500]),
                  SizedBox(height: 8),
                  Text(
                    'Tap to record your performance',
                    style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          if (_isAnalyzing)
            Column(
              children: [
                CircularProgressIndicator(color: isDarkMode ? Colors.blue[300] : Color(0xFF2563EB)),
                SizedBox(height: 12),
                Text('AI analyzing your performance...', style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
              ],
            )
          else if (_hasRecording && !_isAnalyzing)
            Column(
              children: [
                if (_hasMalpractice)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.red[900] : Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Issues Detected', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(_analysisResult ?? '', style: TextStyle(color: isDarkMode ? Colors.white : Colors.red[700])),
                        SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _retakeRecording,
                          child: Text('Retake Recording'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.green[900] : Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Great Performance!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(_analysisResult ?? '', style: TextStyle(color: isDarkMode ? Colors.white : Colors.green[700])),
                      ],
                    ),
                  ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitRecording,
                  child: Text('Submit Recording'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? Colors.blue[300] : Color(0xFF2563EB),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _toggleRecording,
                  icon: Icon(_isRecording ? Icons.stop : Icons.fiber_manual_record),
                  label: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording ? Colors.red : (isDarkMode ? Colors.blue[300] : Color(0xFF2563EB)),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showRecordingTips(),
                  icon: Icon(Icons.info_outline),
                  label: Text('Tips'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDarkMode ? Colors.blue[300] : Color(0xFF2563EB),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Back to Course'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDarkMode ? Colors.blue[300] : Color(0xFF2563EB),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: (_hasRecording && !_hasMalpractice) ? () => _goToNextUnit() : null,
            child: Text(_isLastUnitInSection() ? 'Go to Next Section' : 'Go to Next Unit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: (_hasRecording && !_hasMalpractice) ? (isDarkMode ? Colors.blue[300] : Color(0xFF2563EB)) : Colors.grey,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
    
    if (!_isRecording) {
      _startAnalysis();
    }
  }

  void _startAnalysis() async {
    setState(() {
      _isAnalyzing = true;
      _hasRecording = true;
    });

    // Simulate AI analysis delay
    await Future.delayed(Duration(seconds: 3));

    // Simulate random analysis result
    bool hasMalpractice = DateTime.now().millisecond % 3 == 0; // 33% chance of malpractice
    
    setState(() {
      _isAnalyzing = false;
      _hasMalpractice = hasMalpractice;
      _analysisResult = hasMalpractice 
        ? 'Improper form detected. Please maintain proper posture and follow the demonstrated technique.'
        : 'Excellent form and technique! Your movement patterns are correct.';
    });
  }

  void _retakeRecording() {
    setState(() {
      _hasRecording = false;
      _hasMalpractice = false;
      _analysisResult = null;
      _isRecording = false;
    });
  }

  void _submitRecording() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisResultsPage(
          unitName: widget.unitName,
          unitIndex: widget.unitIndex,
          sectionIndex: widget.sectionIndex,
          totalUnitsInSection: widget.totalUnitsInSection,
          hasMalpractice: _hasMalpractice,
          analysisResult: _analysisResult ?? '',
        ),
      ),
    );

    if (result == 'retake') {
      _retakeRecording();
    } else if (result == 'next') {
      _goToNextUnit();
    } else if (result == 'section_complete') {
      Navigator.pop(context, 'section_complete');
    }
  }

  bool _isLastUnitInSection() {
    return widget.unitIndex == widget.totalUnitsInSection - 1;
  }

  void _goToNextUnit() {
    String message = _isLastUnitInSection() 
        ? 'Section completed! Moving to next section...'
        : 'Unit completed! Moving to next unit...';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    Navigator.pop(context, _isLastUnitInSection() ? 'section_complete' : true);
  }

  void _showRecordingTips() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        title: Text('Recording Tips', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Ensure good lighting', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
            Text('• Keep camera steady', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
            Text('• Record full movement', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
            Text('• Focus on proper form', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
            Text('• Record multiple angles if needed', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
          ),
        ],
      ),
    );
  }
}