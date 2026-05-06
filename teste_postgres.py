import psycopg2

conn = psycopg2.connect(
    host="localhost",
    dbname="igreja_db",
    user="postgres",
    password="9897",
    client_encoding="UTF8"
)

print("Conectou com sucesso!")

conn.close()
