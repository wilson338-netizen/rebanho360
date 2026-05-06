from fastapi import APIRouter
from pydantic import BaseModel
from typing import List
from sqlalchemy import create_engine, text
from datetime import date

router = APIRouter()

# ================================
# CONEXÃO COM BANCO
# ================================

DATABASE_URL = "postgresql+psycopg2://postgres:9897@localhost:5432/igreja_db"
engine = create_engine(DATABASE_URL)

# ================================
# MODEL
# ================================

class PresencaRequest(BaseModel):
    pg_id: int
    presentes: List[int]
    visitantes: List[str]

# ================================
# ROTA
# ================================

@router.post("/presencas")
def salvar_presenca(dados: PresencaRequest):

    hoje = date.today()

    with engine.connect() as conn:

        # MEMBROS
        for membro_id in dados.presentes:
            conn.execute(text("""
                INSERT INTO presencas (pg_id, membro_id, data, presente)
                VALUES (:pg, :membro, :data, true)
            """), {
                "pg": dados.pg_id,
                "membro": membro_id,
                "data": hoje
            })

        # VISITANTES
        for nome in dados.visitantes:
            conn.execute(text("""
                INSERT INTO visitantes_pg (pg_id, nome, data)
                VALUES (:pg, :nome, :data)
            """), {
                "pg": dados.pg_id,
                "nome": nome,
                "data": hoje
            })

        conn.commit()

    return {"status": "Presença salva com sucesso"}

