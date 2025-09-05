import 'package:flutter/material.dart';
import 'analysis_results.dart';

class UnitDetailsPage extends StatefulWidget {
  final String unitName;
  final String unitDescription;
  final String sectionName;
  final int unitIndex;

  const UnitDetailsPage({
    Key? key,
    required this.unitName,
    required this.unitDescription,
    required this.sectionName,
    required this.unitIndex,
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
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFE),
      appBar: AppBar(
        title: Text('Unit Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF2563EB),
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
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            widget.unitName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Text(
            widget.unitDescription,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.access_time, color: Color(0xFF2563EB), size: 20),
              SizedBox(width: 8),
              Text(
                'Estimated time: 15-20 minutes',
                style: TextStyle(
                  color: Color(0xFF2563EB),
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
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_outline, size: 64, color: Color(0xFF2563EB)),
                  SizedBox(height: 8),
                  Text(
                    'Video demonstration coming soon',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Watch this video for an overview and demonstration of key concepts for ${widget.unitName}.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectives() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
              color: Colors.black87,
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
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Color(0xFF2563EB), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              objective,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam, size: 48, color: Colors.grey[500]),
                  SizedBox(height: 8),
                  Text(
                    'Tap to record your performance',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          if (_isAnalyzing)
            Column(
              children: [
                CircularProgressIndicator(color: Color(0xFF2563EB)),
                SizedBox(height: 12),
                Text('AI analyzing your performance...', style: TextStyle(color: Colors.grey[600])),
              ],
            )
          else if (_hasRecording && !_isAnalyzing)
            Column(
              children: [
                if (_hasMalpractice)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
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
                        Text(_analysisResult ?? '', style: TextStyle(color: Colors.red[700])),
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
                      color: Colors.green[50],
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
                        Text(_analysisResult ?? '', style: TextStyle(color: Colors.green[700])),
                      ],
                    ),
                  ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitRecording,
                  child: Text('Submit Recording'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2563EB),
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
                    backgroundColor: _isRecording ? Colors.red : Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showRecordingTips(),
                  icon: Icon(Icons.info_outline),
                  label: Text('Tips'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFF2563EB),
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
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Back to Course'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Color(0xFF2563EB),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: (_hasRecording && !_hasMalpractice) ? () => _goToNextUnit() : null,
            child: Text('Go to Next Unit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: (_hasRecording && !_hasMalpractice) ? Color(0xFF2563EB) : Colors.grey,
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
          hasMalpractice: _hasMalpractice,
          analysisResult: _analysisResult ?? '',
        ),
      ),
    );

    if (result == 'retake') {
      _retakeRecording();
    } else if (result == 'next') {
      _goToNextUnit();
    }
  }

  void _goToNextUnit() {
    // Navigate to next unit in the same section
    int nextUnitIndex = widget.unitIndex + 1;
    
    // For demo, just show completion message and go back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Unit completed! Moving to next unit...'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // Return true to mark current unit as completed
    Navigator.pop(context, true);
  }

  void _showRecordingTips() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Recording Tips'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Ensure good lighting'),
            Text('• Keep camera steady'),
            Text('• Record full movement'),
            Text('• Focus on proper form'),
            Text('• Record multiple angles if needed'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }




}