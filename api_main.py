# ==========================================
# IMPORTAÇÕES
# ==========================================

from fastapi import FastAPI, HTTPException, UploadFile, File, Body
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy import create_engine, text
from sqlalchemy.orm import Session
from pydantic import BaseModel
from passlib.context import CryptContext
from jose import jwt
from datetime import datetime, timedelta, date
import os
import shutil

print("🔥 DASHBOARD DETALHADO CARREGADO")

# ==========================================
# APP
# ==========================================

app = FastAPI(title="Rebanho360 API FINAL")

# ==========================================
# CORS (OBRIGATÓRIO PARA FLUTTER WEB)
# ==========================================

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # depois podemos restringir
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==========================================
# UPLOADS
# ==========================================

app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# ==========================================
# SEGURANÇA
# ==========================================

SECRET_KEY = "rebanho360_super_secret_key_32chars"
ALGORITHM = "HS256"

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")



# ==========================================
# DATABASE
# ==========================================

DATABASE_URL = os.getenv("DATABASE_URL")

print("🔥 DATABASE_URL:", DATABASE_URL)

if not DATABASE_URL:
    raise Exception("DATABASE_URL não configurado no Railway!")

# Corrige formato do Railway (postgres -> postgresql)
DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://")

from sqlalchemy import create_engine

engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True
)

# ==========================================
# BASE URL (PRODUÇÃO)
# ==========================================

BASE_URL = os.getenv(
    "BASE_URL",
    "https://web-production-88cd7.up.railway.app"
)



# ==========================================
# PERMISSÃO
# ==========================================

def somente_admin(user):
    if user["tipo"] not in ["admin", "pastor"]:
        raise HTTPException(status_code=403, detail="Sem permissão")
    

# ==========================================
# MODELOS
# ==========================================

class UsuarioLogin(BaseModel):
    email: str
    senha: str

class Financeiro(BaseModel):
    membro_id: int | None = None
    tipo: str
    categoria: str
    valor: float
    origem: str
    descricao: str
    data: str

class Agendamento(BaseModel):
    nome: str
    pedido: str
    data: str

class NovoUsuario(BaseModel):
    nome: str
    email: str
    senha: str
    tipo: str
    membro_id: int

class Aviso(BaseModel):
    titulo: str
    descricao: str

class PedidoOracao(BaseModel):
    membro_id: int
    pedido: str

class Mensagem(BaseModel):
    de_membro: int
    para_membro: int
    mensagem: str

class Voluntario(BaseModel):
    membro_id: int
    evento_id: int

class Igreja(BaseModel):
    nome: str
    endereco: str
    cidade: str

class NovaCongregacao(BaseModel):
    nome: str
    endereco: str
    tipo: str
    fk_igreja: int


# ==========================================
# MODEL SEGMENTO
# ==========================================
from pydantic import BaseModel

class Segmento(BaseModel):
    nome: str

# ==========================================
# SEGURANÇA (JWT)
# ==========================================

from datetime import datetime, timedelta
from fastapi import HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwt, JWTError

# 🔐 CONFIG
SECRET_KEY = "sua_chave_secreta_aqui"  # 🔥 pode manter a sua atual
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_HOURS = 12

# 🔐 SCHEMA DE SEGURANÇA
security = HTTPBearer()



# ==========================================
# CRIAR TOKEN
# ==========================================
def criar_token(data: dict):
    to_encode = data.copy()
    to_encode.update({
        "exp": datetime.utcnow() + timedelta(hours=ACCESS_TOKEN_EXPIRE_HOURS)
    })

    token = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

    print("TOKEN GERADO:", token)  # debug opcional

    return token


## ==========================================
# VALIDAR TOKEN (CORRIGIDO E BLINDADO)
# ==========================================

from fastapi import Request

def verificar_token(request: Request):

    auth = request.headers.get("Authorization")

    print("HEADER RECEBIDO:", auth)  # 🔥 DEBUG

    if not auth:
        raise HTTPException(status_code=401, detail="Token não enviado")

    if not auth.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Formato inválido")

    token = auth.replace("Bearer ", "")

    print("TOKEN LIMPO:", token)  # 🔥 DEBUG

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])

        print("PAYLOAD:", payload)  # 🔥 DEBUG

        return payload

    except JWTError as e:
        print("ERRO TOKEN:", e)
        raise HTTPException(status_code=401, detail="Token inválido")
    

# ==========================================
# LOGIN
# ==========================================
@app.post("/login")
def login(dados: dict):

    try:
        with engine.connect() as conn:

            usuario = conn.execute(text("""
                SELECT id, tipo, fk_igreja, fk_membro
                FROM usuarios
                WHERE email = :email AND senha = :senha
            """), {
                "email": dados.get("email"),
                "senha": dados.get("senha")
            }).mappings().fetchone()

            if not usuario:
                return {"erro": "Usuário inválido"}

            user_id = usuario["id"]
            tipo = usuario["tipo"] if usuario["tipo"] else "membro"
            igreja_id = usuario["fk_igreja"]
            membro_id = usuario["fk_membro"]

            token = criar_token({
                "user_id": user_id,
                "tipo": tipo,
                "igreja_id": igreja_id,
                "membro_id": membro_id
            })

            return {
                "token": token,
                "tipo": tipo,
                "membro_id": membro_id,
                "igreja_id": igreja_id
            }

    except Exception as e:
        print("🔥 ERRO LOGIN:", str(e))
        return {"erro": str(e)}
    

    


# ==========================================
# USUÁRIO LOGADO
# ==========================================

@app.get("/me")
def me(user=Depends(verificar_token)):

    with engine.connect() as conn:
        usuario = conn.execute(text("""
            SELECT id, nome, email, tipo, fk_igreja
            FROM usuarios
            WHERE id = :id
        """), {"id": user["user_id"]}).fetchone()

    if not usuario:
        raise HTTPException(status_code=404)

    return dict(usuario._mapping)



# ==========================================
# USUÁRIOS
# ==========================================

@app.post("/usuarios")
def criar_usuario(dados: NovoUsuario, user=Depends(verificar_token)):

    senha_hash = pwd_context.hash(dados.senha)

    with engine.connect() as conn:

        existe = conn.execute(text("""
            SELECT id FROM usuarios WHERE email = :email
        """), {"email": dados.email}).fetchone()

        if existe:
            raise HTTPException(status_code=400, detail="Email já cadastrado")

        conn.execute(text("""
            INSERT INTO usuarios (nome, email, senha, tipo, fk_membro, fk_igreja)
            VALUES (:nome, :email, :senha, :tipo, :membro, :igreja)
        """), {
            "nome": dados.nome,
            "email": dados.email,
            "senha": senha_hash,
            "tipo": dados.tipo,
            "membro": dados.membro_id,
            "igreja": user["igreja_id"]  # 🔥 automático
        })

        conn.commit()

    return {"status": "usuario criado"}


# ==========================================
# MEMBROS
# ==========================================

from datetime import date

# ================= SEGMENTO AUTOMÁTICO =================
def calcular_segmento(data_nascimento):
    if not data_nascimento:
        return "Adulto"

    try:
        idade = date.today().year - data_nascimento.year
    except:
        return "Adulto"

    if idade <= 6:
        return "Berçário"
    elif idade <= 11:
        return "Infantil"
    elif idade <= 18:
        return "Adolescente"
    elif idade <= 35:
        return "Jovens"
    else:
        return "Adulto"


# ==========================================
# CRIAR MEMBRO
# ==========================================

@app.post("/membros")
def criar_membro(dados: dict, user=Depends(verificar_token)):

    try:
        with engine.connect() as conn:

            conn.execute(text("""
                INSERT INTO membros (
                    nome,
                    telefone,
                    endereco,
                    bairro,
                    cep,
                    municipio,
                    estado,
                    email,
                    cargo,
                    fk_congregacao,
                    fk_familia,
                    fk_igreja,
                    data_nascimento
                )
                VALUES (
                    :nome,
                    :telefone,
                    :endereco,
                    :bairro,
                    :cep,
                    :municipio,
                    :estado,
                    :email,
                    :cargo,
                    :fk_congregacao,
                    :fk_familia,
                    :igreja,
                    :data_nascimento
                )
            """), {
                "nome": dados.get("nome"),
                "telefone": dados.get("telefone"),
                "endereco": dados.get("endereco"),
                "bairro": dados.get("bairro"),
                "cep": dados.get("cep"),
                "municipio": dados.get("municipio"),
                "estado": dados.get("estado"),
                "email": dados.get("email"),
                "cargo": dados.get("cargo"),
               "fk_congregacao": dados.get("fk_congregacao") or None,
                "fk_familia": dados.get("fk_familia"),
                "data_nascimento": dados.get("data_nascimento"),
                "igreja": user["igreja_id"]
            })

            conn.commit()

        return {"status": "ok"}

    except Exception as e:
        print("ERRO AO SALVAR MEMBRO:", e)
        raise HTTPException(status_code=500, detail=str(e))


# ==========================================
# LISTAR MEMBROS (COM SEGMENTO)
# ==========================================

@app.get("/membros")
def listar_membros(user=Depends(verificar_token)):

    with engine.connect() as conn:
        result = conn.execute(text("""
            SELECT m.*, c.nome as congregacao
            FROM membros m
            LEFT JOIN congregacoes c ON c.id = m.fk_congregacao
            WHERE m.fk_igreja = :igreja
        """), {"igreja": user["igreja_id"]})

        dados = []

        for row in result:
            membro = dict(row._mapping)

            membro["segmento"] = calcular_segmento(
                membro.get("data_nascimento")
            )

            # 🔥 proteção contra null (resolve seu erro vermelho)
            for k, v in membro.items():
                if v is None:
                    membro[k] = ""

            dados.append(membro)

        return dados
    
