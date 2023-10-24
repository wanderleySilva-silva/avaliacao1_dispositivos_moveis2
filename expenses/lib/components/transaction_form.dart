import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionForm extends StatefulWidget {
  final void Function(String, String, double, DateTime)
      onSubmit; // String adicionada

  TransactionForm(this.onSubmit);

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>(); // Linha adicionada
  final _categoryController = TextEditingController(); // Linha adicionada
  final _titleController = TextEditingController();
  final _valueController = TextEditingController();


  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = "";
  String _selectedPayment = "";


  List<String> _categoryList = [
    'Entretenimento',
    'Alimentação',
    'Saúde',
    'Outros'
  ];

  _submitForm() {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      final category = _categoryController.text; // Linha adicionada
      final title = _titleController.text;
      final value = double.tryParse(_valueController.text) ?? 0.0;
      widget.onSubmit(_selectedCategory, title, value,
          _selectedDate); // categoria adicionada
    }
  }

  //Mostrar seletor de datas
  _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategory.isEmpty ? null : _selectedCategory,
                items: _categoryList.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedCategory = value ?? '';
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Categoria',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, escolha uma categoria';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _titleController,
                onFieldSubmitted: (_) => _submitForm(),
                decoration: InputDecoration(
                  labelText: 'Título',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, preencha o título';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _valueController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onFieldSubmitted: (_) => _submitForm(),
                decoration: InputDecoration(
                  labelText: 'Valor (R\$)',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, preencha o valor';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Digite um valor numérico válido';
                  }
                  return null;
                },
              ),
              Text('Opção de Pagamento:'),
              Row(
                children: <Widget>[
                  Radio<String>(
                    value: 'Cartão de Crédito',
                    groupValue: _selectedPayment,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedPayment = value!;
                      });
                    },
                  ),
                  Text('Cartão de Crédito'),
                  Radio<String>(
                    value: 'PIX',
                    groupValue: _selectedPayment,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedPayment = value!;
                      });
                    },
                  ),
                  Text('PIX'),
                  Radio<String>(
                    value: 'Dinheiro em espécie',
                    groupValue: _selectedPayment,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedPayment = value!;
                      });
                    },
                  ),
                  Text('Dinheiro em espécie'),
                ],
              ),
              Container(
                height: 70,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'Nenhuma data selecionada!'
                            : 'Data selecionada: ${DateFormat('dd/MM/y').format(_selectedDate)}',
                      ),
                    ),
                    TextButton(
                      onPressed: _showDatePicker,
                      child: Text(
                        'Selecionar data!',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(
                      'Adicionar transação',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
