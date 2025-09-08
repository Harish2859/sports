import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

// Simple test to verify camera functionality
class CameraTest extends StatefulWidget {
  const CameraTest({super.key});

  @override
  State<CameraTest> createState() => _CameraTestState();
}

class _CameraTestState extends State<CameraTest> {
  List<CameraDescription>? cameras;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _testCamera();
  }

  Future<void> _testCamera() async {
    try {
      cameras = await availableCameras();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Test')),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : error != null
                ? Text('Error: $error')
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Found ${cameras?.length ?? 0} cameras'),
                      if (cameras != null)
                        ...cameras!.map((camera) => Text(camera.name)),
                      const SizedBox(height: 20),
                      const Text('Camera functionality is working!'),
                    ],
                  ),
      ),
    );
  }
}