# ==========================================
# MEMBRO POR ID
# ==========================================

@app.get("/membros/{id}")
def get_membro(id: int, user=Depends(verificar_token)):

    with engine.connect() as conn:
        result = conn.execute(text("""
            SELECT * FROM membros
            WHERE id = :id AND fk_igreja = :igreja
        """), {
            "id": id,
            "igreja": user["igreja_id"]
        }).fetchone()

        if not result:
            raise HTTPException(status_code=404, detail="Membro não encontrado")

        return dict(result._mapping)


# ==========================================
# ATUALIZAR MEMBRO
# ==========================================

@app.put("/membros/{id}")
def atualizar_membro(id: int, dados: dict, user=Depends(verificar_token)):

    with engine.connect() as conn:
        conn.execute(text("""
            UPDATE membros
            SET nome=:nome,
                telefone=:telefone,
                endereco=:endereco,
                bairro=:bairro,
                cep=:cep,
                municipio=:municipio,
                estado=:estado,
                email=:email,
                cargo=:cargo,
                fk_congregacao=:fk_congregacao,
                fk_familia=:fk_familia,
                data_nascimento=:data_nascimento
            WHERE id=:id AND fk_igreja=:igreja
        """), {
            "id": id,
            "nome": dados.get("nome"),
            "telefone": dados.get("telefone"),
            "endereco": dados.get("endereco"),
            "bairro": dados.get("bairro"),
            "cep": dados.get("cep"),
            "municipio": dados.get("municipio"),
            "estado": dados.get("estado"),
            "email": dados.get("email"),

            # 🔥 ESSA LINHA RESOLVE TUDO
            "cargo": dados.get("cargo") or "Membro",

            "fk_congregacao": dados.get("fk_congregacao"),
            "fk_familia": dados.get("fk_familia"),
            "data_nascimento": dados.get("data_nascimento"),
            "igreja": user["igreja_id"]
        })

        conn.commit()

    return {"status": "ok"}





# ==========================================
# DELETAR MEMBRO
# ==========================================

@app.delete("/membros/{id}")
def deletar_membro(id: int, user=Depends(verificar_token)):

    with engine.connect() as conn:
        conn.execute(text("""
            DELETE FROM membros
            WHERE id=:id AND fk_igreja=:igreja
        """), {
            "id": id,
            "igreja": user["igreja_id"]
        })

        conn.commit()

    return {"status": "ok"}



# ==========================================
# EBD DO MEMBRO (CORRIGIDO PROFISSIONAL)
# ==========================================

from datetime import date

@app.get("/membro/ebd")
def ebd_do_membro(user=Depends(verificar_token)):

    membro_id = user.get("membro_id")

    if not membro_id:
        raise HTTPException(status_code=400, detail="Membro não identificado")

    with engine.connect() as conn:

        # ==========================
        # BUSCAR MEMBRO (AGORA COM TURMA)
        # ==========================
        membro = conn.execute(text("""
            SELECT nome, fk_turma
            FROM membros
            WHERE id = :id
        """), {"id": membro_id}).fetchone()

        if not membro:
            raise HTTPException(status_code=404, detail="Membro não encontrado")

        # ==========================
        # DEFINIR TURMA (AUTO + FALLBACK)
        # ==========================
        turma_db = None

        # 🔹 1. tenta pela fk_turma (manual)
        if membro.fk_turma:
            turma_db = conn.execute(text("""
                SELECT t.id, t.nome, m.nome as professor
                FROM ebd_turmas t
                LEFT JOIN membros m ON m.id = t.professor_id
                WHERE t.id = :turma
                AND t.fk_igreja = :igreja
            """), {
                "turma": membro.fk_turma,
                "igreja": user["igreja_id"]
            }).fetchone()

        # 🔹 2. fallback automático por idade
        if not turma_db:

            idade = 0

            membro_data = conn.execute(text("""
                SELECT data_nascimento
                FROM membros
                WHERE id = :id
            """), {"id": membro_id}).fetchone()

            if membro_data and membro_data.data_nascimento:
                idade = date.today().year - membro_data.data_nascimento.year

            if idade <= 6:
                nome_turma = "Berçário"
            elif idade <= 11:
                nome_turma = "Infantil"
            elif idade <= 18:
                nome_turma = "Adolescente"
            elif idade <= 35:
                nome_turma = "Jovens"
            else:
                nome_turma = "Adulto"

            turma_db = conn.execute(text("""
                SELECT t.id, t.nome, m.nome as professor
                FROM ebd_turmas t
                LEFT JOIN membros m ON m.id = t.professor_id
                WHERE LOWER(t.nome) = LOWER(:nome)
                AND t.fk_igreja = :igreja
            """), {
                "nome": nome_turma,
                "igreja": user["igreja_id"]
            }).fetchone()

        # ==========================
        # BUSCAR LIÇÃO DA TURMA
        # ==========================
        licao = None

        if turma_db:
            licao = conn.execute(text("""
                SELECT titulo, descricao
                FROM ebd_licoes
                WHERE fk_turma = :turma
                ORDER BY data DESC
                LIMIT 1
            """), {
                "turma": turma_db.id
            }).fetchone()

        # ==========================
        # RETORNO FINAL
        # ==========================
        return {
            "nome": membro.nome,
            "turma": turma_db.nome if turma_db else "Sem turma",
            "professor": turma_db.professor if turma_db else "Não definido",
            "licao": licao.titulo if licao else "Sem lição",
            "descricao": licao.descricao if licao else "",
            "frequencia": 75
        }


@app.put("/ebd/turmas/{id}")
def atualizar_turma(id: int, dados: dict, user=Depends(verificar_token)):

    with engine.connect() as conn:
        conn.execute(text("""
            UPDATE ebd_turmas
            SET professor_id = :professor
            WHERE id = :id
            AND fk_igreja = :igreja
        """), {
            "professor": dados.get("professor_id"),
            "id": id,
            "igreja": user["igreja_id"]
        })

        conn.commit()

    return {"status": "ok"}

@app.post("/ebd/licao")
def salvar_licao(dados: dict, user=Depends(verificar_token)):

    with engine.connect() as conn:
        conn.execute(text("""
            INSERT INTO ebd_licoes (
                titulo,
                descricao,
                fk_turma,
                fk_igreja,
                data
            )
            VALUES (
                :titulo,
                :descricao,
                :turma,
                :igreja,
                NOW()
            )
        """), {
            "titulo": dados.get("titulo"),
            "descricao": dados.get("descricao"),
            "turma": dados.get("fk_turma"),
            "igreja": user["igreja_id"]
        })

        conn.commit()

    return {"status": "ok"}



@app.post("/ebd/presenca")
def salvar_presenca(dados: dict, user=Depends(verificar_token)):

    with engine.connect() as conn:

        for item in dados.get("presenca", []):

            print("ITEM RECEBIDO:", item)  # 🔥 DEBUG

            membro_id = item.get("membro_id")
            turma_id = item.get("turma_id")
            presente = item.get("presente", True)

            if not membro_id or not turma_id:
                continue  # 🔥 evita quebrar

            conn.execute(text("""
                INSERT INTO ebd_presenca (
                    fk_membro,
                    fk_turma,
                    presente,
                    fk_igreja
                )
                VALUES (
                    :membro,
                    :turma,
                    :presente,
                    :igreja
                )
            """), {
                "membro": membro_id,
                "turma": turma_id,
                "presente": presente,
                "igreja": user["igreja_id"]
            })

        conn.commit()

    return {"status": "ok"}


@app.get("/ebd/membros")
def membros_por_turma(turma: int, user=Depends(verificar_token)):

    with engine.connect() as conn:
        result = conn.execute(text("""
            SELECT id, nome
            FROM membros
            WHERE fk_turma = :turma
        """), {
            "turma": turma
        })

        return [dict(r._mapping) for r in result]


@app.get("/ebd/ultima")
def ultima_presenca(turma: int, user=Depends(verificar_token)):

    with engine.connect() as conn:
        result = conn.execute(text("""
            SELECT fk_membro, presente
            FROM ebd_presenca
            WHERE fk_turma = :turma
            ORDER BY data DESC
        """), {
            "turma": turma
        })

        return [dict(r._mapping) for r in result]
    

@app.get("/ebd/relatorio")
def relatorio_ebd(turma: int, user=Depends(verificar_token)):

    with engine.connect() as conn:

        # ==========================
        # TOTAL DE AULAS DA TURMA
        # ==========================
        total_aulas = conn.execute(text("""
            SELECT COUNT(DISTINCT data) as total
            FROM ebd_presenca
            WHERE fk_turma = :turma
            AND fk_igreja = :igreja
        """), {
            "turma": turma,
            "igreja": user["igreja_id"]
        }).fetchone()

        total = total_aulas.total if total_aulas else 0

        # ==========================
        # PRESENÇA POR MEMBRO
        # ==========================
        result = conn.execute(text("""
            SELECT 
                m.id,
                m.nome,
                COUNT(CASE WHEN p.presente = true THEN 1 END) as presencas
            FROM membros m
            LEFT JOIN ebd_presenca p 
                ON p.fk_membro = m.id
                AND p.fk_turma = :turma
                AND p.fk_igreja = :igreja
            WHERE m.fk_turma = :turma
            GROUP BY m.id, m.nome
            ORDER BY presencas DESC
        """), {
            "turma": turma,
            "igreja": user["igreja_id"]
        })

        lista = []

        for r in result:
            freq = 0

            if total > 0:
                freq = round((r.presencas / total) * 100, 1)

            lista.append({
                "id": r.id,
                "nome": r.nome,
                "presencas": r.presencas,
                "faltas": total - r.presencas,
                "frequencia": freq
            })

        return {
            "total_aulas": total,
            "dados": lista
        }


