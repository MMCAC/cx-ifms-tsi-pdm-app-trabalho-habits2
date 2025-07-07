class HabitoConcluido {
  final String id;
  final String habitoId;
  final String nome;
  final DateTime dataConclusao;

  HabitoConcluido({
    required this.id,
    required this.habitoId,
    required this.nome,
    required this.dataConclusao,
  });

  factory HabitoConcluido.fromJson(Map<String, dynamic> json) {
    return HabitoConcluido(
      id: json['_id'],
      habitoId: json['habitoId'],
      nome: json['nome'],
      dataConclusao: DateTime.parse(json['dataConclusao']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'habitoId': habitoId,
      'nome': nome,
    };
  }
}
