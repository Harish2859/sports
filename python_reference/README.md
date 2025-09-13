# Height Assessment Python Server

This Python server provides height assessment services for the Flutter sports app using standard growth charts and WHO/CDC data.

## Setup

1. Install required dependencies:
```bash
pip install flask flask-cors numpy
```

2. Run the server:
```bash
python height_assessment_server.py
```

The server will start on `http://localhost:8000`

## API Endpoints

### POST /analyze_height
Analyzes height measurements and provides assessment based on age and gender.

**Request Body:**
```json
{
  "estimated_height": 175.5,
  "height_estimates": [174.2, 175.8, 175.1],
  "age": 25,
  "gender": "male"
}
```

**Response:**
```json
{
  "estimated_height": 175.1,
  "category": "Average",
  "percentile": 50.0,
  "is_healthy": true,
  "recommendations": [
    "Continue current healthy lifestyle habits",
    "Maintain balanced nutrition and regular exercise"
  ],
  "confidence": 0.92,
  "analysis_details": {
    "measurement_count": 3,
    "height_range": {
      "min": 174.2,
      "max": 175.8,
      "std_dev": 0.81
    }
  }
}
```

### GET /health
Health check endpoint.

### GET /standards
Returns height standards data for reference.

## Height Categories

- **Below Average**: < 10th percentile
- **Low Average**: 10th - 25th percentile  
- **Average**: 25th - 75th percentile
- **High Average**: 75th - 90th percentile
- **Above Average**: > 90th percentile

## Integration with Flutter

The Flutter app automatically tries to connect to the Python server. If the server is unavailable, it falls back to local assessment using simplified standards.

To use with the Flutter app:
1. Start the Python server
2. Ensure your device/emulator can reach `localhost:8000`
3. The app will automatically use the server for height assessments

## Customization

You can modify the `HEIGHT_STANDARDS` dictionary to use different growth charts or add more age groups and genders as needed.