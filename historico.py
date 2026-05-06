import json
import os

ARQUIVO = "historico.json"

if os.path.exists(ARQUIVO):
    with open(ARQUIVO, "r") as f:
        historico = json.load(f)
else:
    historico = []

def registrar_atendimento(nome_cliente, tipo):
    historico.append({
        "nome": nome_cliente,
        "tipo": tipo
    })
    salvar()

def mostrar_historico():
    return historico

def salvar():
    with open(ARQUIVO, "w") as f:
        json.dump(historico, f, indent=4)