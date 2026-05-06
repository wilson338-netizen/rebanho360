fila = []

def adicionar_cliente(nome):
    fila.append(nome)

def atender_cliente():
    if fila:
        return fila.pop(0)
    return None

def ver_fila():
    return list(enumerate(fila, start=1))