@app.get("/leitura/hoje")
def leitura_hoje(user=Depends(verificar_token)):

    with engine.connect() as conn:

        dia = conn.execute(text("""
            SELECT COUNT(*) as total
            FROM leitura_progresso
            WHERE fk_membro = :membro
        """), {"membro": user["membro_id"]}).fetchone()

        dia_atual = (dia.total or 0) + 1

        leitura = conn.execute(text("""
            SELECT * FROM leitura_plano
            WHERE dia = :dia
        """), {"dia": dia_atual}).fetchone()

        return dict(leitura._mapping) if leitura else {}
    

@app.post("/leitura/concluir")
def concluir_leitura(user=Depends(verificar_token)):

    from datetime import date

    with engine.connect() as conn:

        # ==========================
        # SALVAR PROGRESSO
        # ==========================
        conn.execute(text("""
            INSERT INTO leitura_progresso (
                fk_membro, data, fk_igreja
            )
            VALUES (:membro, CURRENT_DATE, :igreja)
        """), {
            "membro": user["membro_id"],
            "igreja": user["igreja_id"]
        })

        # ==========================
        # CALCULAR STREAK REAL
        # ==========================
        dias = conn.execute(text("""
            SELECT DISTINCT data
            FROM leitura_progresso
            WHERE fk_membro = :membro
            ORDER BY data DESC
        """), {"membro": user["membro_id"]}).fetchall()

        streak = 0
        hoje = date.today()

        from datetime import timedelta

        for d in dias:
            if d.data == hoje - timedelta(days=streak):
                streak += 1
            else:
                break

        # ==========================
        # MEDALHAS
        # ==========================
        medalhas = {
            3: "Iniciante 🟢",
            7: "Fiel 🔵",
            15: "Discipulado 🟣",
            30: "Comprometido 🟡",
            60: "Constante 🔥",
            100: "Guerreiro da Fé 👑"
        }

        if streak in medalhas:

            ja_tem = conn.execute(text("""
                SELECT 1 FROM leitura_medalhas
                WHERE fk_membro = :membro
                AND medalha = :medalha
            """), {
                "membro": user["membro_id"],
                "medalha": medalhas[streak]
            }).fetchone()

            if not ja_tem:
                conn.execute(text("""
                    INSERT INTO leitura_medalhas (fk_membro, medalha)
                    VALUES (:membro, :medalha)
                """), {
                    "membro": user["membro_id"],
                    "medalha": medalhas[streak]
                })

        conn.commit()

    return {
        "status": "ok",
        "streak": streak
    }




@app.get("/leitura/hoje")
def leitura_hoje(user=Depends(verificar_token)):

    with engine.connect() as conn:

        progresso = conn.execute(text("""
            SELECT COUNT(*) as total
            FROM leitura_progresso
            WHERE fk_membro = :membro
        """), {"membro": user["membro_id"]}).fetchone()

        dia_atual = (progresso.total or 0) + 1

        leitura = conn.execute(text("""
            SELECT dia, titulo, leitura
            FROM leitura_plano
            WHERE dia = :dia
        """), {"dia": dia_atual}).fetchone()

        return {
            "dia": leitura.dia if leitura else dia_atual,
            "titulo": leitura.titulo if leitura else "Plano não encontrado",
            "leitura": leitura.leitura if leitura else ""
        }


@app.get("/leitura/streak")
def leitura_streak(user=Depends(verificar_token)):

    from datetime import date, timedelta

    with engine.connect() as conn:

        dias = conn.execute(text("""
            SELECT DISTINCT data
            FROM leitura_progresso
            WHERE fk_membro = :membro
            ORDER BY data DESC
        """), {"membro": user["membro_id"]}).fetchall()

        streak = 0
        hoje = date.today()

        for d in dias:
            if d.data == hoje - timedelta(days=streak):
                streak += 1
            else:
                break

        return {"streak": streak}


@app.get("/leitura/medalhas")
def medalhas(user=Depends(verificar_token)):

    with engine.connect() as conn:

        result = conn.execute(text("""
            SELECT medalha, data
            FROM leitura_medalhas
            WHERE fk_membro = :membro
            ORDER BY data DESC
        """), {"membro": user["membro_id"]})

        return [dict(r._mapping) for r in result]
    


@app.get("/leitura/ranking")
def ranking(user=Depends(verificar_token)):

    with engine.connect() as conn:

        result = conn.execute(text("""
            SELECT m.nome, COUNT(p.id) as total
            FROM leitura_progresso p
            JOIN membros m ON m.id = p.fk_membro
            WHERE p.fk_igreja = :igreja
            GROUP BY m.nome
            ORDER BY total DESC
            LIMIT 10
        """), {"igreja": user["igreja_id"]})

        return [dict(r._mapping) for r in result]
    



# ==========================================
# CARTEIRINHA
# ==========================================

from fastapi import Request

@app.get("/carteirinha/{membro_id}")
def carteirinha(membro_id: int, request: Request):

    print("HEADERS:", request.headers)

    # 🔥 pega header corretamente
    auth = request.headers.get("authorization") or request.headers.get("Authorization")

    if not auth:
        raise HTTPException(status_code=401, detail="Sem token")

    try:
        token = auth.split(" ")[1]

        payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])

        print("PAYLOAD:", payload)

    except Exception as e:
        print("ERRO TOKEN:", e)
        raise HTTPException(status_code=401, detail="Token inválido")

    with engine.connect() as conn:

        membro = conn.execute(text("""
            SELECT id, nome, telefone, foto
            FROM membros
            WHERE id = :id AND fk_igreja = :igreja
        """), {
            "id": membro_id,
            "igreja": payload["igreja_id"]
        }).fetchone()

        if not membro:
            raise HTTPException(status_code=404)

        ministro = conn.execute(text("""
            SELECT cargo
            FROM ministros
            WHERE fk_membro = :id
        """), {"id": membro_id}).fetchone()

    return {
        "id": membro.id,
        "nome": membro.nome,
        "telefone": membro.telefone,
        "foto": membro.foto,
        "cargo": ministro.cargo if ministro else "Membro"
    }






@app.put("/membros/{id}/celula")
def escolher_celula(id: int, celula_id: int, user=Depends(verificar_token)):

    with engine.connect() as conn:
        conn.execute(text("""
            UPDATE membros
            SET fk_celula = :celula
            WHERE id = :id AND fk_igreja = :igreja
        """), {
            "id": id,
            "celula": celula_id,
            "igreja": user["igreja_id"]
        })

        conn.commit()

    return {"status": "ok"}


# ==========================================
# CARTEIRINHAS (ADMIN)
# ==========================================

@app.get("/carteirinhas")
def listar_carteirinhas(user=Depends(verificar_token)):

    if user["tipo"] not in ["admin", "pastor"]:
        raise HTTPException(status_code=403, detail="Acesso negado")

    with engine.connect() as conn:
        res = conn.execute(text("""
            SELECT id, nome, foto, telefone
            FROM membros
            WHERE fk_igreja = :igreja
        """), {"igreja": user["igreja_id"]})

    return [dict(r._mapping) for r in res]




# ==========================================
# FAMILIAS
# ==========================================

@app.post("/familias")
def criar_familia(dados: dict, user=Depends(verificar_token)):

    with engine.connect() as conn:
        conn.execute(text("""
            INSERT INTO familias (
                nome,
                telefone,
                endereco,
                observacoes,
                fk_igreja
            )
            VALUES (
                :nome,
                :telefone,
                :endereco,
                :observacoes,
                :igreja
            )
        """), {
            "nome": dados.get("nome"),
            "telefone": dados.get("telefone"),
            "endereco": dados.get("endereco"),
            "observacoes": dados.get("observacoes"),
            "igreja": user["igreja_id"]
        })

        conn.commit()

    return {"status": "ok"}


@app.get("/familias")
def listar_familias(user=Depends(verificar_token)):

    with engine.connect() as conn:
        result = conn.execute(text("""
            SELECT * FROM familias
            WHERE fk_igreja = :igreja
        """), {
            "igreja": user["igreja_id"]
        })

        return [dict(row._mapping) for row in result]
    




# ==========================================
# UPLOAD
# ==========================================

@app.post("/upload")
async def upload(file: UploadFile = File(...)):

    os.makedirs("uploads", exist_ok=True)

    nome_limpo = file.filename.replace(" ", "_")
    caminho = os.path.join("uploads", nome_limpo)

    with open(caminho, "wb") as f:
        f.write(await file.read())

    url = f"{BASE_URL}/uploads/{nome_limpo}"

    return {"url": url}


# ==========================================
# FINANCEIRO
# ==========================================

@app.post("/financeiro")
def salvar_financeiro(dados: Financeiro, user=Depends(verificar_token)):

    with engine.connect() as conn:
        conn.execute(text("""
            INSERT INTO financeiro 
            (membro_id, tipo, categoria, valor, origem, descricao, data, fk_igreja)
            VALUES (:membro_id, :tipo, :categoria, :valor, :origem, :descricao, :data, :igreja)
        """), {
            **dados.dict(),
            "igreja": user["igreja_id"]
        })

        conn.commit()

    return {"status": "ok"}




@app.get("/financeiro")
def listar_financeiro(user=Depends(verificar_token)):

    with engine.connect() as conn:
        res = conn.execute(text("""
            SELECT * FROM financeiro
            WHERE fk_igreja = :igreja
            ORDER BY data DESC
        """), {"igreja": user["igreja_id"]})

    return [dict(r._mapping) for r in res]




