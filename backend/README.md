# Free Find Backend

A simple Flask backend that integrates with Google's Gemini AI via Vertex AI to analyze images of donated items.

## Features

- **Image Analysis**: Upload images and get AI-powered categorization and descriptions
- **Text Analysis**: Process text with Gemini AI
- **CORS Enabled**: Ready for frontend integration
- **Health Check**: Simple endpoint to verify backend status

## Setup

### Prerequisites

1. Google Cloud Project with Vertex AI API enabled
2. Service account with Vertex AI permissions (or default credentials)
3. Python 3.8+

### Installation

1. **Install dependencies:**
   ```bash
   cd backend
   pip install -r requirements.txt
   ```

2. **Configure environment:**
   ```bash
   cp .env.example .env
   # Edit .env with your actual values
   ```

3. **Set up Google Cloud credentials:**
   
   Option A: Service Account Key File
   ```bash
   # Download your service account key and set the path in .env
   GOOGLE_APPLICATION_CREDENTIALS=path/to/your/key.json
   ```
   
   Option B: Default Credentials (if running on Google Cloud)
   ```bash
   gcloud auth application-default login
   ```

### Running the Server

```bash
cd backend
python app.py
```

The server will start on `http://localhost:5000`

## API Endpoints

### Health Check
```
GET /health
```
Returns server status.

### Image Analysis
```
POST /analyze-image
Content-Type: application/json

{
    "image": "base64_encoded_image_string",
    "task": "categorize"  // optional
}
```

**Response:**
```json
{
    "success": true,
    "task": "categorize",
    "result": {
        "category": "Electronics",
        "title": "Vintage Radio",
        "description": "A classic wooden radio in good condition",
        "condition": "Good",
        "confidence": 0.85
    }
}
```

### Text Analysis
```
POST /analyze-text
Content-Type: application/json

{
    "text": "text to analyze",
    "task": "optional task description"
}
```

## Frontend Integration

### Swift Example

```swift
func analyzeImage(_ imageData: Data) async {
    let base64Image = imageData.base64EncodedString()
    
    let requestBody = [
        "image": base64Image,
        "task": "categorize"
    ]
    
    guard let url = URL(string: "http://localhost:5000/analyze-image") else { return }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
    
    do {
        let (data, _) = try await URLSession.shared.data(for: request)
        // Handle response
    } catch {
        print("Error: \(error)")
    }
}
```

### JavaScript Example

```javascript
async function analyzeImage(imageBase64) {
    const response = await fetch('http://localhost:5000/analyze-image', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            image: imageBase64,
            task: 'categorize'
        })
    });
    
    return await response.json();
}
```

## Deployment

### Local Development
The server runs on port 5000 by default.

### Production
- Set `FLASK_DEBUG=False` in production
- Use a production WSGI server like Gunicorn
- Configure proper firewall rules
- Use HTTPS

### Docker (Optional)
```dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["python", "app.py"]
```

## Error Handling

The API returns appropriate HTTP status codes:
- `200`: Success
- `400`: Bad Request (invalid image, missing data)
- `500`: Server Error (AI model issues, processing errors)

## Security Notes

- The API accepts base64-encoded images to avoid file upload complexity
- CORS is enabled for development; configure appropriately for production
- Store service account keys securely
- Use environment variables for sensitive configuration
