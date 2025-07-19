from fastapi import FastAPI, HTTPException, Depends, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr
from sqlalchemy import Column, Integer, String, create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from passlib.context import CryptContext
import jwt
from datetime import datetime, timedelta
from typing import Optional

# ------------------ DB SETUP ------------------

DATABASE_URL = "postgresql://postgres:1234@localhost:5436/WEFT" 

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
Base = declarative_base()

# ------------------ MODELS ------------------

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    password = Column(String, nullable=False)
    year = Column(String)
    branch = Column(String)
    class_id = Column(String)

Base.metadata.create_all(bind=engine)

# ------------------ SCHEMAS ------------------

class UserSignup(BaseModel):
    name: str
    email: EmailStr
    password: str
    year: str
    branch: str
    class_id: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserOut(BaseModel):
    id: int
    name: str
    email: str
    year: str
    branch: str
    class_id: str

    class Config:
        orm_mode = True

# ------------------ SECURITY ------------------

# JWT Configuration
SECRET_KEY = "your-secret-key-here-change-in-production"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def verify_token(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token has expired")
    except jwt.JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

def get_token_from_cookie(request: Request) -> Optional[str]:
    """Extract AccessToken from Cookie header"""
    cookie_header = request.headers.get("cookie")
    if not cookie_header:
        return None
    
    # Parse cookie header to find AccessToken
    cookies = {}
    for cookie in cookie_header.split(";"):
        if "=" in cookie:
            name, value = cookie.strip().split("=", 1)
            cookies[name] = value
    
    return cookies.get("AccessToken")

def get_current_user(request: Request, db: Session = Depends(get_db)):
    """Dependency to get current authenticated user"""
    token = get_token_from_cookie(request)
    if not token:
        raise HTTPException(status_code=401, detail="Access Token not present")
    
    payload = verify_token(token)
    user_id = payload.get("sub")
    if user_id is None:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise HTTPException(status_code=401, detail="User not found")
    
    return user

# ------------------ FASTAPI ------------------

app = FastAPI()

# Enable CORS (for Flutter, React, etc.)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # set your IP/domain here in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ------------------ ROUTES ------------------

@app.post("/auth/signup", response_model=UserOut)
def signup(user: UserSignup, db: Session = Depends(get_db)):
    existing_user = db.query(User).filter(User.email == user.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")

    new_user = User(
        name=user.name,
        email=user.email,
        password=hash_password(user.password),
        year=user.year,
        branch=user.branch,
        class_id=user.class_id
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


@app.post("/auth/login")
def login(user: UserLogin, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.email == user.email).first()
    if not db_user or not verify_password(user.password, db_user.password):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    # Create access token
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": str(db_user.id), "email": db_user.email},
        expires_delta=access_token_expires
    )
    
    return {
        "AccessToken": access_token,
        "RefreshToken": "refresh_token_placeholder",  # You can implement refresh tokens later
        "user": {
            "id": db_user.id,
            "name": db_user.name,
            "email": db_user.email,
            "year": db_user.year,
            "branch": db_user.branch,
            "class_id": db_user.class_id
        }
    }

# ------------------ POSTS ROUTES ------------------

class PostCreate(BaseModel):
    title: str
    content: str

class PostResponse(BaseModel):
    id: int
    title: str
    content: str
    user_name: str
    created_at: str
    likes_count: int
    comments_count: int
    liked: bool

    class Config:
        orm_mode = True

# Mock posts data (replace with database model later)
posts_db = []

@app.get("/posts", response_model=list[PostResponse])
def get_posts(current_user: User = Depends(get_current_user)):
    """Get all posts - requires authentication"""
    # Mock data for now
    mock_posts = [
        {
            "id": 1,
            "title": "Welcome to WEFT!",
            "content": "This is our first post",
            "user_name": current_user.name,
            "created_at": datetime.utcnow().isoformat(),
            "likes_count": 5,
            "comments_count": 2,
            "liked": False
        },
        {
            "id": 2,
            "title": "Flutter Development",
            "content": "Learning Flutter is amazing!",
            "user_name": "John Doe",
            "created_at": datetime.utcnow().isoformat(),
            "likes_count": 10,
            "comments_count": 3,
            "liked": True
        }
    ]
    return mock_posts

@app.post("/posts", response_model=PostResponse)
def create_post(post: PostCreate, current_user: User = Depends(get_current_user)):
    """Create a new post - requires authentication"""
    new_post = {
        "id": len(posts_db) + 1,
        "title": post.title,
        "content": post.content,
        "user_name": current_user.name,
        "created_at": datetime.utcnow().isoformat(),
        "likes_count": 0,
        "comments_count": 0,
        "liked": False
    }
    posts_db.append(new_post)
    return new_post

@app.post("/posts/{post_id}/like")
def like_post(post_id: int, current_user: User = Depends(get_current_user)):
    """Like a post - requires authentication"""
    # Mock implementation
    return {"message": f"Post {post_id} liked by {current_user.name}"}

@app.delete("/posts/{post_id}")
def delete_post(post_id: int, current_user: User = Depends(get_current_user)):
    """Delete a post - requires authentication"""
    # Mock implementation
    return {"message": f"Post {post_id} deleted by {current_user.name}"}

# ------------------ PROFILE ROUTES ------------------

@app.get("/profile/view")
def get_profile(current_user: User = Depends(get_current_user)):
    """Get user profile - requires authentication"""
    return {
        "id": current_user.id,
        "name": current_user.name,
        "email": current_user.email,
        "year": current_user.year,
        "branch": current_user.branch,
        "class_id": current_user.class_id
    }

@app.put("/profile/update")
def update_profile(profile_data: dict, current_user: User = Depends(get_current_user)):
    """Update user profile - requires authentication"""
    # Mock implementation
    return {"message": f"Profile updated for {current_user.name}"}

@app.post("/profile/upload-image")
def upload_profile_image(image_data: dict, current_user: User = Depends(get_current_user)):
    """Upload profile image - requires authentication"""
    # Mock implementation
    return {"imageUrl": "https://example.com/profile-image.jpg"}

@app.delete("/profile/delete")
def delete_account(current_user: User = Depends(get_current_user)):
    """Delete user account - requires authentication"""
    # Mock implementation
    return {"message": f"Account deleted for {current_user.name}"}
