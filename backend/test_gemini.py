#!/usr/bin/env python3

import requests
import json
from PIL import Image, ImageDraw
import base64
import io

def create_test_image():
    """Create a simple test image of a book"""
    img = Image.new('RGB', (400, 300), color='white')
    draw = ImageDraw.Draw(img)
    
    # Draw a simple book shape
    draw.rectangle([100, 80, 300, 220], fill='blue', outline='black', width=3)
    draw.rectangle([105, 85, 295, 95], fill='darkblue')
    
    # Add some text to make it look like a book
    try:
        draw.text((200, 130), 'PYTHON', fill='white', anchor='mm')
        draw.text((200, 150), 'PROGRAMMING', fill='white', anchor='mm')
        draw.text((200, 170), 'GUIDE', fill='white', anchor='mm')
    except:
        # Fallback if anchor parameter not supported
        draw.text((150, 130), 'PYTHON', fill='white')
        draw.text((120, 150), 'PROGRAMMING', fill='white')
        draw.text((170, 170), 'GUIDE', fill='white')
    
    # Convert to base64
    buffer = io.BytesIO()
    img.save(buffer, format='JPEG')
    img_str = base64.b64encode(buffer.getvalue()).decode()
    
    return img_str

def test_image_analysis():
    """Test the image analysis endpoint"""
    print("🖼️  Testing Image Analysis with Gemini AI...")
    print("="*50)
    
    # Create test image
    print("📸 Creating test image of a book...")
    image_b64 = create_test_image()
    print(f"✅ Test image created (size: {len(image_b64)} chars)")
    
    # Prepare request
    payload = {
        "image": image_b64,
        "task": "categorize"
    }
    
    try:
        print("🤖 Sending image to Gemini AI for analysis...")
        response = requests.post(
            'http://localhost:8080/analyze-image',
            headers={'Content-Type': 'application/json'},
            data=json.dumps(payload),
            timeout=30
        )
        
        print(f"📡 Response status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print("🎉 SUCCESS! Gemini AI analysis:")
            print(json.dumps(result, indent=2))
            
            if result.get('success') and 'result' in result:
                analysis = result['result']
                if 'category' in analysis:
                    print(f"\n📂 Category: {analysis['category']}")
                    print(f"📝 Title: {analysis.get('title', 'N/A')}")
                    print(f"📄 Description: {analysis.get('description', 'N/A')}")
                    print(f"⭐ Condition: {analysis.get('condition', 'N/A')}")
                    print(f"🎯 Confidence: {analysis.get('confidence', 'N/A')}")
        else:
            print("❌ FAILED!")
            print(f"Error: {response.text}")
            
    except Exception as e:
        print(f"❌ ERROR: {str(e)}")

def test_text_analysis():
    """Test the text analysis endpoint"""
    print("\n📝 Testing Text Analysis with Gemini AI...")
    print("="*50)
    
    payload = {
        "text": "I want to donate a vintage wooden dining table. It seats 6 people and has some wear on the surface but all legs are sturdy.",
        "task": "categorize this donation item and suggest a title"
    }
    
    try:
        print("🤖 Sending text to Gemini AI for analysis...")
        response = requests.post(
            'http://localhost:8080/analyze-text',
            headers={'Content-Type': 'application/json'},
            data=json.dumps(payload),
            timeout=15
        )
        
        print(f"📡 Response status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print("🎉 SUCCESS! Gemini AI analysis:")
            print(f"Analysis: {result['result']['analysis']}")
        else:
            print("❌ FAILED!")
            print(f"Error: {response.text}")
            
    except Exception as e:
        print(f"❌ ERROR: {str(e)}")

if __name__ == "__main__":
    print("🚀 Testing Free Find Backend with Gemini AI")
    print("="*50)
    
    # Test text analysis first (simpler)
    test_text_analysis()
    
    # Test image analysis
    test_image_analysis()
    
    print("\n✅ Testing complete!")
