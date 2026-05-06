from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from database import Base

class Usuario(Base):
    __tablename__ = "usuarios"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    senha = Column(String)

    clientes = relationship("Cliente", back_populates="dono")


class Cliente(Base):
    __tablename__ = "clientes"

    id = Column(Integer, primary_key=True, index=True)
    nome = Column(String)
    idade = Column(Integer)
    documento = Column(String)

    usuario_id = Column(Integer, ForeignKey("usuarios.id"))
    dono = relationship("Usuario", back_populates="clientes")
    