fila_prioritaria = []

def adicionar_prioritario(nome):
    fila_prioritaria.append(nome)

def atender_prioritario():
    if fila_prioritaria:
        return fila_prioritaria.pop(0)
    return None

def ver_fila_prioritaria():
    return fila_prioritaria

def tem_prioritario():
    return len(fila_prioritaria) > 0
