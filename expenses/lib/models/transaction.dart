
class Transacao {
  
  final String id;
  final String category;
  final String title;
  final double value;
  final String payment;
  final DateTime date;

  Transacao(this.id, this.category, this.title, this.value, this.payment, this.date);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'value': value,
      'payment': payment,
      'date': date.toIso8601String(), // Converte a data para um formato que pode ser armazenado no banco de dados
    };
  }
}
