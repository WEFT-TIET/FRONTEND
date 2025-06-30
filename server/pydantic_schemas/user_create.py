from pydantic import BaseModel


class UserCreate(BaseModel):
    name: str
    year: str
    branch: str
    class_id: str
    email: str
    password: str