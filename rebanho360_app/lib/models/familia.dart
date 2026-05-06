class Familia {
  final int id;
  final String nome;
  final String? telefone;

  Familia({
    required this.id,
    required this.nome,
    this.telefone,
  });

  factory Familia.fromJson(Map json) {
    return Familia(
      id: int.parse(json["id"].toString()),
      nome: json["nome"] ?? "",
      telefone: json["telefone"],
    );
  }
}