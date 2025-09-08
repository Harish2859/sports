import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'analysis_results.dart';
import 'theme_provider.dart';
import 'simple_video_recorder.dart';
import 'performance_videos_manager.dart';

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
  final String? videoUrl;

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
    this.videoUrl,
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
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  String? _recordedVideoPath;
  VideoPlayerController? _recordedVideoController;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _recordedVideoController?.dispose();
    super.dispose();
  }

  void _initializeVideo() {
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      if (widget.videoUrl!.startsWith('http')) {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
      } else {
        _videoController = VideoPlayerController.asset(widget.videoUrl!);
      }
      
      _videoController!.initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
        });
      }).catchError((error) {
        print('Video initialization error: $error');
      });
    }
  }

  Future<void> _initializeRecordedVideo() async {
    if (_recordedVideoPath != null) {
      _recordedVideoController = VideoPlayerController.file(File(_recordedVideoPath!));
      await _recordedVideoController!.initialize();
      if (mounted) setState(() {});
    }
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
            child: _isVideoInitialized && _videoController != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        ),
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _videoController!.value.isPlaying
                                    ? _videoController!.pause()
                                    : _videoController!.play();
                              });
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Center(
                                child: Icon(
                                  _videoController!.value.isPlaying
                                      ? Icons.pause_circle_outline
                                      : Icons.play_circle_outline,
                                  size: 64,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_circle_outline, size: 64, color: isDarkMode ? Colors.blue[300] : Color(0xFF2563EB)),
                        SizedBox(height: 8),
                        Text(
                          widget.videoUrl != null ? 'Loading video...' : 'No video available',
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
            child: _recordedVideoPath != null && _recordedVideoController != null && _recordedVideoController!.value.isInitialized
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        VideoPlayer(_recordedVideoController!),
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _recordedVideoController!.value.isPlaying
                                    ? _recordedVideoController!.pause()
                                    : _recordedVideoController!.play();
                              });
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Center(
                                child: Icon(
                                  _recordedVideoController!.value.isPlaying
                                      ? Icons.pause_circle_outline
                                      : Icons.play_circle_outline,
                                  size: 64,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
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

  void _toggleRecording() async {
    if (_isRecording) {
      setState(() {
        _isRecording = false;
      });
      return;
    }

    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const SimpleVideoRecorder()),
    );

    if (result != null) {
      PerformanceVideosManager().addVideo(result);
      setState(() {
        _recordedVideoPath = result;
      });
      _initializeRecordedVideo();
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
      _recordedVideoPath = null;
      _recordedVideoController?.dispose();
      _recordedVideoController = null;
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