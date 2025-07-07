class Habito {
  final String id;
   String nome;
  final bool seg, ter, qua, qui, sex, sab, dom;

  Habito({
    required this.id,
    required this.nome,
    required this.seg,
    required this.ter,
    required this.qua,
    required this.qui,
    required this.sex,
    required this.sab,
    required this.dom,
  });

  factory Habito.fromJson(Map<String, dynamic> json) {
    return Habito(
      id: json['_id'],
      nome: json['nome'],
      seg: json['seg'],
      ter: json['ter'],
      qua: json['qua'],
      qui: json['qui'],
      sex: json['sex'],
      sab: json['sab'],
      dom: json['dom'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'seg': seg,
      'ter': ter,
      'qua': qua,
      'qui': qui,
      'sex': sex,
      'sab': sab,
      'dom': dom,
    };
  }
}
