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
                "condition": "one of: Excellent, Good, Fair, Poor",
                "confidence": "confidence level from 0.0 to 1.0",
                "co2_savings": "estimated CO2 savings in kg when this item is donated vs thrown away",
                "co2_explanation": "brief explanation of the CO2 calculation"
            }
            
            For CO2 estimation, consider:
            - Manufacturing emissions avoided (someone reuses instead of buying new)
            - Disposal emissions avoided (item doesn't go to landfill)
            - Item condition impact on reuse potential
            - Typical production footprint for this category
            
            Base CO2 estimates on real lifecycle assessment data. Be conservative but realistic.
            
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

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('FLASK_DEBUG', 'False').lower() == 'true'
    app.run(host='0.0.0.0', port=port, debug=debug)
