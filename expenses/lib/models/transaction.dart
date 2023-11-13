import 'dart:convert';

List<Transacao> transacaoFromJson(String str) =>
    List<Transacao>.from(json.decode(str).map((x) => Transacao.fromJson(x)));

String employeeToJson(List<Transacao> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Transacao {
  String id;
  String category;
  String title;
  double value;
  String payment;
  DateTime date;

  Transacao({
    required this.id,
    required this.category,
    required this.title,
    required this.value,
    required this.payment,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'value': value,
      'payment': payment,
      'date': date.toIso8601String(), // Converte a data para um formato que pode ser armazenado no banco de dados
    };
  }

  factory Transacao.fromJson(Map<String, dynamic> json) => Transacao(
        id: '${json['id']}',
        category: json['category'],
        title: json['title'],
        value: (json['value'] as num).toDouble(),
        payment: json['payment'],
        date: DateTime.parse((json['date'] as String).split('/').reversed.join('-')),
      );
}