@app.get("/financeiro/resumo")
def resumo(user=Depends(verificar_token)):

    with engine.connect() as conn:

        entradas = conn.execute(text("""
            SELECT COALESCE(SUM(valor),0)
            FROM financeiro 
            WHERE tipo='entrada' AND fk_igreja=:igreja
        """), {"igreja": user["igreja_id"]}).scalar()

        saidas = conn.execute(text("""
            SELECT COALESCE(SUM(valor),0)
            FROM financeiro 
            WHERE tipo='saida' AND fk_igreja=:igreja
        """), {"igreja": user["igreja_id"]}).scalar()

    return {
        "entradas": float(entradas),
        "saidas": float(saidas),
        "saldo": float(entradas - saidas)
    }


@app.get("/financeiro/mensal")
def financeiro_mensal(user=Depends(verificar_token)):

    with engine.connect() as conn:
        res = conn.execute(text("""
            SELECT 
                TO_CHAR(data, 'MM/YYYY') as mes,
                SUM(CASE WHEN tipo='entrada' THEN valor ELSE 0 END) as entradas,
                SUM(CASE WHEN tipo='saida' THEN valor ELSE 0 END) as saidas
            FROM financeiro
            WHERE fk_igreja = :igreja
            GROUP BY mes
            ORDER BY mes
        """), {"igreja": user["igreja_id"]})

        dados = []
        for r in res:
            entradas = r.entradas or 0
            saidas = r.saidas or 0

            dados.append({
                "mes": r.mes,
                "entradas": float(entradas),
                "saidas": float(saidas),
                "saldo": float(entradas - saidas)
            })

    return dados


@app.get("/financeiro/membros")
def financeiro_membros(user=Depends(verificar_token)):

    with engine.connect() as conn:
        res = conn.execute(text("""
            SELECT m.nome, 
                   COUNT(f.id) as total, 
                   COALESCE(SUM(f.valor),0) as valor
            FROM membros m
            LEFT JOIN financeiro f 
                ON f.membro_id = m.id 
                AND f.fk_igreja = :igreja
            WHERE m.fk_igreja = :igreja
            GROUP BY m.nome
        """), {"igreja": user["igreja_id"]})

    return [dict(r._mapping) for r in res]



# ==========================================
# CONFIGURAÇÃO PIX (ADMIN)
# ==========================================

@app.put("/igreja/pix")
def configurar_pix(dados: dict, user=Depends(verificar_token)):

    with engine.connect() as conn:
        conn.execute(text("""
            UPDATE igrejas
            SET pix_chave = :chave,
                pix_nome = :nome,
                pix_cidade = :cidade
            WHERE id = :igreja
        """), {
            "chave": dados["pix_chave"],
            "nome": dados["pix_nome"],
            "cidade": dados["pix_cidade"],
            "igreja": user["igreja_id"]
        })

        conn.commit()

    return {"status": "PIX atualizado"}



# ==========================================
# OBTER PIX
# ==========================================

@app.get("/igreja/pix")
def obter_pix(user=Depends(verificar_token)):

    print("USER:", user)  # 🔍 debug

    with engine.connect() as conn:
        igreja = conn.execute(text("""
            SELECT pix_chave, pix_nome, pix_cidade
            FROM igrejas
            WHERE id = :igreja
        """), {"igreja": user["igreja_id"]}).fetchone()

    if not igreja:
        raise HTTPException(status_code=404, detail="Igreja não encontrada")

    dados = dict(igreja._mapping)

    # 🔥 NOVA VALIDAÇÃO (ESSENCIAL)
    if not dados["pix_chave"]:
        raise HTTPException(status_code=404, detail="PIX não configurado")

    return dados




# ==========================================
# Salvar ofertas
# ==========================================
@app.post("/ofertas")
def registrar_oferta(dados: dict, user=Depends(verificar_token)):

    with engine.begin() as conn:
        conn.execute(text("""
            INSERT INTO entradas_financeiras 
            (valor, tipo, fk_membro, fk_igreja, origem, descricao)
            VALUES (:valor, :tipo, :membro, :igreja, :origem, :descricao)
        """), {
            "valor": dados["valor"],
            "tipo": "oferta",
            "membro": user["user_id"],
            "igreja": user["igreja_id"],
            "origem": "app",
            "descricao": "Oferta via PIX"
        })

    return {"status": "oferta registrada"}



# ==========================================
# DASHBOARD
# ==========================================

@app.get("/dashboard")
def dashboard(user=Depends(verificar_token)):

    with engine.connect() as conn:

        membros = conn.execute(text("""
            SELECT COUNT(*) 
            FROM membros 
            WHERE fk_igreja = :igreja
        """), {"igreja": user["igreja_id"]}).scalar()

        entradas = conn.execute(text("""
            SELECT COALESCE(SUM(valor),0)
            FROM financeiro 
            WHERE tipo='entrada' AND fk_igreja=:igreja
        """), {"igreja": user["igreja_id"]}).scalar()

        saidas = conn.execute(text("""
            SELECT COALESCE(SUM(valor),0)
            FROM financeiro 
            WHERE tipo='saida' AND fk_igreja=:igreja
        """), {"igreja": user["igreja_id"]}).scalar()

    return {
        "membros": membros,
        "entradas": float(entradas),
        "saidas": float(saidas),
        "saldo": float(entradas - saidas)
    }


# ==========================================
# DASHBOARD DETALHADO
# ==========================================

@app.get("/dashboard/detalhado")
def dashboard_detalhado(user=Depends(verificar_token)):

    if not user["igreja_id"]:
        raise HTTPException(status_code=400, detail="Usuário sem igreja")

    with engine.connect() as conn:

        ultimos = conn.execute(text("""
            SELECT descricao, valor, tipo, data
            FROM financeiro
            WHERE fk_igreja = :igreja
            ORDER BY data DESC
            LIMIT 5
        """), {"igreja": user["igreja_id"]})

        mensal = conn.execute(text("""
            SELECT DATE_TRUNC('month', data) as mes,
                   SUM(CASE WHEN tipo='entrada' THEN valor ELSE 0 END) as entradas,
                   SUM(CASE WHEN tipo='saida' THEN valor ELSE 0 END) as saidas
            FROM financeiro
            WHERE fk_igreja = :igreja
            GROUP BY mes
            ORDER BY mes
        """), {"igreja": user["igreja_id"]})

    return {
        "ultimos": [dict(r._mapping) for r in ultimos],
        "mensal": [dict(r._mapping) for r in mensal]
    }




# ==========================================
# EVENTOS
# ==========================================


@app.post("/eventos")
def criar_evento(dados: dict, user=Depends(verificar_token)):

    data_evento = dados.get("data") or dados.get("data_evento")

    with engine.connect() as conn:
        conn.execute(text("""
            INSERT INTO eventos (titulo, descricao, data_evento, fk_igreja)
            VALUES (:titulo, :descricao, :data, :igreja)
        """), {
            "titulo": dados["titulo"],
            "descricao": dados.get("descricao", ""),
            "data": data_evento,
            "igreja": user["igreja_id"]
        })

        conn.commit()

    return {"status": "ok"}






@app.get("/eventos")
def eventos(user=Depends(verificar_token)):

    with engine.connect() as conn:
        res = conn.execute(text("""
            SELECT * FROM eventos
            WHERE fk_igreja = :igreja
            ORDER BY data_evento
        """), {"igreja": user["igreja_id"]})

    return [dict(r._mapping) for r in res]



@app.put("/eventos/{id}")
def editar_evento(id: int, dados: dict, user=Depends(verificar_token)):

    with engine.connect() as conn:
        conn.execute(text("""
            UPDATE eventos
            SET titulo = :titulo,
                descricao = :descricao,
                data_evento = :data
            WHERE id = :id AND fk_igreja = :igreja
        """), {
            "id": id,
            "titulo": dados["titulo"],
            "descricao": dados["descricao"],
            "data": dados["data_evento"],
            "igreja": user["igreja_id"]
        })

        conn.commit()

    return {"msg": "Atualizado"}



@app.delete("/eventos/{id}")
def excluir_evento(id: int, user=Depends(verificar_token)):

    with engine.connect() as conn:
        conn.execute(text("""
            DELETE FROM eventos
            WHERE id = :id AND fk_igreja = :igreja
        """), {
            "id": id,
            "igreja": user["igreja_id"]
        })

        conn.commit()

    return {"msg": "Excluído"}




# ==========================================
# AVISOS
# ==========================================

@app.get("/avisos")
def avisos(user=Depends(verificar_token)):

    with engine.connect() as conn:
        res = conn.execute(text("""
            SELECT * FROM avisos
            WHERE fk_igreja = :igreja
            ORDER BY id DESC
        """), {"igreja": user["igreja_id"]})

    return [dict(r._mapping) for r in res]



# ==========================================
# IGREJAS
# ==========================================

from fastapi import HTTPException
from sqlalchemy import text


# ==========================
# CRIAR
# ==========================
@app.post("/igrejas")
def criar_igreja(dados: dict):

    tipo = (dados.get("tipo") or "SEDE").upper()

    with engine.begin() as conn:

        # 🔒 VERIFICA SE JÁ EXISTE SEDE
        existe = conn.execute(text("""
            SELECT COUNT(*) FROM igrejas
            WHERE UPPER(tipo) = 'SEDE'
        """)).scalar()

        if existe > 0 and tipo == "SEDE":
            raise HTTPException(
                status_code=400,
                detail="Já existe uma igreja sede cadastrada"
            )

        dados["tipo"] = tipo

        conn.execute(text("""
            INSERT INTO igrejas (
                razao_social,
                nome_fantasia,
                cnpj,
                endereco,
                cidade,
                telefone,
                email,
                site,
                data_fundacao,
                pastor,
                tipo
            )
            VALUES (
                :razao_social,
                :nome_fantasia,
                :cnpj,
                :endereco,
                :cidade,
                :telefone,
                :email,
                :site,
                :data_fundacao,
                :pastor,
                :tipo
            )
        """), dados)

    return {"status": "ok"}


