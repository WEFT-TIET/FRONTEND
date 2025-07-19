#!/usr/bin/env python3
"""
Server startup script for WEFT backend with JWT authentication
"""

import uvicorn
import sys
import os

def main():
    print("🚀 Starting WEFT Backend Server...")
    print("📍 Server will be available at: http://localhost:8080")
    print("🔐 JWT Authentication enabled")
    print("🍪 Cookie-based token validation enabled")
    print("=" * 50)
    
    # Start the server
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8080,
        reload=True,
        log_level="info"
    )

if __name__ == "__main__":
    main() 