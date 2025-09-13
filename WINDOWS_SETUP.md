# Windows Setup Instructions

## Install Required Tools

### 1. Install Python and Dependencies
```powershell
# Install Python 3.9+ from python.org
# Then install packages
pip install kivy[base,media] opencv-python-headless mediapipe numpy
pip install buildozer
```

### 2. Install Android SDK/NDK
```powershell
# Download Android Studio from developer.android.com
# Install Android SDK (API 33) and NDK (25b)
# Add to PATH:
$env:ANDROID_HOME = "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"
$env:PATH += ";$env:ANDROID_HOME\platform-tools"
```

### 3. Install WSL2 for Buildozer (Required)
```powershell
# Enable WSL2
wsl --install
# Restart computer
# Install Ubuntu from Microsoft Store
```

## Build Kivy APK (Use WSL2)

```bash
# In WSL2 Ubuntu terminal
sudo apt update
sudo apt install -y python3-pip openjdk-11-jdk unzip
pip3 install buildozer cython

# Copy project to WSL
cp -r /mnt/c/flutter/sports/fitness_tracker_kivy ~/
cd ~/fitness_tracker_kivy

# Build APK
buildozer android debug
```

## Install APK (Use Windows PowerShell)

```powershell
# Enable Developer Options on Android device
# Enable USB Debugging
# Connect device via USB

# Install ADB (if not installed with Android Studio)
# Download platform-tools from developer.android.com
# Extract to C:\platform-tools
$env:PATH += ";C:\platform-tools"

# Install APK
adb devices
adb install ~/fitness_tracker_kivy/bin/fitnesstracker-1.0-arm64-v8a_armeabi-v7a-debug.apk
```

## Alternative: Use Pre-built APK

Since buildozer requires Linux, here's a simplified approach:

### Create Mock Assessment (Testing Only)
```dart
// Replace _startKivyAssessment method in assessment_screen.dart
Future<void> _startKivyAssessment() async {
  setState(() => _isAnalyzing = true);
  
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Mock assessment started (60 seconds)'),
      backgroundColor: Colors.blue,
    ),
  );
  
  await Future.delayed(const Duration(seconds: 5)); // Shortened for testing
  
  // Create mock results
  final mockResults = {
    'sit_up_count': 8,
    'form_score': 0.75,
    'score_out_of_10': 7.5,
    'estimated_height_cm': 165.0,
    'total_frames': 1800,
    'analysis_complete': true,
  };
  
  setState(() {
    _analysisResults = mockResults;
    _isAnalyzing = false;
  });
  
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Mock assessment completed!'),
      backgroundColor: Colors.green,
    ),
  );
}
```

## Test Flutter App

```powershell
cd C:\flutter\sports
flutter pub get
flutter run
```

## Production Build Steps

1. **Use Linux VM or WSL2** for buildozer
2. **Build APK** in Linux environment
3. **Transfer APK** to Windows
4. **Install via ADB** on Android device
5. **Test integration** with Flutter app

## Troubleshooting

- **Buildozer not found**: Use WSL2 or Linux VM
- **ADB not found**: Install Android Studio or platform-tools
- **Device not detected**: Enable USB debugging, install drivers
- **APK install fails**: Check device compatibility (API 21+)