# ==========================
# LISTAR
# ==========================
@app.get("/igrejas")
def listar_igrejas():

    with engine.connect() as conn:
        result = conn.execute(text("""
            SELECT * FROM igrejas ORDER BY id DESC
        """))

        return [dict(row._mapping) for row in result]


# ==========================
# EDITAR
# ==========================
@app.put("/igrejas/{id}")
def editar_igreja(id: int, dados: dict):

    tipo = (dados.get("tipo") or "").upper()

    # 🔥 TRATAMENTO DE DATA (AQUI ESTÁ A CORREÇÃO)
    data_fundacao = dados.get("data_fundacao")

    if not data_fundacao or len(data_fundacao) < 10:
        data_fundacao = None  # evita erro no SQL

    with engine.begin() as conn:

        # 🔒 valida sede
        if tipo == "SEDE":
            existe = conn.execute(text("""
                SELECT COUNT(*) FROM igrejas
                WHERE UPPER(tipo) = 'SEDE' AND id != :id
            """), {"id": id}).scalar()

            if existe > 0:
                raise HTTPException(
                    status_code=400,
                    detail="Já existe outra igreja sede cadastrada"
                )

        conn.execute(text("""
            UPDATE igrejas SET
                razao_social = :razao_social,
                nome_fantasia = :nome_fantasia,
                cnpj = :cnpj,
                endereco = :endereco,
                cidade = :cidade,
                telefone = :telefone,
                email = :email,
                site = :site,
                data_fundacao = :data_fundacao,
                pastor = :pastor,
                tipo = :tipo
            WHERE id = :id
        """), {
            **dados,
            "data_fundacao": data_fundacao,
            "tipo": tipo if tipo else "SEDE",
            "id": id
        })

    return {"status": "ok"}



# ==========================
# EXCLUIR
# ==========================
@app.delete("/igrejas/{id}")
def excluir_igreja(id: int):

    with engine.begin() as conn:

        # 🔥 1. acompanhamentos pastorais (CORRIGIDO)
        conn.execute(text("""
            DELETE FROM acompanhamentos_pastorais
            WHERE fk_membro IN (
                SELECT id FROM membros WHERE fk_igreja = :id
            )
        """), {"id": id})

        # 🔥 2. músicos
        conn.execute(text("""
            DELETE FROM musicos 
            WHERE membro_id IN (
                SELECT id FROM membros WHERE fk_igreja = :id
            )
        """), {"id": id})

        # 🔥 3. membros
        conn.execute(text("""
            DELETE FROM membros 
            WHERE fk_igreja = :id
        """), {"id": id})

        # 🔥 4. congregações
        conn.execute(text("""
            DELETE FROM congregacoes 
            WHERE fk_igreja = :id
        """), {"id": id})

        # 🔥 5. igreja
        conn.execute(text("""
            DELETE FROM igrejas 
            WHERE id = :id
        """), {"id": id})

    return {"status": "ok"}






# ==========================================
# CONGREGAÇÕES
# ==========================================

from fastapi import HTTPException, Depends
from sqlalchemy import text


# ==========================
# LISTAR
# ==========================
@app.get("/congregacoes")
def listar_congregacoes():

    with engine.connect() as conn:

        result = conn.execute(text("""
            SELECT 
                c.*,
                i.nome_fantasia AS igreja
            FROM congregacoes c
            LEFT JOIN igrejas i ON i.id = c.fk_igreja
            ORDER BY c.id DESC
        """))

        return [dict(row._mapping) for row in result]


# ==========================
# CRIAR
# ==========================
@app.post("/congregacoes")
def criar_congregacao(dados: dict):

    with engine.begin() as conn:

        # 🔥 pega automaticamente a SEDE
        igreja = conn.execute(text("""
            SELECT id FROM igrejas 
            WHERE tipo = 'SEDE' 
            LIMIT 1
        """)).fetchone()

        if not igreja:
            raise HTTPException(
                status_code=400,
                detail="Nenhuma igreja sede cadastrada"
            )

        conn.execute(text("""
            INSERT INTO congregacoes (
                nome,
                endereco,
                cidade,
                estado,
                cep,
                telefone,
                email,
                data_fundacao,
                dirigente,
                tipo,
                fk_igreja
            )
            VALUES (
                :nome,
                :endereco,
                :cidade,
                :estado,
                :cep,
                :telefone,
                :email,
                :data_fundacao,
                :dirigente,
                'FILIAL',
                :igreja
            )
        """), {
            **dados,
            "igreja": igreja[0]
        })

    return {"status": "ok"}


# ==========================
# ATUALIZAR
# ==========================
@app.put("/congregacoes/{id}")
def atualizar_congregacao(id: int, dados: dict):

    # 🔥 trata data
    data_fundacao = dados.get("data_fundacao")

    if not data_fundacao or len(data_fundacao) < 10:
        data_fundacao = None  # evita erro no banco

    with engine.begin() as conn:

        conn.execute(text("""
            UPDATE congregacoes SET
                nome = :nome,
                endereco = :endereco,
                cidade = :cidade,
                estado = :estado,
                cep = :cep,
                telefone = :telefone,
                email = :email,
                data_fundacao = :data_fundacao,
                dirigente = :dirigente,
                tipo = 'FILIAL'
            WHERE id = :id
        """), {
            **dados,
            "data_fundacao": data_fundacao,
            "id": id
        })

    return {"status": "ok"}


# ==========================
# EXCLUIR
# ==========================
@app.delete("/congregacoes/{id}")
def excluir_congregacao(id: int):

    with engine.begin() as conn:

        # 🔥 remove membros primeiro (evita erro FK)
        conn.execute(text("""
            DELETE FROM membros 
            WHERE fk_congregacao = :id
        """), {"id": id})

        # 🔥 remove congregação
        conn.execute(text("""
            DELETE FROM congregacoes 
            WHERE id = :id
        """), {"id": id})

    return {"status": "ok"}




# ==========================================
# CÉLULAS
# ==========================================

@app.post("/celulas")
def criar_pg(dados: dict, user=Depends(verificar_token)):

    somente_admin(user)  # 🔥 BLOQUEIO

    with engine.connect() as conn:
        conn.execute(text("""
            INSERT INTO celulas (nome, lider, fk_igreja)
            VALUES (:nome, :lider, :igreja)
        """), {
            "nome": dados["nome"],
            "lider": dados["lider"],
            "igreja": user["igreja_id"]
        })

        conn.commit()

    return {"status": "pg criada"}






@app.get("/celulas")
def celulas(user=Depends(verificar_token)):

    with engine.connect() as conn:
        res = conn.execute(text("""
            SELECT id, nome, lider, dia_semana, bairro
            FROM celulas
            WHERE fk_igreja = :igreja
            ORDER BY nome
        """), {"igreja": user["igreja_id"]})

    return [dict(r._mapping) for r in res]





# ==========================================
# VOLUNTÁRIOS
# ==========================================

@app.post("/voluntarios")
def voluntarios(dados: dict, user=Depends(verificar_token)):

    with engine.connect() as conn:
        conn.execute(text("""
            INSERT INTO voluntarios (fk_membro, fk_evento, fk_igreja, funcao, status)
            VALUES (:fk_membro, :fk_evento, :igreja, :funcao, 'pendente')
        """), {
            "fk_membro": dados["membro_id"],
            "fk_evento": dados["evento_id"],
            "funcao": dados.get("funcao", ""),
            "igreja": user["igreja_id"]
        })

        conn.commit()

    return {"status": "ok"}


@app.get("/voluntarios/{evento_id}")
def listar_voluntarios_evento(evento_id: int, user=Depends(verificar_token)):

    with engine.connect() as conn:
        res = conn.execute(text("""
            SELECT v.id, m.nome, v.funcao, v.status
            FROM voluntarios v
            JOIN membros m ON m.id = v.fk_membro
            WHERE v.fk_evento = :evento
            AND v.fk_igreja = :igreja
            ORDER BY m.nome
        """), {
            "evento": evento_id,
            "igreja": user["igreja_id"]
        })

    return [dict(r._mapping) for r in res]


# ==========================================
# LISTAR VOLUNTÁRIOS
# ==========================================
@app.get("/voluntarios")
def listar_voluntarios(user=Depends(verificar_token)):

    with engine.connect() as conn:
        res = conn.execute(text("""
            SELECT v.id, m.nome, v.funcao, v.status
            FROM voluntarios v
            JOIN membros m ON m.id = v.fk_membro
            WHERE v.fk_igreja = :igreja
        """), {"igreja": user["igreja_id"]})

    return [dict(r._mapping) for r in res]


# ==========================================
# ESCALA
# ==========================================

@app.post("/escala/gerar_por_evento")
def gerar_escala(dados: dict, user=Depends(verificar_token)):

    # 🔥 VALIDAÇÃO (evita erro silencioso)
    evento_id = dados.get("evento_id")

    if not evento_id:
        raise HTTPException(status_code=400, detail="evento_id é obrigatório")

    if not user or not user.get("igreja_id"):
        raise HTTPException(status_code=401, detail="Usuário não autenticado")

    funcoes = ["Louvor", "Mídia", "Recepção", "Intercessão"]
    escala = []

    with engine.connect() as conn:

        for funcao in funcoes:

            res = conn.execute(text("""
                SELECT v.fk_membro, m.nome
                FROM voluntarios v
                JOIN membros m ON m.id = v.fk_membro
                WHERE v.fk_evento = :evento
                AND v.funcao = :funcao
                AND v.fk_igreja = :igreja
                LIMIT 1
            """), {
                "evento": evento_id,
                "funcao": funcao,
                "igreja": user["igreja_id"]
            }).fetchone()

            if res:
                escala.append({
                    "membro_id": res.fk_membro,
                    "nome": res.nome,
                    "funcao": funcao
                })

    return {
        "status": "ok",
        "escala": escala
    }


