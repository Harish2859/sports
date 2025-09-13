# Kivy Fitness Tracker Integration - Build Instructions

## Prerequisites

1. **Python 3.9+** with pip
2. **Buildozer** for Android packaging
3. **Android SDK/NDK** (API 21+)
4. **Flutter** development environment

## Step 1: Install Dependencies

```bash
# Install Python dependencies
pip install kivy[base,media] opencv-python-headless mediapipe numpy buildozer

# Install Flutter dependencies
cd c:\flutter\sports
flutter pub get
```

## Step 2: Build Kivy APK

```bash
# Navigate to Kivy project
cd fitness_tracker_kivy

# Initialize buildozer (if not done)
buildozer init

# Build debug APK
buildozer android debug

# Install APK on device
adb install bin/fitnesstracker-1.0-arm64-v8a_armeabi-v7a-debug.apk
```

## Step 3: Update Android Manifest

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.CAMERA" />
```

## Step 4: Test Integration

1. **Build Flutter app**: `flutter run`
2. **Navigate to Assessment Screen**
3. **Record video** (optional)
4. **Tap "Take Assessment"** - launches Kivy app
5. **Complete 60-second assessment**:
   - 0-10s: Red countdown
   - 10-30s: Height estimation (stand upright)
   - 30-40s: Height result display
   - 40-60s: Sit-up analysis (perform sit-ups)
6. **Results automatically load** in Flutter app

## Assessment Flow

### Phase 1: Countdown (0-10s)
- Red countdown timer
- Get ready message

### Phase 2: Height Estimation (10-30s)
- Stand upright, full body visible
- Blue/cyan status indicators
- Height estimated around 165cm baseline

### Phase 3: Gap (30-40s)
- Height result displayed
- Prepare for sit-ups countdown

### Phase 4: Sit-up Analysis (40-60s)
- Perform sit-ups with good form
- Form bar: Red (<0.5), Yellow (0.5-0.8), Green (>0.8)
- Rep counting with cheat detection
- Score calculation (0-10)

## Troubleshooting

### Kivy App Issues
- **App won't launch**: Check package name `org.example.fitnesstracker`
- **Camera not working**: Grant camera permissions, try `index=1` in Camera
- **No skeleton overlay**: Center person in frame, good lighting
- **Height estimation off**: Adjust `165 / 0.8` multiplier in `estimate_height()`

### Flutter Integration Issues
- **Intent not found**: Verify APK installed and package name correct
- **Results not loading**: Check external storage permissions
- **JSON not found**: Ensure Kivy app completed full 60-second cycle

### Performance Issues
- **Slow processing**: Use `resolution=(320, 240)` in Camera
- **High CPU usage**: Set `model_complexity=1` in MediaPipe Pose
- **Memory issues**: Reduce frame processing rate

## File Locations

- **Kivy source**: `fitness_tracker_kivy/main.py`
- **Buildozer config**: `fitness_tracker_kivy/buildozer.spec`
- **Flutter integration**: `lib/screens/assessment_screen.dart`
- **Results JSON**: `/sdcard/blazepose_outputs.json`

## Debug Commands

```bash
# Check APK installation
adb shell pm list packages | grep fitness

# Monitor logs
adb logcat | grep -i fitness

# Pull results file
adb pull /sdcard/blazepose_outputs.json

# Check permissions
adb shell dumpsys package org.example.fitnesstracker | grep permission
```

## Expected Results

After successful assessment:
- **Sit-up count**: Number of completed reps
- **Form score**: 0.0-1.0 (quality of movement)
- **Overall score**: 0-10 (performance rating)
- **Height estimate**: ~165cm (adjustable)
- **Analysis data**: Complete JSON with frame-by-frame data