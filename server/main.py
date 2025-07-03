from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr
from sqlalchemy import Column, Integer, String, create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from passlib.context import CryptContext

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

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

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


@app.post("/auth/login", response_model=UserOut)
def login(user: UserLogin, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.email == user.email).first()
    if not db_user or not verify_password(user.password, db_user.password):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    return db_user
