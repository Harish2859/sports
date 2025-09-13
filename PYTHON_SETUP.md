# Python Integration Setup Guide

This guide explains how to set up the Python fitness analysis integration with your Flutter sports app.

## Prerequisites

1. **Python 3.8+** installed on your system
2. **pip** package manager

## Installation Steps

### 1. Install Python Dependencies

Navigate to the project root and install the required packages:

```bash
cd python_reference
pip install -r requirements.txt
```

### 2. Test the Installation

Test the height assessment server:
```bash
python launcher.py server
```

Test the fitness tracker:
```bash
python launcher.py tracker
```

## How It Works

### Integration Flow

1. **Video Recording**: User records assessment video using Flutter camera
2. **AI Analysis**: User taps "AI Analysis" button to start Python fitness tracker
3. **Real-time Analysis**: Python app analyzes pose, counts sit-ups, measures form
4. **Height Assessment**: Estimates height and provides health recommendations
5. **Results Display**: Flutter app shows comprehensive analysis results

### Python Components

- **fitness_tracker.py**: Real-time pose detection and sit-up analysis
- **height_assessment_server.py**: Flask server for height analysis and recommendations
- **launcher.py**: Utility script to start services

### Flutter Integration

- **FitnessAnalysisService**: Communicates with Python services
- **AnalysisResultsWidget**: Displays analysis results
- **AssessmentScreen**: Main integration point

## Features

### Fitness Analysis
- Real-time pose detection using MediaPipe
- Sit-up counting with form analysis
- Performance scoring (0-10 scale)
- Cheat detection

### Height Assessment
- Computer vision height estimation
- Percentile calculations based on age/gender
- Health status assessment
- Personalized recommendations

## Troubleshooting

### Common Issues

1. **Python not found**: Ensure Python is in your system PATH
2. **Dependencies missing**: Run `pip install -r requirements.txt`
3. **Camera access**: Grant camera permissions to Python applications
4. **Server not starting**: Check if port 8000 is available

### Error Messages

- "Python analysis server not available": Install Python dependencies
- "Analysis failed": Check Python installation and dependencies
- "No analysis results found": Ensure fitness tracker completed successfully

## Usage Tips

1. **Good Lighting**: Ensure adequate lighting for pose detection
2. **Full Body Visible**: Keep entire body in camera frame
3. **Stable Position**: Minimize camera movement during analysis
4. **Follow Instructions**: The Python tracker provides real-time guidance

## Development Notes

- Python services run as separate processes
- Communication via HTTP API and JSON files
- Results are automatically loaded back into Flutter
- Services can be extended with additional analysis features