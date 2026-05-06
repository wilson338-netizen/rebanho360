from fila import adicionar_cliente, atender_cliente, ver_fila
from fila_prioritaria import (
    adicionar_prioritario,
    atender_prioritario,
    ver_fila_prioritaria,
    tem_prioritario
)
from historico import registrar_atendimento, mostrar_historico
from estatisticas import registrar_atendimento_atendente, mostrar_estatisticas
import csv


def gerar_relatorio_csv():
    historico = mostrar_historico()
    stats = mostrar_estatisticas()

    with open("relatorio_atendimentos.csv", "w", newline="", encoding="utf-8") as arquivo:
        writer = csv.writer(arquivo)

        writer.writerow(["RELATÓRIO DE ATENDIMENTOS"])
        writer.writerow([])

        writer.writerow(["Cliente", "Tipo"])
        for item in historico:
            writer.writerow([item["nome"], item["tipo"]])

        writer.writerow([])
        writer.writerow(["Estatísticas por Atendente"])
        writer.writerow(["Atendente", "Quantidade"])

        for nome, qtd in stats.items():
            writer.writerow([nome, qtd])

    print("Relatório CSV gerado com sucesso!")


while True:
    print("\n--- SISTEMA DE ATENDIMENTO ---")
    print("1 - Adicionar cliente normal")
    print("2 - Atender próximo cliente")
    print("3 - Ver fila normal")
    print("4 - Adicionar cliente prioritário")
    print("5 - Ver fila prioritária")
    print("6 - Ver histórico de atendimentos")
    print("7 - Ver estatísticas por atendente")
    print("8 - Gerar relatório CSV")
    print("0 - Sair")

    opcao = input("Escolha uma opção: ")

    if opcao == "1":
        nome = input("Nome do cliente: ")
        adicionar_cliente(nome)
        print(f"{nome} adicionado à fila normal.")

    elif opcao == "2":
        atendente = input("Nome do atendente: ")

        if tem_prioritario():
            cliente = atender_prioritario()
            registrar_atendimento(cliente, "prioritario")
            registrar_atendimento_atendente(atendente)
            print(f"Atendendo PRIORITÁRIO: {cliente}")

        else:
            cliente = atender_cliente()
            if cliente:
                registrar_atendimento(cliente, "normal")
                registrar_atendimento_atendente(atendente)
                print(f"Atendendo {cliente}...")
            else:
                print("Fila vazia.")

    elif opcao == "3":
        fila_atual = ver_fila()
        if fila_atual:
            print("\n--- FILA NORMAL ---")
            for posicao, nome in fila_atual:
                print(f"{posicao}º - {nome}")
        else:
            print("Fila normal vazia.")

    elif opcao == "4":
        nome = input("Nome do cliente prioritário: ")
        adicionar_prioritario(nome)
        print(f"{nome} adicionado à fila prioritária.")

    elif opcao == "5":
        fila_prio = ver_fila_prioritaria()
        if fila_prio:
            print("\n--- FILA PRIORITÁRIA ---")
            for i, nome in enumerate(fila_prio, start=1):
                print(f"{i}º - {nome}")
        else:
            print("Fila prioritária vazia.")

    elif opcao == "6":
        historico = mostrar_historico()
        if historico:
            print("\n--- HISTÓRICO ---")
            for item in historico:
                print(f"{item['nome']} ({item['tipo']})")
        else:
            print("Nenhum atendimento realizado.")

    elif opcao == "7":
        stats = mostrar_estatisticas()
        if stats:
            print("\n--- ESTATÍSTICAS ---")
            ordenado = sorted(stats.items(), key=lambda x: x[1], reverse=True)
            for nome, qtd in ordenado:
                print(f"{nome} realizou {qtd} atendimentos.")
        else:
            print("Nenhum atendimento registrado.")

    elif opcao == "8":
        gerar_relatorio_csv()

    elif opcao == "0":
        print("Encerrando sistema...")
        break

    else:
        print("Opção inválida.")