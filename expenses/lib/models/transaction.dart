
class Transaction {
  
  final String id;
  final String category;
  //final String payment;
  final String title;
  final double value;
  final DateTime date;
  

  Transaction(this.id, this.category, this.title, this.value, this.date);
}
