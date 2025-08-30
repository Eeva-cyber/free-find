#!/bin/bash

echo "🔥 Free Find Backend Quick Test"
echo "================================"

# Kill any existing processes
echo "🧹 Cleaning up existing processes..."
pkill -f "python.*app.py" 2>/dev/null || true
sleep 2

# Navigate to backend directory
cd /home/sihanren409/free-find/backend

# Activate virtual environment
source venv/bin/activate

# Set port to 8080
export PORT=8080

# Start server in background
echo "🚀 Starting server on port 8080..."
python app.py &
SERVER_PID=$!

# Wait for server to start
echo "⏳ Waiting for server to start..."
sleep 5

# Test health endpoint
echo "🏥 Testing health endpoint..."
RESPONSE=$(curl -s http://localhost:8080/health)
echo "Response: $RESPONSE"

# Test external access
echo ""
echo "🌐 Your backend is running at:"
echo "   Internal: http://localhost:8080"
echo "   External: http://$(curl -s http://ipinfo.io/ip):8080"
echo ""
echo "📱 Update your iOS app to use: http://$(curl -s http://ipinfo.io/ip):8080"
echo ""
echo "🔧 To stop the server later, run: kill $SERVER_PID"
echo "   Or use: pkill -f 'python.*app.py'"
echo ""
echo "✅ Backend is ready for your iOS app!"
