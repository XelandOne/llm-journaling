from sqlalchemy import Column, Integer, String, DateTime, Date, Table
from sqlalchemy.orm import relationship
from backend.database import Base
import datetime

class Event(Base):
    __tablename__ = "events"

    id = Column(Integer, primary_key=True, index=True)
    date = Column(Date, default=datetime.date.today)
    startTime = Column(DateTime)
    endTime = Column(DateTime)
    description = Column(String)
    tags = Column(String)  

class Feeling(Base):
    __tablename__ = "feelings"

    id = Column(Integer, primary_key=True, index=True)
    feelings = Column(String)  
    score = Column(Integer)
    datetime = Column(DateTime, default=datetime.datetime.now)


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    score = Column(Integer, default=0)