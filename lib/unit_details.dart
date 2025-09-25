import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'analysis_results.dart';
import 'simple_video_recorder.dart';
import 'performance_videos_manager.dart';

// A custom painter for the dashed border effect.
class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const double dashWidth = 8;
    const double dashSpace = 6;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      canvas.drawLine(Offset(startX, size.height), Offset(startX + dashWidth, size.height), paint);
      startX += dashWidth + dashSpace;
    }

    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      canvas.drawLine(Offset(size.width, startY), Offset(size.width, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
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
  // State variables remain the same
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
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    _recordedVideoController?.dispose();
    super.dispose();
  }
  
  void _videoListener() {
    if (mounted) {
      setState(() {});
    }
  }

  void _initializeVideo() {
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      if (widget.videoUrl!.startsWith('http')) {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
      } else {
        _videoController = VideoPlayerController.asset(widget.videoUrl!);
      }
      
      _videoController!
        ..addListener(_videoListener)
        ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
        }
      }).catchError((error) {
        print('Video initialization error: $error');
        // Handle error state if needed
      });
    }
  }

  Future<void> _initializeRecordedVideo() async {
    if (_recordedVideoPath != null) {
      _recordedVideoController?.dispose();
      _recordedVideoController = VideoPlayerController.file(File(_recordedVideoPath!));
      await _recordedVideoController!.initialize();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVideoHero(context),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUnitInfo(),
                  _buildDivider(),
                  _buildSectionHeader("Record Your Performance"),
                  SizedBox(height: 16),
                  _buildRecordingSection(),
                  _buildDivider(),
                  _buildDosAndDontsSection(),
                  _buildDivider(),
                  _buildSectionHeader("Learning Objectives"),
                  SizedBox(height: 16),
                  _buildObjectives(),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoHero(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 300,
          width: double.infinity,
          color: Colors.black,
          child: _isVideoInitialized && _videoController != null
              ? Center(
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.ondemand_video_rounded, size: 64, color: Colors.grey[800]),
                      SizedBox(height: 12),
                      Text('No Instructional Video Available', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    ],
                  ),
                ),
        ),
        // Gradient overlay for text readability
        Container(
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
                Colors.black.withOpacity(0.9)
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // Video Player Controls
        if (_isVideoInitialized && _videoController != null)
        Positioned.fill(
          child: _buildVideoControlsOverlay(_videoController!),
        ),
        // Top action buttons (Back, etc.)
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeroButton(context, Icons.arrow_back, () => Navigator.of(context).pop()),
              _buildHeroButton(context, Icons.more_horiz, () { /* Add functionality */ }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroButton(BuildContext context, IconData icon, VoidCallback onPressed) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
  
  Widget _buildVideoControlsOverlay(VideoPlayerController controller) {
    bool isFinished = controller.value.position >= controller.value.duration;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Top space
        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                if (isFinished) {
                  controller.seekTo(Duration.zero);
                  controller.play();
                } else {
                  controller.value.isPlaying ? controller.pause() : controller.play();
                }
              });
            },
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: AnimatedOpacity(
                  opacity: controller.value.isPlaying ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.black.withOpacity(0.6),
                    child: Icon(
                      isFinished ? Icons.replay : Icons.play_arrow,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Progress Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: VideoProgressIndicator(
            controller,
            allowScrubbing: true,
            padding: const EdgeInsets.all(8),
            colors: VideoProgressColors(
              playedColor: Theme.of(context).primaryColor,
              bufferedColor: Colors.grey[700]!,
              backgroundColor: Colors.grey[850]!,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.unitName,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            _buildInfoTag(Icons.calendar_today_outlined, '2025'),
            SizedBox(width: 12),
            _buildInfoTag(Icons.timer_outlined, '15-20 min'),
          ],
        ),
        SizedBox(height: 20),
        Text(
          widget.unitDescription,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
            height: 1.6,
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[400], size: 16),
          SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
        ],
      ),
    );
  }
  
  Widget _buildDivider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24.0),
    child: Divider(color: Colors.grey[800], height: 1),
  );
  
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.black87,
        fontSize: 22,
        fontWeight: FontWeight.bold
      ),
    );
  }

  Widget _buildRecordingSection() {
    Widget currentStateWidget;

    if (_isAnalyzing) {
      currentStateWidget = _buildAnalyzingState();
    } else if (_hasRecording) {
      currentStateWidget = _buildResultState();
    } else {
      currentStateWidget = _buildInitialState();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: currentStateWidget,
    );
  }

  Widget _buildInitialState() {
    return Column(
      key: ValueKey('initial'),
      children: [
        _buildRecordedVideoPlayerContainer(),
        SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            HapticFeedback.heavyImpact();
            _toggleRecording();
          },
          icon: Icon(Icons.videocam),
          label: Text('Record Now'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            elevation: 8,
            shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
        ),
        SizedBox(height: 12),
        TextButton.icon(
          onPressed: _showRecordingTips,
          icon: Icon(Icons.lightbulb_outline, size: 20),
          label: Text('Recording Tips'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[400],
          ),
        )
      ],
    );
  }

  Widget _buildRecordedVideoPlayerContainer({Widget? overlay}) {
    bool hasVideo = _recordedVideoPath != null && _recordedVideoController != null && _recordedVideoController!.value.isInitialized;
    
    return AspectRatio(
      aspectRatio: 16/9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: Colors.black,
          child: hasVideo
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _recordedVideoController!.value.aspectRatio,
                      child: VideoPlayer(_recordedVideoController!),
                    ),
                    _buildVideoControlsOverlay(_recordedVideoController!),
                    if (overlay != null) overlay,
                  ],
                )
              : CustomPaint(
                  painter: DashedBorderPainter(),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_camera_front_outlined, size: 64, color: Colors.grey[700]),
                        SizedBox(height: 12),
                        Text('Your recording will appear here', style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildAnalyzingState() {
    return Column(
      key: ValueKey('analyzing'),
      children: [
        _buildRecordedVideoPlayerContainer(
          overlay: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Theme.of(context).primaryColor),
                      SizedBox(height: 20),
                      Text(
                        'AI is analyzing your video...',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultState() {
    return Column(
      key: ValueKey('result'),
      children: [
        _buildRecordedVideoPlayerContainer(),
        SizedBox(height: 24),
        _buildAnalysisResultCard(),
        SizedBox(height: 16),
        if (!_hasMalpractice)
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              _submitRecording();
            },
            icon: Icon(Icons.check_circle_outline),
            label: Text('Submit Recording'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
  
  Widget _buildAnalysisResultCard() {
    final bool isSuccess = !_hasMalpractice;
    final Color cardColor = isSuccess ? Colors.green.shade50 : Colors.red.shade50;
    final Color borderColor = isSuccess ? Colors.green.shade400 : Colors.red.shade400;
    final String title = isSuccess ? 'Face Matched Successfully!' : 'Issues Detected';

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(isSuccess ? Icons.check_circle : Icons.warning, color: borderColor, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            _analysisResult ?? '',
            style: TextStyle(color: Colors.black87, height: 1.5),
          ),
          if (!isSuccess) ...[
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                _retakeRecording();
              },
              icon: Icon(Icons.refresh),
              label: Text('Retake Recording'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: Size(double.infinity, 48),
                textStyle: TextStyle(fontWeight: FontWeight.bold)
              ),
            ),
          ]
        ],
      ),
    );
  }

  // ** NEW WIDGET **
  Widget _buildDosAndDontsSection() {
    if (widget.dos.isEmpty && widget.donts.isEmpty) {
      return SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Key Points"),
        SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.dos.isNotEmpty)
            Expanded(
              child: _buildGuidelineList(
                "Do's",
                widget.dos,
                Icons.check_circle,
                Colors.green.shade400,
              ),
            ),
            if (widget.dos.isNotEmpty && widget.donts.isNotEmpty)
            SizedBox(width: 20),
            if (widget.donts.isNotEmpty)
            Expanded(
              child: _buildGuidelineList(
                "Don'ts",
                widget.donts,
                Icons.cancel,
                Colors.red.shade400,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  // ** NEW HELPER WIDGET **
  Widget _buildGuidelineList(String title, List<String> items, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 10),
              Expanded(child: Text(item, style: TextStyle(color: Colors.grey[700], height: 1.4))),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildObjectives() {
    return Column(
      children: widget.objectives
        .map((objective) => _buildObjectiveItem(objective))
        .toList(),
    );
  }

  Widget _buildObjectiveItem(String objective) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.task_alt, color: Theme.of(context).primaryColor, size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              objective,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // --- LOGIC METHODS (Unchanged functionality, minor additions like Haptic Feedback) ---
  
  void _toggleRecording() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const SimpleVideoRecorder()),
    );

    if (result != null && mounted) {
      PerformanceVideosManager().addVideo(result);
      setState(() {
        _recordedVideoPath = result;
      });
      await _initializeRecordedVideo();
      _startAnalysis();
    }
  }

  void _startAnalysis() async {
    if (!mounted) return;
    setState(() {
      _isAnalyzing = true;
      _hasRecording = true;
    });

    await Future.delayed(Duration(seconds: 3));

    bool hasMalpractice = DateTime.now().millisecond % 3 == 0;
    
    if (!mounted) return;
    setState(() {
      _isAnalyzing = false;
      _hasMalpractice = hasMalpractice;
      _analysisResult = hasMalpractice 
      ? 'Face not clearly visible or video quality issues detected. Please ensure good lighting and face is clearly visible throughout the recording.'
      : 'Face successfully recognized with clear visibility. AI analysis completed successfully.';
    });
  }

  void _retakeRecording() {
    if (!mounted) return;
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
    final Color primaryColor = Theme.of(context).primaryColor;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.tips_and_updates, color: primaryColor),
            SizedBox(width: 10),
            Text('Recording Tips', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTipItem('Ensure good, bright lighting on your face.', Icons.lightbulb_outline, primaryColor),
            _buildTipItem('Keep the camera steady and at eye level.', Icons.videocam_outlined, primaryColor),
            _buildTipItem('Make sure your entire movement is in the frame.', Icons.zoom_out_map, primaryColor),
            _buildTipItem('Focus on proper form, not speed.', Icons.accessibility_new, primaryColor),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          SizedBox(width: 16),
          Expanded(child: Text(text, style: TextStyle(color: Colors.grey[700], height: 1.4))),
        ],
      ),
    );
  }
}