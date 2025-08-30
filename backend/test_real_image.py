#!/usr/bin/env python3

import requests
import json
import base64
import os

def test_with_real_image(image_path):
    """Test the image analysis endpoint with a real image file"""
    print(f"🖼️  Testing Image Analysis with: {image_path}")
    print("="*60)
    
    # Check if file exists
    if not os.path.exists(image_path):
        print(f"❌ Error: File {image_path} not found!")
        return
    
    try:
        # Read and encode the image
        print("📸 Reading and encoding image...")
        with open(image_path, 'rb') as image_file:
            image_data = base64.b64encode(image_file.read()).decode('utf-8')
        
        file_size = len(image_data)
        print(f"✅ Image loaded successfully (base64 size: {file_size:,} chars)")
        
        # Prepare request
        payload = {
            "image": image_data,
            "task": "categorize"
        }
        
        print("🤖 Sending image to Gemini AI for analysis...")
        print("⏳ This may take 10-30 seconds...")
        
        # Send request
        response = requests.post(
            'http://localhost:8080/analyze-image',
            headers={'Content-Type': 'application/json'},
            data=json.dumps(payload),
            timeout=60  # Increased timeout for real images
        )
        
        print(f"📡 Response status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print("🎉 SUCCESS! Gemini AI analysis:")
            print("="*40)
            print(json.dumps(result, indent=2))
            
            # Extract and display key information
            if result.get('success') and 'result' in result:
                analysis = result['result']
                print("\n📋 ANALYSIS SUMMARY:")
                print("="*40)
                
                if isinstance(analysis, dict):
                    category = analysis.get('category', 'N/A')
                    title = analysis.get('title', 'N/A')
                    description = analysis.get('description', 'N/A')
                    condition = analysis.get('condition', 'N/A')
                    confidence = analysis.get('confidence', 'N/A')
                    
                    print(f"📂 Category: {category}")
                    print(f"📝 Title: {title}")
                    print(f"📄 Description: {description}")
                    print(f"⭐ Condition: {condition}")
                    print(f"🎯 Confidence: {confidence}")
                    
                    # Check if it matches expected categories
                    valid_categories = ["Furniture", "Clothing", "Electronics", "Books", "Toys", "Kitchenware", "Sports & Outdoors", "Other"]
                    if category in valid_categories:
                        print(f"✅ Category '{category}' is valid for your app!")
                    else:
                        print(f"⚠️  Category '{category}' might need mapping to: {', '.join(valid_categories)}")
                else:
                    print("Raw response:", analysis)
        else:
            print("❌ FAILED!")
            try:
                error_data = response.json()
                print(f"Error details: {json.dumps(error_data, indent=2)}")
            except:
                print(f"Raw error: {response.text}")
            
    except requests.exceptions.Timeout:
        print("❌ TIMEOUT: Request took too long. This might happen with large images.")
    except Exception as e:
        print(f"❌ ERROR: {str(e)}")

def test_health_first():
    """Test if the server is running"""
    print("🏥 Checking server health...")
    try:
        response = requests.get('http://localhost:8080/health', timeout=5)
        if response.status_code == 200:
            print("✅ Server is running!")
            return True
        else:
            print(f"❌ Server responded with status {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Cannot connect to server: {e}")
        return False

if __name__ == "__main__":
    print("🚀 Testing Free Find Backend with Real Image")
    print("="*60)
    
    # First check if server is running
    if not test_health_first():
        print("\n💡 Make sure your server is running:")
        print("   cd /home/sihanren409/free-find/backend")
        print("   source venv/bin/activate")
        print("   PORT=8080 python app_genai.py")
        exit(1)
    
    # Test with the real image
    image_path = "test.png"
    test_with_real_image(image_path)
    
    print("\n✅ Testing complete!")
