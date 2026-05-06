import tkinter as tk
from tkinter import messagebox
from fila import adicionar_cliente, atender_cliente, ver_fila
from fila_prioritaria import (
    adicionar_prioritario,
    atender_prioritario,
    ver_fila_prioritaria,
    tem_prioritario
)
from historico import registrar_atendimento, mostrar_historico
from estatisticas import registrar_atendimento_atendente


# ----- FUNÇÕES -----

def atualizar_fila():
    lista_fila.delete(0, tk.END)
    for posicao, nome in ver_fila():
        lista_fila.insert(tk.END, f"{posicao}º - {nome}")

def atualizar_historico():
    lista_historico.delete(0, tk.END)
    for item in mostrar_historico():
        lista_historico.insert(tk.END, f"{item['nome']} ({item['tipo']})")

def adicionar_cliente_gui():
    nome = entry_cliente.get()
    if nome:
        adicionar_cliente(nome)
        entry_cliente.delete(0, tk.END)
        atualizar_fila()
    else:
        messagebox.showwarning("Aviso", "Digite o nome do cliente.")

def atender_cliente_gui():
    atendente = entry_atendente.get()
    if not atendente:
        messagebox.showwarning("Aviso", "Digite o nome do atendente.")
        return

    if tem_prioritario():
        cliente = atender_prioritario()
        tipo = "prioritario"
    else:
        cliente = atender_cliente()
        tipo = "normal"

    if cliente:
        registrar_atendimento(cliente, tipo)
        registrar_atendimento_atendente(atendente)
        messagebox.showinfo("Atendimento", f"Atendendo {cliente}")
        atualizar_fila()
        atualizar_historico()
    else:
        messagebox.showinfo("Info", "Fila vazia.")


# ----- JANELA -----

janela = tk.Tk()
janela.title("Sistema de Atendimento")
janela.geometry("500x500")

# Cliente
tk.Label(janela, text="Nome do Cliente").pack()
entry_cliente = tk.Entry(janela)
entry_cliente.pack()

tk.Button(janela, text="Adicionar Cliente", command=adicionar_cliente_gui).pack(pady=5)

# Atendente
tk.Label(janela, text="Nome do Atendente").pack()
entry_atendente = tk.Entry(janela)
entry_atendente.pack()

tk.Button(janela, text="Atender Próximo", command=atender_cliente_gui).pack(pady=10)

# Fila
tk.Label(janela, text="Fila Normal").pack()
lista_fila = tk.Listbox(janela, width=50)
lista_fila.pack(pady=5)

# Histórico
tk.Label(janela, text="Histórico").pack()
lista_historico = tk.Listbox(janela, width=50)
lista_historico.pack(pady=5)

atualizar_fila()
atualizar_historico()

janela.mainloop()
