from flask import Flask, request, jsonify
from flask_cors import CORS
import base64
import io
from PIL import Image
import vertexai
from vertexai.preview.generative_models import GenerativeModel, Part
import os
from google.oauth2 import service_account
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

app = Flask(__name__)
CORS(app)  # Enable CORS for frontend requests

# Initialize Vertex AI
def initialize_vertex_ai():
    """Initialize Vertex AI with your project settings"""
    project_id = os.getenv('GOOGLE_CLOUD_PROJECT_ID', 'your-project-id')
    location = os.getenv('GOOGLE_CLOUD_LOCATION', 'us-central1')
    
    # If using service account key file
    credentials_path = os.getenv('GOOGLE_APPLICATION_CREDENTIALS')
    if credentials_path:
        credentials = service_account.Credentials.from_service_account_file(credentials_path)
        vertexai.init(project=project_id, location=location, credentials=credentials)
    else:
        # For local development or if using default credentials
        vertexai.init(project=project_id, location=location)

# Initialize Vertex AI when app starts
try:
    initialize_vertex_ai()
    # Allow overriding the model name via env var; default to the requested newer model
    model_name = os.getenv('GEMINI_MODEL_NAME', 'gemini-2.5-flash')
    try:
        model = GenerativeModel(model_name)
        print(f"Vertex AI initialized successfully with model: {model_name}")
    except Exception as model_err:
        # Fallback to previous stable version if the requested model isn't available
        fallback_model = 'gemini-1.5-flash'
        print(f"Primary model '{model_name}' unavailable ({model_err}); attempting fallback '{fallback_model}'")
        try:
            model = GenerativeModel(fallback_model)
            print(f"Fallback model '{fallback_model}' initialized successfully")
        except Exception as fb_err:
            print(f"Warning: Both primary and fallback model initialization failed: {fb_err}")
            model = None
except Exception as e:
    print(f"Warning: Vertex AI initialization failed before model selection: {e}")
    model = None

@app.route('/health', methods=['GET'])
def health_check():
    """Simple health check endpoint"""
    return jsonify({"status": "healthy", "message": "Backend is running"})

@app.route('/analyze-image', methods=['POST'])
def analyze_image():
    """
    Analyze an image using Gemini AI to categorize donation items
    Expected request format:
    {
        "image": "base64_encoded_image_string",
        "task": "categorize" // optional, defaults to categorize
    }
    """
    try:
        # Check if model is initialized
        if model is None:
            return jsonify({
                "error": "Gemini AI model not initialized. Please check your Vertex AI configuration."
            }), 500

        # Get request data
        data = request.get_json()
        if not data or 'image' not in data:
            return jsonify({"error": "No image data provided"}), 400

        # Decode base64 image
        try:
            image_data = base64.b64decode(data['image'])
            image = Image.open(io.BytesIO(image_data))
            
            # Convert to RGB if necessary
            if image.mode != 'RGB':
                image = image.convert('RGB')
                
        except Exception as e:
            return jsonify({"error": f"Invalid image data: {str(e)}"}), 400

        # Prepare the image for Vertex AI
        img_byte_arr = io.BytesIO()
        image.save(img_byte_arr, format='JPEG')
        img_byte_arr = img_byte_arr.getvalue()

        # Create the image part for Gemini
        image_part = Part.from_data(
            mime_type="image/jpeg",
            data=img_byte_arr
        )

        # Get task type (default to categorize)
        task = data.get('task', 'categorize')
        
        # Create prompt based on task
        if task == 'categorize':
            prompt = """
            Analyze this image of a donated item and provide the following information in JSON format:
            
            {
                "category": "one of: Furniture, Clothing, Electronics, Books, Toys, Kitchenware, Sports & Outdoors, Other",
                "title": "suggested title for the item",
                "description": "brief description of the item",
                "condition": "one of: New, Like New, Good, Fair, Poor",
                "confidence": "confidence level from 0.0 to 1.0"
            }
            
            Be accurate and helpful. If you're unsure about the category, use "Other" and explain in the description.
            """
        else:
            prompt = data.get('custom_prompt', 'Describe what you see in this image.')

        # Generate content using Gemini
        try:
            response = model.generate_content([prompt, image_part])
            
            if response.text:
                # Try to parse as JSON if it's a categorization task
                if task == 'categorize':
                    try:
                        import json
                        # Clean the response text (remove markdown formatting if present)
                        clean_text = response.text.strip()
                        if clean_text.startswith('```json'):
                            clean_text = clean_text[7:]
                        if clean_text.endswith('```'):
                            clean_text = clean_text[:-3]
                        
                        result = json.loads(clean_text.strip())
                        return jsonify({
                            "success": True,
                            "task": task,
                            "result": result
                        })
                    except json.JSONDecodeError:
                        # If JSON parsing fails, return raw text
                        return jsonify({
                            "success": True,
                            "task": task,
                            "result": {
                                "raw_response": response.text,
                                "note": "Could not parse as JSON, returning raw response"
                            }
                        })
                else:
                    return jsonify({
                        "success": True,
                        "task": task,
                        "result": {
                            "description": response.text
                        }
                    })
            else:
                return jsonify({"error": "No response from Gemini AI"}), 500
                
        except Exception as e:
            return jsonify({"error": f"Gemini AI processing failed: {str(e)}"}), 500

    except Exception as e:
        return jsonify({"error": f"Unexpected error: {str(e)}"}), 500

