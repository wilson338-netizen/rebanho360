TextField(controller: titulo),
TextField(controller: descricao),

ElevatedButton(
  onPressed: () async {
    await ApiService.post("/ebd/licoes", {
      "titulo": titulo.text,
      "descricao": descricao.text,
      "data": DateTime.now().toIso8601String(),
    });
  },
  child: Text("Salvar Lição"),
)

