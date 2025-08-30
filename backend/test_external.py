#!/usr/bin/env python3

import requests
import json

def test_external_access():
    """Test external access to the backend"""
    print("🌐 Testing External Backend Access")
    print("="*50)
    
    # Test health endpoint
    try:
        print("🏥 Testing health endpoint...")
        response = requests.get('http://34.129.197.247:8080/health', timeout=10)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.json()}")
        
        if response.status_code == 200:
            print("✅ External access working!")
            return True
        else:
            print("❌ External access failed!")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_text_analysis_external():
    """Test text analysis via external access"""
    if not test_external_access():
        return
        
    print("\n📝 Testing AI Text Analysis...")
    print("="*50)
    
    payload = {
        "text": "I want to donate a red bicycle in excellent condition",
        "task": "categorize this donation item"
    }
    
    try:
        response = requests.post(
            'http://34.129.197.247:8080/analyze-text',
            headers={'Content-Type': 'application/json'},
            data=json.dumps(payload),
            timeout=30
        )
        
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            print("✅ AI Analysis Success!")
            print(f"Analysis: {result['result']['analysis'][:200]}...")
        else:
            print(f"❌ Analysis failed: {response.text}")
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_text_analysis_external()
    print("\n🎯 Your iOS app should now be able to connect!")
    print("   URL: http://34.129.197.247:8080")