# ==========================================
# RANKING
# ==========================================

@app.get("/ranking")
def ranking(user=Depends(verificar_token)):

    if not user or not user.get("igreja_id"):
        raise HTTPException(status_code=401, detail="Usuário não autenticado")

    with engine.connect() as conn:
        res = conn.execute(text("""
            SELECT nome, total_escalas
            FROM membros
            WHERE fk_igreja = :igreja
            ORDER BY total_escalas DESC
        """), {"igreja": user["igreja_id"]}).fetchall()

    return [{"nome": r.nome, "total": r.total_escalas} for r in res]


# ==========================================
# MÚSICOS
# ==========================================

@app.get("/musicos")
def musicos(user=Depends(verificar_token)):

    with engine.connect() as conn:
        res = conn.execute(text("""
            SELECT m.id, mb.nome, m.instrumento, m.nivel
            FROM musicos m
            JOIN membros mb ON mb.id = m.membro_id
            WHERE mb.fk_igreja = :igreja
        """), {"igreja": user["igreja_id"]})

    return [dict(r._mapping) for r in res]


# ==========================================
# MUSICOS
# ==========================================

@app.post("/musicos")
def criar_musico(dados: dict, user=Depends(verificar_token)):

    with engine.connect() as conn:
        conn.execute(text("""
            INSERT INTO musicos (membro_id, instrumento, nivel, fk_igreja)
            VALUES (:membro_id, :instrumento, :nivel, :igreja)
        """), {
            "membro_id": dados["membro_id"],
            "instrumento": dados["instrumento"],
            "nivel": dados["nivel"],
            "igreja": user["igreja_id"]
        })

        conn.commit()

    return {"status": "ok"}



# ==========================================
# EBD
# ==========================================

@app.post("/ebd/presenca")
def salvar_presenca(dados: dict, user=Depends(verificar_token)):

    turma = dados.get("turma")
    lista = dados.get("presenca")

    with engine.connect() as conn:
        for item in lista:
            conn.execute(text("""
                INSERT INTO ebd_presenca 
                (fk_membro, turma, presente, fk_igreja, data)
                VALUES (:membro, :turma, :presente, :igreja, CURRENT_DATE)

                ON CONFLICT (fk_membro, turma, data, fk_igreja)
                DO UPDATE SET presente = EXCLUDED.presente
            """), {
                "membro": item["membro_id"],
                "turma": turma,
                "presente": item["presente"],
                "igreja": user["igreja_id"]
            })

        conn.commit()

    return {"msg": "ok"}



@app.get("/ebd/relatorio")
def relatorio_ebd(
    inicio: str = None,
    fim: str = None,
    turma: str = None,
    user=Depends(verificar_token)
):

    filtro_data = ""
    if inicio and fim:
        filtro_data = "AND e.data BETWEEN :inicio AND :fim"

    filtro_turma = ""
    if turma:
        filtro_turma = "AND e.turma = :turma"

    query = f"""
        SELECT m.nome,
               COUNT(*) FILTER (WHERE e.presente = true) AS presencas,
               COUNT(*) AS total_aulas,
               ROUND(
                   (COUNT(*) FILTER (WHERE e.presente = true)::decimal /
                    NULLIF(COUNT(*),0)) * 100, 2
               ) AS percentual
        FROM ebd_presenca e
        JOIN membros m ON m.id = e.fk_membro
        WHERE e.fk_igreja = :igreja
        {filtro_data}
        {filtro_turma}
        GROUP BY m.nome
        ORDER BY percentual DESC
    """

    params = {"igreja": user["igreja_id"]}

    if inicio and fim:
        params["inicio"] = inicio
        params["fim"] = fim

    if turma:
        params["turma"] = turma

    with engine.connect() as conn:
        res = conn.execute(text(query), params).fetchall()

    return [
        {
            "nome": r.nome,
            "presencas": r.presencas,
            "total": r.total_aulas,
            "percentual": float(r.percentual or 0)
        }
        for r in res
    ]


@app.get("/ebd/ultima")
def ultima_presenca(turma: str, user=Depends(verificar_token)):

    with engine.connect() as conn:
        res = conn.execute(text("""
            SELECT fk_membro, presente
            FROM ebd_presenca
            WHERE fk_igreja = :igreja
              AND turma = :turma
              AND data = (
                  SELECT MAX(data)
                  FROM ebd_presenca
                  WHERE fk_igreja = :igreja
                    AND turma = :turma
              )
        """), {
            "igreja": user["igreja_id"],
            "turma": turma
        }).fetchall()

    return [
        {"membro_id": r.fk_membro, "presente": r.presente}
        for r in res
    ]


@app.get("/ebd/ranking")
def ranking_ebd(user=Depends(verificar_token)):

    with engine.connect() as conn:
        res = conn.execute(text("""
            SELECT m.nome,
                   ROUND(
                       (COUNT(*) FILTER (WHERE e.presente = true)::decimal /
                        NULLIF(COUNT(*),0)) * 100, 2
                   ) AS percentual
            FROM ebd_presenca e
            JOIN membros m ON m.id = e.fk_membro
            WHERE e.fk_igreja = :igreja
            GROUP BY m.nome
            ORDER BY percentual DESC
            LIMIT 10
        """), {"igreja": user["igreja_id"]}).fetchall()

    return [{"nome": r.nome, "percentual": float(r.percentual)} for r in res]





# ==========================================
# CRIAR SEGMENTO
# ==========================================
@app.post("/segmentos")
def criar_segmento(dados: Segmento, user=Depends(verificar_token)):

    with engine.connect() as conn:
        conn.execute(text("""
            INSERT INTO segmentos_ebd (nome, fk_igreja)
            VALUES (:nome, :igreja)
        """), {
            "nome": dados.nome,
            "igreja": user["igreja_id"]
        })
        conn.commit()

    return {"status": "ok"}


# ==========================================
# LISTAR SEGMENTOS
# ==========================================
@app.get("/segmentos")
def listar_segmentos(user=Depends(verificar_token)):

    with engine.connect() as conn:
        res = conn.execute(text("""
            SELECT id, nome
            FROM segmentos_ebd
            WHERE fk_igreja = :igreja
            ORDER BY nome
        """), {"igreja": user["igreja_id"]})

    return [dict(r._mapping) for r in res]


# ==========================================
# DELETAR SEGMENTO
# ==========================================
@app.delete("/segmentos/{id}")
def deletar_segmento(id: int, user=Depends(verificar_token)):

    with engine.connect() as conn:
        conn.execute(text("""
            DELETE FROM segmentos_ebd
            WHERE id = :id AND fk_igreja = :igreja
        """), {
            "id": id,
            "igreja": user["igreja_id"]
        })
        conn.commit()

    return {"status": "deletado"}


# ==========================================
# EBD PARTE NOVA
# =========================================

@app.get("/ebd/membros-por-segmento")
def membros_por_segmento(user=Depends(verificar_token)):

    with engine.connect() as conn:
        res = conn.execute(text("""
            SELECT id, nome, data_nascimento
            FROM membros
            WHERE fk_igreja = :igreja
        """), {"igreja": user["igreja_id"]}).fetchall()

    dados = []

    for r in res:
        segmento = calcular_segmento(r.data_nascimento)
        dados.append({
            "id": r.id,
            "nome": r.nome,
            "segmento": segmento
        })



    return dados

from datetime import date

def calcular_segmento(data_nascimento):
    if not data_nascimento:
        return "Adulto"

    hoje = date.today()
    idade = hoje.year - data_nascimento.year

    # ajuste fino (corrige aniversário)
    if (hoje.month, hoje.day) < (data_nascimento.month, data_nascimento.day):
        idade -= 1

    if idade <= 6:
        return "Berçário"
    elif idade <= 11:
        return "Infantil"
    elif idade <= 18:
        return "Adolescente"
    elif idade <= 35:
        return "Jovens"
    else:
        return "Adulto"



@app.get("/ebd/frequencia")
def frequencia(user=Depends(verificar_token)):

    with engine.connect() as conn:
        res = conn.execute(text("""
            SELECT m.nome,
                   COUNT(*) FILTER (WHERE e.presente = true) AS presencas,
                   COUNT(*) AS total
            FROM ebd_presenca e
            JOIN membros m ON m.id = e.fk_membro
            WHERE e.fk_igreja = :igreja
            GROUP BY m.nome
        """), {"igreja": user["igreja_id"]}).fetchall()

    return [
        {
            "nome": r.nome,
            "presencas": r.presencas,
            "percentual": (r.presencas / r.total * 100) if r.total > 0 else 0
        }
        for r in res
    ]


@app.get("/ebd/alertas")
def alertas(user=Depends(verificar_token)):

    with engine.connect() as conn:
        res = conn.execute(text("""
            SELECT m.nome
            FROM membros m
            WHERE m.id NOT IN (
                SELECT fk_membro
                FROM ebd_presenca
                WHERE data >= CURRENT_DATE - INTERVAL '21 days'
                AND presente = true
            )
            AND m.fk_igreja = :igreja
        """), {"igreja": user["igreja_id"]}).fetchall()

    return [{"nome": r.nome} for r in res]

@app.get("/ebd/ranking")
def ranking(user=Depends(verificar_token)):

    with engine.connect() as conn:
        res = conn.execute(text("""
            SELECT m.nome,
                   COUNT(*) FILTER (WHERE e.presente = true) AS pontos
            FROM ebd_presenca e
            JOIN membros m ON m.id = e.fk_membro
            WHERE e.fk_igreja = :igreja
            GROUP BY m.nome
            ORDER BY pontos DESC
            LIMIT 10
        """), {"igreja": user["igreja_id"]}).fetchall()

    return [{"nome": r.nome, "pontos": r.pontos} for r in res]



