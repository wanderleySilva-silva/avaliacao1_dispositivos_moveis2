import 'package:expenses/models/transaction.dart';
import 'package:flutter/material.dart';

class EditTransactionPage extends StatefulWidget {
  final Transacao transaction;
  final Function editHandler;

  EditTransactionPage(this.transaction, this.editHandler);

  @override
  _EditTransactionPageState createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  String? id;
  String? category;
  String? title;
  double? valor;
  String? payment;
  DateTime? date;

  @override
  void initState() {
    super.initState();
    id = widget.transaction.id;
    category = widget.transaction.category;
    title = widget.transaction.title;
    valor = widget.transaction.value;
    payment = widget.transaction.payment;
    date = widget.transaction.date;
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      var newTransaction = Transacao(
        id: widget.transaction.id,
        category: category!,
        title: title!,
        value: valor!,
        payment: payment!,
        date: date!,
      );

      widget.editHandler(newTransaction);

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('Editar Transação'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: id,
                decoration: const InputDecoration(labelText: 'Id'),
                onSaved: (value) => id = value,
              ),
              TextFormField(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Category'),
                onSaved: (value) => category = value,
              ),
              TextFormField(
                initialValue: title,
                decoration: const InputDecoration(labelText: 'Title'),
                onSaved: (value) => title = value,
              ),
              TextFormField(
                initialValue: valor.toString(),
                decoration: const InputDecoration(labelText: 'Value'),
                keyboardType: TextInputType.number,
                onSaved: (value) => valor = double.parse(value ?? '0'),
              ),
              TextFormField(
                initialValue: payment,
                decoration: const InputDecoration(labelText: 'Payment'),
                onSaved: (value) => payment = value,
              ),
              TextFormField(
                initialValue: date.toString(),
                decoration: const InputDecoration(labelText: 'Date'),
                onSaved: (value) => date = date,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    child: const Text('Salvar'),
                    onPressed: _save,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.purple),
                      
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
