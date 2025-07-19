# WEFT Backend Server

## Overview

This is the FastAPI backend server for the WEFT Flutter application with JWT authentication and Cookie-based token validation.

## Features

✅ **JWT Authentication** - Secure token-based authentication  
✅ **Cookie-based Tokens** - Tokens sent as HTTP cookies  
✅ **Protected Routes** - All API endpoints require authentication  
✅ **User Management** - Signup, login, profile management  
✅ **Posts API** - Create, read, like, delete posts  
✅ **Profile API** - View, update, upload images  

## Setup Instructions

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Database Setup

Make sure PostgreSQL is running on port 5436 with:
- Database: `WEFT`
- Username: `postgres`
- Password: `1234`

### 3. Start the Server

```bash
# Option 1: Using the startup script
python start_server.py

# Option 2: Using uvicorn directly
uvicorn main:app --host 0.0.0.0 --port 8080 --reload
```

## API Endpoints

### Authentication

#### POST `/auth/signup`
Register a new user
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "year": "2025",
  "branch": "COE",
  "class_id": "1A62"
}
```

#### POST `/auth/login`
Login and get JWT tokens
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "AccessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "RefreshToken": "refresh_token_placeholder",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "year": "2025",
    "branch": "COE",
    "class_id": "1A62"
  }
}
```

### Posts (Protected Routes)

#### GET `/posts`
Get all posts (requires authentication)

#### POST `/posts`
Create a new post (requires authentication)
```json
{
  "title": "My First Post",
  "content": "This is the content of my post"
}
```

#### POST `/posts/{post_id}/like`
Like a post (requires authentication)

#### DELETE `/posts/{post_id}`
Delete a post (requires authentication)

### Profile (Protected Routes)

#### GET `/profile/view`
Get user profile (requires authentication)

#### PUT `/profile/update`
Update user profile (requires authentication)

#### POST `/profile/upload-image`
Upload profile image (requires authentication)

#### DELETE `/profile/delete`
Delete user account (requires authentication)

## Authentication Flow

1. **Login**: User provides email/password
2. **Token Generation**: Server creates JWT token with user info
3. **Token Storage**: Flutter app stores token in SharedPreferences
4. **Automatic Inclusion**: All subsequent requests include token as Cookie
5. **Token Validation**: Server validates token and extracts user info

## Token Format

The server expects tokens in the Cookie header:
```
Cookie: AccessToken=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## Security Features

- **JWT Tokens**: Secure, signed tokens with expiration
- **Password Hashing**: bcrypt password hashing
- **Token Validation**: Automatic token validation on protected routes
- **Cookie Parsing**: Proper parsing of Cookie headers
- **Error Handling**: Comprehensive error responses

## Configuration

### JWT Settings (in main.py)
```python
SECRET_KEY = "your-secret-key-here-change-in-production"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30
```

### Database Settings
```python
DATABASE_URL = "postgresql://postgres:1234@localhost:5436/WEFT"
```

## Testing

### Test Login
```bash
curl -X POST "http://localhost:8080/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "password": "password123"}'
```

### Test Protected Route
```bash
curl -X GET "http://localhost:8080/posts" \
  -H "Cookie: AccessToken=your_jwt_token_here"
```

## Development Notes

- **Mock Data**: Posts are currently using mock data (replace with database)
- **Refresh Tokens**: Placeholder implementation (implement later)
- **File Uploads**: Mock implementation (implement with proper file handling)
- **Error Handling**: Basic error handling (enhance for production)

## Production Considerations

1. **Change SECRET_KEY**: Use a strong, unique secret key
2. **Database**: Replace mock data with proper database models
3. **File Storage**: Implement proper file upload handling
4. **Refresh Tokens**: Implement refresh token mechanism
5. **Rate Limiting**: Add rate limiting for API endpoints
6. **Logging**: Add comprehensive logging
7. **CORS**: Configure CORS for production domains
8. **HTTPS**: Use HTTPS in production

## Troubleshooting

### Common Issues

1. **Database Connection**: Ensure PostgreSQL is running on port 5436
2. **Dependencies**: Make sure all requirements are installed
3. **Port Conflicts**: Ensure port 8080 is available
4. **Token Issues**: Check that tokens are being sent as Cookies

### Debug Mode

Enable debug logging by setting log_level to "debug":
```python
uvicorn.run("main:app", log_level="debug")
``` 