@app.get("/ebd/dashboard")
def dashboard_ebd(user=Depends(verificar_token)):

    with engine.connect() as conn:

        total = conn.execute(text("""
            SELECT COUNT(*) FROM membros
            WHERE fk_igreja = :igreja
        """), {"igreja": user["igreja_id"]}).scalar()

        presentes = conn.execute(text("""
            SELECT COUNT(*) FROM ebd_presenca
            WHERE fk_igreja = :igreja
            AND data = CURRENT_DATE
            AND presente = true
        """), {"igreja": user["igreja_id"]}).scalar()

        frequencia = conn.execute(text("""
            SELECT 
                COUNT(*) FILTER (WHERE presente = true) * 100.0 / COUNT(*)
            FROM ebd_presenca
            WHERE fk_igreja = :igreja
        """), {"igreja": user["igreja_id"]}).scalar()

        ausentes = conn.execute(text("""
            SELECT COUNT(*) FROM membros
            WHERE id NOT IN (
                SELECT fk_membro FROM ebd_presenca
                WHERE data >= CURRENT_DATE - INTERVAL '21 days'
                AND presente = true
            )
            AND fk_igreja = :igreja
        """), {"igreja": user["igreja_id"]}).scalar()

    return {
        "total": total,
        "presentes": presentes,
        "frequencia": round(frequencia or 0, 2),
        "ausentes": ausentes
    }


@app.get("/ebd/grafico-segmento")
def grafico_segmento(user=Depends(verificar_token)):

    with engine.connect() as conn:
        res = conn.execute(text("""
            SELECT turma, COUNT(*) as total
            FROM ebd_presenca
            WHERE fk_igreja = :igreja
            GROUP BY turma
        """), {"igreja": user["igreja_id"]}).fetchall()

    return [{"segmento": r.turma, "total": r.total} for r in res]




@app.get("/ebd/grafico-semana")
def grafico_semana(user=Depends(verificar_token)):

    with engine.connect() as conn:
        res = conn.execute(text("""
            SELECT data, COUNT(*) as total
            FROM ebd_presenca
            WHERE fk_igreja = :igreja
            GROUP BY data
            ORDER BY data
            LIMIT 7
        """), {"igreja": user["igreja_id"]}).fetchall()

    return [{"data": str(r.data), "total": r.total} for r in res]



@app.post("/ebd/licoes")
def criar_licao(dados: dict, user=Depends(verificar_token)):

    with engine.connect() as conn:
        conn.execute(text("""
            INSERT INTO ebd_licoes (
                titulo,
                descricao,
                data,
                fk_igreja
            )
            VALUES (
                :titulo,
                :descricao,
                :data,
                :igreja
            )
        """), {
            "titulo": dados.get("titulo"),
            "descricao": dados.get("descricao"),
            "data": dados.get("data"),
            "igreja": user["igreja_id"]
        })

        conn.commit()

    return {"status": "ok"}


@app.get("/ebd/licao-atual")
def licao_atual(user=Depends(verificar_token)):

    with engine.connect() as conn:
        licao = conn.execute(text("""
            SELECT titulo, descricao
            FROM ebd_licoes
            WHERE fk_igreja = :igreja
            ORDER BY data DESC
            LIMIT 1
        """), {
            "igreja": user["igreja_id"]
        }).fetchone()

        if not licao:
            return {
                "titulo": "Sem lição definida",
                "descricao": ""
            }

        return {
            "titulo": licao.titulo,
            "descricao": licao.descricao
        }
    
    

    # ==========================
# LISTAR TURMAS
# ==========================
@app.get("/ebd/turmas")
def listar_turmas(user=Depends(verificar_token)):

    with engine.connect() as conn:
        result = conn.execute(text("""
            SELECT t.*, m.nome as professor_nome
            FROM ebd_turmas t
            LEFT JOIN membros m ON m.id = t.professor_id
            WHERE t.fk_igreja = :igreja
        """), {
            "igreja": user["igreja_id"]
        })

        return [dict(row._mapping) for row in result]


# ==========================
# CRIAR TURMA
# ==========================
@app.post("/ebd/turmas")
def criar_turma(dados: dict, user=Depends(verificar_token)):

    with engine.connect() as conn:
        conn.execute(text("""
            INSERT INTO ebd_turmas (
                nome,
                professor_id,
                fk_igreja
            )
            VALUES (
                :nome,
                :professor,
                :igreja
            )
        """), {
            "nome": dados.get("nome"),
            "professor": dados.get("professor_id"),
            "igreja": user["igreja_id"]
        })

        conn.commit()

    return {"status": "ok"}





# ==========================================
# CADASTRO DE IGREJA (SaaS)
# ==========================================

@app.post("/igrejas/cadastrar")
def cadastrar_igreja(dados: dict):

    with engine.connect() as conn:

        igreja = conn.execute(text("""
            INSERT INTO igrejas (nome, pix_chave, pix_nome, pix_cidade)
            VALUES (:nome, :chave, :pix_nome, :pix_cidade)
            RETURNING id
        """), {
            "nome": dados["nome"],
            "chave": dados.get("pix_chave"),
            "pix_nome": dados.get("pix_nome"),
            "pix_cidade": dados.get("pix_cidade")
        }).fetchone()

        # cria admin da igreja
        senha_hash = pwd_context.hash(dados["senha"])

        conn.execute(text("""
            INSERT INTO usuarios (nome, email, senha, tipo, fk_igreja)
            VALUES (:nome, :email, :senha, 'admin', :igreja)
        """), {
            "nome": dados["nome_admin"],
            "email": dados["email"],
            "senha": senha_hash,
            "igreja": igreja.id
        })

        conn.commit()

    return {"status": "igreja criada"}



@app.get("/pagamento/pix")
def gerar_pix(user=Depends(verificar_token)):

    return {
        "pix": "11999999999",
        "valor": "29.90",
        "descricao": "Plano Rebanho360"
    }



@app.get("/admin/igrejas")
def listar_igrejas(user=Depends(verificar_token)):

    if user["tipo"] != "superadmin":
        raise HTTPException(403)

    with engine.connect() as conn:
        res = conn.execute(text("SELECT * FROM igrejas"))

    return [dict(r._mapping) for r in res]



# ==========================================
# Painel ADM / PASTOR
# ==========================================

@app.get("/painel/atendimentos")
def painel_atendimentos(user=Depends(verificar_token)):

    with engine.connect() as conn:

        oracoes = conn.execute(text("""
            SELECT id, nome, pedido, status
            FROM pedidos_oracao
            WHERE fk_igreja = :igreja OR fk_igreja IS NULL
            ORDER BY id DESC
        """), {"igreja": user["igreja_id"]}).fetchall()

        agenda = conn.execute(text("""
            SELECT id, nome, data, status
            FROM agendamentos
            WHERE fk_igreja = :igreja OR fk_igreja IS NULL
            ORDER BY data DESC
        """), {"igreja": user["igreja_id"]}).fetchall()

        return {
            "oracoes": [dict(o._mapping) for o in oracoes],
            "agendamentos": [dict(a._mapping) for a in agenda]
        }
 
   
    
# ==========================================
# AGENDAMENTOS
# ==========================================

@app.post("/agendamento")
def criar_agendamento(dados: dict, user=Depends(verificar_token)):

    with engine.connect() as conn:

        conn.execute(text("""
            INSERT INTO agendamentos (
                nome, data, status, fk_igreja, fk_membro, resposta
            )
            VALUES (
                :nome, :data, 'pendente', :igreja, :membro, ''
            )
        """), {
            "nome": user.get("nome", "Membro"),
            "data": dados["data"],
            "igreja": user["igreja_id"],
            "membro": user["membro_id"]  # 🔥 ESSENCIAL
        })

        conn.commit()

    return {"status": "ok"}



@app.get("/agendamentos")
def listar_agendamentos(user=Depends(verificar_token)):

    with engine.connect() as conn:
        res = conn.execute(text("""
            SELECT * FROM agendamentos
            WHERE fk_igreja = :igreja
            ORDER BY data DESC
        """), {"igreja": user["igreja_id"]})

    return [dict(r._mapping) for r in res]



@app.put("/agendamentos/{id}")
def atualizar_status(id: int, status: str, user=Depends(verificar_token)):

    with engine.connect() as conn:
        conn.execute(text("""
            UPDATE agendamentos
            SET status=:status
            WHERE id=:id AND fk_igreja=:igreja
        """), {
            "id": id,
            "status": status,
            "igreja": user["igreja_id"]
        })

        conn.commit()

    return {"status": "ok"}



@app.put("/agendamento/responder/{id}")
def responder_agendamento(id: int, dados: dict, user=Depends(verificar_token)):

    with engine.connect() as conn:

        conn.execute(text("""
            UPDATE agendamentos
            SET resposta = :resposta,
                status = 'confirmado'
            WHERE id = :id
        """), {
            "resposta": dados.get("resposta"),
            "id": id
        })

        conn.commit()

    return {"status": "ok"}


