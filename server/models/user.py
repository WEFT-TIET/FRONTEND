from sqlalchemy import TEXT, VARCHAR, Column, LargeBinary
from models.base import Base


class User(Base):
    __tablename__ = 'users'

    id = Column(TEXT, primary_key=True)
    name = Column(VARCHAR(100))
    year = Column(VARCHAR(4))
    branch = Column(VARCHAR(4))
    class_id = Column(VARCHAR(4))
    email = Column(VARCHAR(100))
    password = Column(LargeBinary)