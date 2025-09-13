from flask import Flask, request, jsonify
from flask_cors import CORS
import numpy as np
import json
from datetime import datetime
import logging

app = Flask(__name__)
CORS(app)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Standard height data (WHO/CDC growth charts simplified)
HEIGHT_STANDARDS = {
    'male': {
        18: {'percentiles': [160.0, 165.0, 170.0, 175.0, 180.0, 185.0, 190.0]},  # 5th, 10th, 25th, 50th, 75th, 90th, 95th
        25: {'percentiles': [162.0, 167.0, 172.0, 177.0, 182.0, 187.0, 192.0]},
        30: {'percentiles': [162.0, 167.0, 172.0, 177.0, 182.0, 187.0, 192.0]},
        35: {'percentiles': [161.0, 166.0, 171.0, 176.0, 181.0, 186.0, 191.0]},
    },
    'female': {
        18: {'percentiles': [150.0, 155.0, 160.0, 165.0, 170.0, 175.0, 180.0]},
        25: {'percentiles': [152.0, 157.0, 162.0, 167.0, 172.0, 177.0, 182.0]},
        30: {'percentiles': [152.0, 157.0, 162.0, 167.0, 172.0, 177.0, 182.0]},
        35: {'percentiles': [151.0, 156.0, 161.0, 166.0, 171.0, 176.0, 181.0]},
    }
}

def calculate_percentile(height, age, gender):
    """Calculate height percentile based on age and gender"""
    try:
        gender = gender.lower()
        if gender not in HEIGHT_STANDARDS:
            gender = 'male'  # Default fallback
        
        # Find closest age group
        age_groups = sorted(HEIGHT_STANDARDS[gender].keys())
        closest_age = min(age_groups, key=lambda x: abs(x - age))
        
        percentiles = HEIGHT_STANDARDS[gender][closest_age]['percentiles']
        
        # Calculate percentile
        if height <= percentiles[0]:
            return 5.0
        elif height <= percentiles[1]:
            return 10.0
        elif height <= percentiles[2]:
            return 25.0
        elif height <= percentiles[3]:
            return 50.0
        elif height <= percentiles[4]:
            return 75.0
        elif height <= percentiles[5]:
            return 90.0
        else:
            return 95.0
            
    except Exception as e:
        logger.error(f"Error calculating percentile: {e}")
        return 50.0  # Default to median

def categorize_height(percentile):
    """Categorize height based on percentile"""
    if percentile < 10:
        return "Below Average"
    elif percentile < 25:
        return "Low Average"
    elif percentile < 75:
        return "Average"
    elif percentile < 90:
        return "High Average"
    else:
        return "Above Average"

def assess_health_status(percentile, height, age, gender):
    """Assess if height is within healthy range"""
    # Generally, 3rd to 97th percentile is considered normal
    return 3.0 <= percentile <= 97.0

def generate_recommendations(category, percentile, height, age, gender):
    """Generate personalized recommendations"""
    recommendations = []
    
    if category == "Below Average":
        recommendations.extend([
            "Ensure adequate nutrition with protein, calcium, and vitamin D",
            "Maintain good posture throughout the day",
            "Consider consulting a healthcare provider for growth assessment",
            "Focus on bone health with weight-bearing exercises",
            "Ensure adequate sleep (7-9 hours) for growth hormone production"
        ])
    elif category == "Low Average":
        recommendations.extend([
            "Maintain balanced nutrition for optimal health",
            "Practice good posture habits",
            "Stay physically active with regular exercise",
            "Monitor growth if still in growing years"
        ])
    elif category == "Average":
        recommendations.extend([
            "Continue current healthy lifestyle habits",
            "Maintain balanced nutrition and regular exercise",
            "Focus on overall fitness and well-being",
            "Practice good posture for spinal health"
        ])
    elif category == "High Average":
        recommendations.extend([
            "Maintain excellent health habits",
            "Ensure proper ergonomics in daily activities",
            "Continue balanced nutrition and exercise",
            "Monitor posture, especially if experiencing growth spurts"
        ])
    else:  # Above Average
        recommendations.extend([
            "Pay special attention to posture and spinal alignment",
            "Ensure proper ergonomics in workspace and daily activities",
            "Consider sports and activities suitable for your height",
            "Maintain flexibility through stretching and yoga",
            "Be mindful of doorways and low-hanging objects"
        ])
    
    # Age-specific recommendations
    if age < 25:
        recommendations.append("Growth may still continue - maintain healthy habits")
    elif age > 50:
        recommendations.append("Focus on bone density maintenance with calcium and exercise")
    
    return recommendations

def calculate_confidence(height_estimates):
    """Calculate confidence based on measurement consistency"""
    if len(height_estimates) < 3:
        return 0.6
    
    std_dev = np.std(height_estimates)
    mean_height = np.mean(height_estimates)
    
    # Lower standard deviation = higher confidence
    coefficient_of_variation = std_dev / mean_height if mean_height > 0 else 1.0
    
    # Convert to confidence score (0-1)
    confidence = max(0.5, 1.0 - (coefficient_of_variation * 10))
    return min(1.0, confidence)

@app.route('/analyze_height', methods=['POST'])
def analyze_height():
    """Main endpoint for height analysis"""
    try:
        data = request.get_json()
        
        # Extract data
        estimated_height = data.get('estimated_height', 0.0)
        height_estimates = data.get('height_estimates', [])
        age = data.get('age', 25)
        gender = data.get('gender', 'male')
        
        logger.info(f"Analyzing height: {estimated_height}cm, Age: {age}, Gender: {gender}")
        
        # Validate input
        if estimated_height < 100 or estimated_height > 250:
            return jsonify({
                'error': 'Invalid height measurement',
                'message': 'Height must be between 100-250 cm'
            }), 400
        
        # Calculate final height (use median of estimates if available)
        if len(height_estimates) > 0:
            final_height = np.median(height_estimates)
        else:
            final_height = estimated_height
        
        # Perform analysis
        percentile = calculate_percentile(final_height, age, gender)
        category = categorize_height(percentile)
        is_healthy = assess_health_status(percentile, final_height, age, gender)
        recommendations = generate_recommendations(category, percentile, final_height, age, gender)
        confidence = calculate_confidence(height_estimates)
        
        # Prepare response
        result = {
            'estimated_height': round(final_height, 1),
            'category': category,
            'percentile': round(percentile, 1),
            'is_healthy': is_healthy,
            'recommendations': recommendations,
            'confidence': round(confidence, 2),
            'analysis_details': {
                'measurement_count': len(height_estimates),
                'height_range': {
                    'min': round(min(height_estimates), 1) if height_estimates else final_height,
                    'max': round(max(height_estimates), 1) if height_estimates else final_height,
                    'std_dev': round(np.std(height_estimates), 2) if len(height_estimates) > 1 else 0.0
                },
                'age_group': age,
                'gender': gender,
                'timestamp': datetime.now().isoformat()
            }
        }
        
        logger.info(f"Analysis complete: {category}, {percentile}th percentile")
        return jsonify(result)
        
    except Exception as e:
        logger.error(f"Error in height analysis: {e}")
        return jsonify({
            'error': 'Analysis failed',
            'message': str(e)
        }), 500

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'Height Assessment API',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/standards', methods=['GET'])
def get_standards():
    """Get height standards for reference"""
    return jsonify({
        'height_standards': HEIGHT_STANDARDS,
        'description': 'Height percentiles by age and gender (cm)'
    })

if __name__ == '__main__':
    logger.info("Starting Height Assessment Server...")
    app.run(host='0.0.0.0', port=8000, debug=True)