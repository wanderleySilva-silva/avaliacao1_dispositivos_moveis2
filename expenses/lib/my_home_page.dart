import 'package:expenses/components/chart.dart';
import 'package:expenses/components/transaction_form.dart';
import 'package:expenses/components/transaction_list.dart';
import 'package:expenses/database/db.dart';
import 'package:expenses/database/firebase/firebase_db.dart';
import 'package:expenses/models/transaction.dart';
import 'package:expenses/starter_page.dart';
import 'package:flutter/material.dart';
import 'dart:math' hide log;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isDarkMode = false; // Linha adicionada
  bool checkBoxValue = false;

  final transactionsFirestoreRepository =
      FirebaseFirestoreTransactionsRepository.instance;

  final transactionsSqliteRepository = DatabaseHelper.instance;

  final List<Transacao> _transactions = [];

  List<Transacao> get _recentTransactions {
    return _transactions.where((tr) {
      return tr.date.isAfter(DateTime.now().subtract(
        const Duration(days: 7),
      ));
    }).toList();
  }

  String id = Random().nextInt(1000000).toString();

  Future<void> _addTransaction(String categoria, String title, double value,
      String payment, DateTime date) async {
    while (_transactions.any((element) => element.id == id)) {
      id = Random().nextInt(1000000).toString();
    }
    // String categoria adicionada
    final newTransaction = Transacao(
      id: id,
      category: categoria, // Linha adicionada
      title: title,
      value: value,
      payment: payment,
      date: date,
    );

    await transactionsFirestoreRepository.save(newTransaction);
    await transactionsSqliteRepository.insertTransaction(newTransaction);

    setState(() {
      _transactions.add(newTransaction);
    });

    Navigator.of(context).pop();
  }

  Future<void> _editTransaction(Transacao editedTransaction) async {
    // Encontre a transação que precisa ser editada
    var transaction =
        _transactions.firstWhere((t) => t.id == editedTransaction.id);

    // Atualize a transação no Firestore e no SQLite
    await transactionsFirestoreRepository.save(editedTransaction);
    await transactionsSqliteRepository.insertTransaction(editedTransaction);

    setState(() {
      _transactions[_transactions.indexOf(transaction)] = editedTransaction;
    });

    Navigator.of(context).pop();
  }

  Future<void> _removeTransaciton(String id) async {
    await transactionsFirestoreRepository.delete(id);
    setState(() {
      _transactions.removeWhere((tr) => tr.id == id);
    });
  }

  void _openTransactionFormModal(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return TransactionForm(
            _addTransaction,
          );
        });
  }

  Future<List<Transacao>> _getTransactions() async {
    if (_transactions.isNotEmpty) return _transactions;

    final transacations =
        await transactionsFirestoreRepository.getTransactions();

    setState(() {
      _transactions.addAll(transacations);
    });

    return transacations;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
        isDarkMode ? ThemeData.dark() : ThemeData.light(); // Linha adicionada

    return MaterialApp(
      theme: theme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          title: const Text('Minhas Despesas'),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              ListTile(
                title: const Text('Formulário'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Tela inicial'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const StartPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Chart(_recentTransactions),
                TransactionList(
                    _editTransaction, _removeTransaciton, _getTransactions),
                Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    setState(
                      () {
                        isDarkMode = value;
                      },
                    );
                  },
                )
              ]),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed:
              checkBoxValue ? () => _openTransactionFormModal(context) : null,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: BottomAppBar(
            child: CheckboxListTile(
          title: const Text('Ativar/desativar botão'),
          value: checkBoxValue,
          onChanged: (value) {
            setState(() {
              checkBoxValue = value!;
            });
          },
        )),
      ),
    );
  }
}
