import heapq

fila_prioridade = []

def adicionar_prioritario(nome, prioridade):
    heapq.heappush(fila_prioridade, (prioridade, nome))

def atender_prioritario():
    if fila_prioridade:
        return heapq.heappop(fila_prioridade)[1]
    return None

def tem_prioritario():
    return len(fila_prioridade) > 0
