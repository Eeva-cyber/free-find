#!/bin/bash

# Free Find Backend Startup Script

echo "🚀 Starting Free Find Backend..."

# Check if we're in the backend directory
if [ ! -f "app.py" ]; then
    echo "❌ Error: app.py not found. Please run this script from the backend directory."
    exit 1
fi

# Check if virtual environment exists, create if not
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "📚 Installing dependencies..."
pip install -r requirements.txt

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "⚠️  Warning: .env file not found. Please create one from .env.example"
    echo "   You can copy the example file: cp .env.example .env"
    echo "   Then edit .env with your Google Cloud project details."
    echo ""
    echo "   For now, the server will start but Gemini AI features won't work."
    echo ""
fi

echo "🌟 Starting Flask server..."
echo "   Backend will be available at: http://localhost:5000"
echo "   Health check: http://localhost:5000/health"
echo ""
echo "   Press Ctrl+C to stop the server"
echo ""

# Start the Flask app
python app.py
