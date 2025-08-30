from flask import Flask, request, jsonify
from flask_cors import CORS
import base64
import io
from PIL import Image
from google import genai
from google.genai import types
import os
from dotenv import load_dotenv
import json

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app)  # Enable CORS for frontend requests

# Initialize Google GenAI client
def initialize_genai():
    """Initialize Google GenAI client with your project settings"""
    project_id = os.getenv('GOOGLE_CLOUD_PROJECT_ID', 'utility-canto-469303-v9')
    location = os.getenv('GOOGLE_CLOUD_LOCATION', 'global')
    
    try:
        client = genai.Client(
            vertexai=True,
            project=project_id,
            location=location,
        )
        return client
    except Exception as e:
        print(f"Error initializing GenAI client: {e}")
        return None

# Initialize GenAI when app starts
try:
    genai_client = initialize_genai()
    model_name = "gemini-2.0-flash-exp"
    print("Google GenAI initialized successfully")
except Exception as e:
    print(f"Warning: Google GenAI initialization failed: {e}")
    genai_client = None

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
        # Check if client is initialized
        if genai_client is None:
            return jsonify({
                "error": "Gemini AI client not initialized. Please check your configuration."
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

        # Prepare the image for GenAI
        img_byte_arr = io.BytesIO()
        image.save(img_byte_arr, format='JPEG')
        img_byte_arr = img_byte_arr.getvalue()
        
        # Encode image as base64 for GenAI
        image_b64 = base64.b64encode(img_byte_arr).decode('utf-8')

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
                "confidence": "confidence level from 0.0 to 1.0"
            }
            
            Be accurate and helpful. If you're unsure about the category, use "Other" and explain in the description.
            Only return the JSON, no other text.
            """
        else:
            prompt = data.get('custom_prompt', 'Describe what you see in this image.')

        # Create content for GenAI
        contents = [
            types.Content(
                role="user",
                parts=[
                    types.Part.from_text(prompt),
                    types.Part.from_bytes(
                        data=img_byte_arr,
                        mime_type="image/jpeg"
                    )
                ]
            )
        ]

        # Configure generation
        generate_config = types.GenerateContentConfig(
            temperature=0.7,
            top_p=0.95,
            max_output_tokens=8192,
        )

        # Generate content using GenAI
        try:
            response = genai_client.models.generate_content(
                model=model_name,
                contents=contents,
                config=generate_config,
            )
            
            if response.text:
                # Try to parse as JSON if it's a categorization task
                if task == 'categorize':
                    try:
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
        if genai_client is None:
            return jsonify({
                "error": "Gemini AI client not initialized. Please check your configuration."
            }), 500

        data = request.get_json()
        if not data or 'text' not in data:
            return jsonify({"error": "No text data provided"}), 400

        text = data['text']
        task = data.get('task', 'analyze')
        
        prompt = f"Task: {task}\n\nText to analyze: {text}\n\nPlease provide a helpful analysis or response."
        
        # Create content for GenAI
        contents = [
            types.Content(
                role="user",
                parts=[
                    types.Part.from_text(prompt)
                ]
            )
        ]

        # Configure generation
        generate_config = types.GenerateContentConfig(
            temperature=0.7,
            top_p=0.95,
            max_output_tokens=8192,
        )
        
        response = genai_client.models.generate_content(
            model=model_name,
            contents=contents,
            config=generate_config,
        )
        
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