@app.route('/analyze-text', methods=['POST'])
def analyze_text():
    """
    Analyze text using Gemini AI
    Expected request format:
    {
        "text": "text to analyze",
        "task": "optional task description"
    }
    """
    try:
        if model is None:
            return jsonify({
                "error": "Gemini AI model not initialized. Please check your Vertex AI configuration."
            }), 500

        data = request.get_json()
        if not data or 'text' not in data:
            return jsonify({"error": "No text data provided"}), 400

        text = data['text']
        task = data.get('task', 'analyze')
        
        prompt = f"Task: {task}\n\nText to analyze: {text}\n\nPlease provide a helpful analysis or response."
        
        response = model.generate_content(prompt)
        
        if response.text:
            return jsonify({
                "success": True,
                "task": task,
                "result": {
                    "analysis": response.text
                }
            })
        else:
            return jsonify({"error": "No response from Gemini AI"}), 500
            
    except Exception as e:
        return jsonify({"error": f"Unexpected error: {str(e)}"}), 500

@app.route('/estimate-co2', methods=['POST'])
def estimate_co2():
    """
    Estimate CO2 savings for a donated item using Gemini AI
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({"error": "No JSON data provided"}), 400
        
        category = data.get('category', '')
        condition = data.get('condition', '')
        title = data.get('title', '')
        description = data.get('description', '')
        
        if not category or not condition:
            return jsonify({"error": "Category and condition are required"}), 400
        
        # Create a comprehensive prompt for CO2 estimation
        prompt = f"""
You are an expert environmental analyst specializing in carbon footprint calculations and lifecycle assessments. 

Please estimate the CO2 savings (in kilograms) when someone donates this item instead of throwing it away and someone else reuses it instead of buying new:

Item Details:
- Category: {category}
- Condition: {condition}
- Title: {title}
- Description: {description}

Consider these factors in your estimation:
1. Manufacturing emissions avoided (someone reuses instead of buying new)
2. Disposal emissions avoided (item doesn't go to landfill/incineration)
3. Transportation savings (local reuse vs new manufacturing/shipping)
4. Item condition impact on reuse potential

Please provide:
1. CO2 savings estimate in kilograms (be realistic and research-based)
2. Brief explanation of your calculation methodology
3. Confidence level (0-1)

Respond in this exact JSON format:
{{
    "co2_savings": [number in kg],
    "unit": "kg",
    "confidence": [0-1],
    "explanation": "[brief explanation]",
    "methodology": "[calculation approach]"
}}

Base your estimates on real lifecycle assessment data for similar products. Be conservative but accurate.
"""

        if model is None:
            # Fallback calculation if Gemini is unavailable
            fallback_savings = calculate_fallback_co2(category, condition)
            return jsonify({
                "success": True,
                "result": {
                    "co2_savings": fallback_savings,
                    "unit": "kg",
                    "confidence": 0.7,
                    "explanation": "Fallback calculation based on category averages",
                    "methodology": "Local estimation using category-based averages"
                }
            })

        # Generate CO2 estimation using Gemini
        response = model.generate_content(prompt)
        
        if response and response.text:
            try:
                # Try to extract JSON from the response
                import json
                import re
                
                # Find JSON in the response
                json_match = re.search(r'\{[^}]+\}', response.text)
                if json_match:
                    result_data = json.loads(json_match.group())
                    
                    # Validate the response structure
                    if 'co2_savings' in result_data:
                        return jsonify({
                            "success": True,
                            "result": result_data
                        })
                
                # If JSON parsing fails, use fallback
                fallback_savings = calculate_fallback_co2(category, condition)
                return jsonify({
                    "success": True,
                    "result": {
                        "co2_savings": fallback_savings,
                        "unit": "kg",
                        "confidence": 0.6,
                        "explanation": f"AI response: {response.text[:100]}...",
                        "methodology": "Gemini AI analysis with fallback calculation"
                    }
                })
                
            except json.JSONDecodeError:
                # Fallback if JSON parsing fails
                fallback_savings = calculate_fallback_co2(category, condition)
                return jsonify({
                    "success": True,
                    "result": {
                        "co2_savings": fallback_savings,
                        "unit": "kg",
                        "confidence": 0.6,
                        "explanation": "AI analysis with fallback calculation",
                        "methodology": "Gemini AI with local fallback"
                    }
                })
        else:
            # Fallback if no response from Gemini
            fallback_savings = calculate_fallback_co2(category, condition)
            return jsonify({
                "success": True,
                "result": {
                    "co2_savings": fallback_savings,
                    "unit": "kg",
                    "confidence": 0.7,
                    "explanation": "Fallback calculation used",
                    "methodology": "Local estimation"
                }
            })
            
    except Exception as e:
        return jsonify({"success": False, "error": f"CO2 estimation error: {str(e)}"}), 500

def calculate_fallback_co2(category, condition):
    """
    Fallback CO2 calculation based on category and condition
    """
    # Base CO2 footprints by category (kg CO2e)
    category_footprints = {
        'electronics': 150.0,
        'furniture': 80.0,
        'clothing': 25.0,
        'kitchenware': 15.0,
        'sports & outdoors': 20.0,
        'toys': 10.0,
        'books': 2.5,
        'other': 15.0
    }
    
    # Condition multipliers
    condition_multipliers = {
        'excellent': 1.0,
        'good': 0.85,
        'fair': 0.65,
        'poor': 0.4
    }
    
    # Get base footprint
    base_co2 = category_footprints.get(category.lower(), 15.0)
    
    # Get condition multiplier
    condition_mult = condition_multipliers.get(condition.lower(), 0.7)
    
    # Calculate savings (80% of production emissions avoided)
    savings_percentage = 0.8
    
    return base_co2 * condition_mult * savings_percentage

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('FLASK_DEBUG', 'False').lower() == 'true'
    app.run(host='0.0.0.0', port=port, debug=debug)
