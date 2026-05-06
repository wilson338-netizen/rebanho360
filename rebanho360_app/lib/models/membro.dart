class Membro {
  final int id;
  final String nome;
  final String? telefone;
  final String? cargo;
  final int? fkCongregacao;
  final int? fkFamilia;
  final String? dataNascimento;

  Membro({
    required this.id,
    required this.nome,
    this.telefone,
    this.cargo,
    this.fkCongregacao,
    this.fkFamilia,
    this.dataNascimento,
  });

  factory Membro.fromJson(Map json) {
    return Membro(
      id: int.parse(json["id"].toString()),
      nome: json["nome"] ?? "",
      telefone: json["telefone"],
      cargo: json["cargo"],
      fkCongregacao: json["fk_congregacao"] != null
          ? int.tryParse(json["fk_congregacao"].toString())
          : null,
      fkFamilia: json["fk_familia"] != null
          ? int.tryParse(json["fk_familia"].toString())
          : null,
      dataNascimento: json["data_nascimento"],
    );
  }
}
