import requests
import base64
import json

def test_health():
    """Test the health endpoint"""
    try:
        response = requests.get('http://localhost:5000/health')
        print(f"Health Check: {response.status_code}")
        print(f"Response: {response.json()}")
        return response.status_code == 200
    except Exception as e:
        print(f"Health check failed: {e}")
        return False

def test_image_analysis(image_path):
    """Test image analysis with a local image file"""
    try:
        # Read and encode image
        with open(image_path, 'rb') as image_file:
            image_data = base64.b64encode(image_file.read()).decode('utf-8')
        
        # Prepare request
        payload = {
            "image": image_data,
            "task": "categorize"
        }
        
        # Send request
        response = requests.post(
            'http://localhost:5000/analyze-image',
            headers={'Content-Type': 'application/json'},
            data=json.dumps(payload),
            timeout=30
        )
        
        print(f"Image Analysis: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        return response.status_code == 200
        
    except Exception as e:
        print(f"Image analysis test failed: {e}")
        return False

def test_text_analysis():
    """Test text analysis"""
    try:
        payload = {
            "text": "I have a wooden chair that I want to donate. It's in good condition but has a small scratch on the back.",
            "task": "categorize and describe this donation item"
        }
        
        response = requests.post(
            'http://localhost:5000/analyze-text',
            headers={'Content-Type': 'application/json'},
            data=json.dumps(payload),
            timeout=15
        )
        
        print(f"Text Analysis: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        return response.status_code == 200
        
    except Exception as e:
        print(f"Text analysis test failed: {e}")
        return False

if __name__ == "__main__":
    print("Testing Free Find Backend API\n")
    
    # Test health endpoint
    print("1. Testing Health Endpoint:")
    health_ok = test_health()
    print()
    
    if not health_ok:
        print("Backend is not running. Please start the server first.")
        exit(1)
    
    # Test text analysis
    print("2. Testing Text Analysis:")
    test_text_analysis()
    print()
    
    # Test image analysis (you need to provide an image path)
    print("3. Testing Image Analysis:")
    print("To test image analysis, uncomment the line below and provide a valid image path:")
    print("# test_image_analysis('path/to/your/test/image.jpg')")
    # test_image_analysis('path/to/your/test/image.jpg')
    
    print("\nTesting complete!")
