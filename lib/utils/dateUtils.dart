class DateUtilsHelper {
  static String nomeDiaSemana(int weekday) {
    const dias = [
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo',
    ];
    return dias[weekday - 1];
  }

  static bool eHoje(DateTime data) {
    final agora = DateTime.now();
    return data.year == agora.year &&
        data.month == agora.month &&
        data.day == agora.day;
  }

  static String formatarData(DateTime data) {
    return "${data.day.toString().padLeft(2, '0')}/"
           "${data.month.toString().padLeft(2, '0')}/"
           "${data.year}";
  }

  static bool mesmaSemana(DateTime data) {
    final agora = DateTime.now();
    final diferenca = agora.difference(data).inDays;
    return diferenca >= 0 && diferenca < 7 && data.weekday <= agora.weekday;
  }
}