@app.put("/agendamento/responder/{id}")
def responder_agendamento(id: int, dados: dict, user=Depends(verificar_token)):

    resposta = (dados.get("resposta") or "").strip()

    if not resposta:
        raise HTTPException(status_code=400, detail="Resposta obrigatória")

    with engine.connect() as conn:

        # 🔹 Atualiza resposta
        conn.execute(text("""
            UPDATE agendamentos
            SET resposta = :resposta,
                status = 'confirmado'
            WHERE id = :id
        """), {
            "resposta": resposta,
            "id": id
        })

        # 🔹 Busca membro
        ag = conn.execute(text("""
            SELECT fk_membro FROM agendamentos WHERE id = :id
        """), {"id": id}).fetchone()

        # 🔹 Notificação (CORRIGIDO)
        if ag and ag.fk_membro:
            conn.execute(text("""
                INSERT INTO notificacoes (fk_membro, mensagem)
                VALUES (:membro, :msg)
            """), {
                "membro": ag.fk_membro,
                "msg": "📅 Agendamento confirmado: " + resposta
            })

        conn.commit()

    return {"status": "ok"}




@app.get("/membro/agendamentos")
def meus_agendamentos(user=Depends(verificar_token)):

    with engine.connect() as conn:

        dados = conn.execute(text("""
            SELECT data, status, resposta
            FROM agendamentos
            WHERE fk_membro = :membro
            ORDER BY data DESC
        """), {
            "membro": user["membro_id"]
        }).fetchall()

        return [dict(d._mapping) for d in dados]



# ==========================================
# DEVOCIONAL
# ==========================================

@app.get("/devocional/hoje")
def devocional_hoje(user=Depends(verificar_token)):

    with engine.connect() as conn:

        dev = conn.execute(text("""
            SELECT titulo, versiculo, mensagem
            FROM devocional
            WHERE data = CURRENT_DATE
            AND fk_igreja = :igreja
        """), {
            "igreja": user["igreja_id"]
        }).fetchone()

        return dict(dev._mapping) if dev else {}
    



@app.post("/devocional")
def criar_devocional(dados: dict, user=Depends(verificar_token)):

    from datetime import date

    with engine.connect() as conn:

        conn.execute(text("""
            INSERT INTO devocional (
                data, titulo, versiculo, mensagem, oracao, fk_igreja
            )
            VALUES (
                :data, :titulo, :versiculo, :mensagem, :oracao, :igreja
            )
        """), {
            "data": dados.get("data", date.today()),  # 🔥 CORREÇÃO
            "titulo": dados["titulo"],
            "versiculo": dados["versiculo"],
            "mensagem": dados["mensagem"],
            "oracao": dados.get("oracao"),
            "igreja": user["igreja_id"]
        })

        conn.commit()

    return {"status": "ok"}





# ==========================================
# PEDIDOS DE ORAÇÃO
# ==========================================

@app.post("/oracao")
def criar_oracao(dados: dict, user=Depends(verificar_token)):

    with engine.connect() as conn:

        conn.execute(text("""
            INSERT INTO pedidos_oracao (
                nome, pedido, data, status, fk_igreja, fk_membro
            )
            VALUES (
                :nome, :pedido, CURRENT_DATE, 'pendente', :igreja, :membro
            )
        """), {
            "nome": user.get("nome", "Membro"),
            "pedido": dados["pedido"],
            "igreja": user["igreja_id"],
            "membro": user["membro_id"]  # 🔥 ESSENCIAL
        })

        conn.commit()

    return {"status": "ok"}




@app.get("/oracao")
def listar_oracao(user=Depends(verificar_token)):

    with engine.connect() as conn:
        res = conn.execute(text("""
            SELECT o.id, m.nome, o.pedido, o.data
            FROM oracao o
            JOIN membros m ON m.id = o.membro_id
            WHERE o.fk_igreja = :igreja
            ORDER BY o.data DESC
        """), {"igreja": user["igreja_id"]})

    return [dict(r._mapping) for r in res]



@app.put("/oracao/responder/{id}")
def responder_oracao(id: int, dados: dict, user=Depends(verificar_token)):

    resposta = (dados.get("resposta") or "").strip()

    if not resposta:
        raise HTTPException(status_code=400, detail="Resposta obrigatória")

    with engine.connect() as conn:

        # 🔹 Atualiza resposta
        conn.execute(text("""
            UPDATE pedidos_oracao
            SET resposta = :resposta,
                status = 'respondido'
            WHERE id = :id
        """), {
            "resposta": resposta,
            "id": id
        })

        # 🔹 Busca membro
        pedido = conn.execute(text("""
            SELECT fk_membro FROM pedidos_oracao WHERE id = :id
        """), {"id": id}).fetchone()

        # 🔹 Notificação
        if pedido and pedido.fk_membro:
            conn.execute(text("""
                INSERT INTO notificacoes (fk_membro, mensagem)
                VALUES (:membro, :msg)
            """), {
                "membro": pedido.fk_membro,
                "msg": "🙏 Resposta de oração: " + resposta
            })

        conn.commit()

    return {"status": "ok"}




@app.get("/membro/oracoes")
def minhas_oracoes(user=Depends(verificar_token)):

    with engine.connect() as conn:

        dados = conn.execute(text("""
            SELECT id, pedido, resposta, status, data
            FROM pedidos_oracao
            WHERE nome = :nome
            ORDER BY id DESC
        """), {
            "nome": user.get("nome", "Membro")
        }).fetchall()

        return [dict(d._mapping) for d in dados]





# ==========================================
# NOTIFICAÇÕES
# ==========================================
@app.get("/notificacoes")
def listar_notificacoes(user=Depends(verificar_token)):

    with engine.connect() as conn:

        notas = conn.execute(text("""
            SELECT * FROM notificacoes
            ORDER BY data DESC
        """)).fetchall()

        return [dict(n._mapping) for n in notas]
    



@app.get("/membro/notificacoes")
def notificacoes(user=Depends(verificar_token)):

    with engine.connect() as conn:

        dados = conn.execute(text("""
            SELECT id, titulo, mensagem, lida, data
            FROM notificacoes
            WHERE fk_membro = :membro
            ORDER BY id DESC
        """), {"membro": user["membro_id"]}).fetchall()

        return [dict(d._mapping) for d in dados]


@app.get("/membro/notificacoes/contador")
def contador_notificacoes(user=Depends(verificar_token)):

    with engine.connect() as conn:

        total = conn.execute(text("""
            SELECT COUNT(*) as total
            FROM notificacoes
            WHERE fk_membro = :membro
            AND lida = false
        """), {
            "membro": user["membro_id"]
        }).fetchone()

        return {"total": total.total}


@app.put("/membro/notificacoes/ler")
def marcar_lidas(user=Depends(verificar_token)):

    with engine.connect() as conn:

        conn.execute(text("""
            UPDATE notificacoes
            SET lida = true
            WHERE fk_membro = :membro
        """), {
            "membro": user["membro_id"]
        })

        conn.commit()

    return {"status": "ok"}



        
# ==========================================
# CHAT
# ==========================================

@app.post("/chat/enviar")
def enviar_chat(dados: dict, user=Depends(verificar_token)):

    if not user.get("membro_id"):
        return {"erro": "Usuário sem membro_id"}  # 🔥 trava erro

    with engine.connect() as conn:

        conn.execute(text("""
            INSERT INTO chat_mensagens (
                fk_remetente, fk_destinatario, mensagem
            )
            VALUES (:rem, :dest, :msg)
        """), {
            "rem": user["membro_id"],
            "dest": dados["destinatario"],
            "msg": dados["mensagem"]
        })

        conn.commit()

    return {"status": "ok"}




@app.get("/chat/conversa/{destinatario}")
def conversa(destinatario: int, user=Depends(verificar_token)):

    usuario = user.get("membro_id")

    with engine.connect() as conn:

        # 🔴 MARCAR COMO LIDA
        conn.execute(text("""
            UPDATE chat_mensagens
            SET lida = TRUE
            WHERE fk_destinatario = :eu
            AND fk_remetente = :outro
        """), {
            "eu": usuario,
            "outro": destinatario
        })

        conn.commit()

        dados = conn.execute(text("""
            SELECT fk_remetente, fk_destinatario, mensagem, data
            FROM chat_mensagens
            WHERE (fk_remetente = :eu AND fk_destinatario = :outro)
               OR (fk_remetente = :outro AND fk_destinatario = :eu)
            ORDER BY data ASC
        """), {
            "eu": usuario,
            "outro": destinatario
        }).fetchall()

        return [dict(d._mapping) for d in dados]
    


@app.get("/chat/conversas")
def listar_conversas(user=Depends(verificar_token)):

    usuario = user.get("membro_id")

    with engine.connect() as conn:

        dados = conn.execute(text("""
            SELECT DISTINCT ON (c.id)
                c.id as membro_id,
                c.nome,
                m.mensagem as ultima_mensagem,
                m.data,

                (
                  SELECT COUNT(*)
                  FROM chat_mensagens x
                  WHERE x.fk_remetente = c.id
                  AND x.fk_destinatario = :eu
                  AND x.lida = FALSE
                ) as nao_lidas

            FROM membros c
            JOIN chat_mensagens m 
              ON (m.fk_remetente = c.id OR m.fk_destinatario = c.id)

            WHERE (m.fk_remetente = :eu OR m.fk_destinatario = :eu)
              AND c.id != :eu

            ORDER BY c.id, m.data DESC
        """), {"eu": usuario}).fetchall()

        return [dict(d._mapping) for d in dados]
    





@app.get("/setup")
def setup_banco():
    with engine.connect() as conn:

        conn.execute(text("""
        CREATE TABLE IF NOT EXISTS usuarios (
            id SERIAL PRIMARY KEY,
            email TEXT,
            senha TEXT,
            tipo TEXT,
            fk_igreja INTEGER,
            fk_membro INTEGER
        );
        """))

        conn.execute(text("""
        INSERT INTO usuarios (email, senha, tipo)
        VALUES ('admin@rebanho360.com', '123456', 'admin')
        ON CONFLICT DO NOTHING;
        """))

        conn.commit()

    return {"status": "Banco configurado"}