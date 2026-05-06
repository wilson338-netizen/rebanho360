import json
import os

ARQUIVO = "estatisticas.json"

if os.path.exists(ARQUIVO):
    with open(ARQUIVO, "r") as f:
        atendimentos_por_atendente = json.load(f)
else:
    atendimentos_por_atendente = {}

def registrar_atendimento_atendente(nome_atendente):
    if nome_atendente in atendimentos_por_atendente:
        atendimentos_por_atendente[nome_atendente] += 1
    else:
        atendimentos_por_atendente[nome_atendente] = 1
    salvar()

def mostrar_estatisticas():
    return atendimentos_por_atendente

def salvar():
    with open(ARQUIVO, "w") as f:
        json.dump(atendimentos_por_atendente, f, indent=4)
        