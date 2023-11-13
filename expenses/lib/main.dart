// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'package:expenses/components/chart.dart';
import 'package:expenses/components/transaction_form.dart';
import 'package:expenses/database/db.dart';
import 'package:expenses/database/firebase/firebase_db.dart';
import 'package:flutter/material.dart';
import 'dart:math' hide log;
import 'dart:developer';
import './components/transaction_list.dart';
import 'models/transaction.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    DatabaseHelper.init(),
    FirebaseFirestoreTransactionsRepository.init(),
  ]);

  runApp(ExpensesApp());
}

class ExpensesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: StartPage(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Quicksand',
          textTheme: ThemeData.light().textTheme.copyWith(
                headline6: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                button: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
          appBarTheme: AppBarTheme(
            toolbarTextStyle: ThemeData.light()
                .textTheme
                .copyWith(
                  headline6: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
                .bodyText2,
            titleTextStyle: ThemeData.light()
                .textTheme
                .copyWith(
                  headline6: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
                .headline6,
          ),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
              .copyWith(secondary: Colors.amber),
        ));
  }
}

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bem-vindo'),
      ),
      body: Center(
        child: Builder(
          builder: (BuildContext newContext) {
            return ElevatedButton(
              onPressed: () {
                Navigator.of(newContext).push(
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(),
                  ),
                );
              },
              child: Text('Cadastrar transações'),
            );
          },
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
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
        Duration(days: 7),
      ));
    }).toList();
  }

  Future<void> _addTransaction(String categoria, String title, double value,
      String payment, DateTime date) async {
    String id = Random().nextInt(1000000).toString();
    while (_transactions.any((element) => element.id == id)) {
      id = Random().nextInt(1000000).toString();
    }
    // String categoria adicinada
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
          return TransactionForm(_addTransaction);
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
          title: Text('Minhas Despesas'),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              ListTile(
                title: Text('Formulário'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Tela inicial'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => StartPage(),
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
                TransactionList(_removeTransaciton, _getTransactions),
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
          child: Icon(Icons.add),
          onPressed:
              checkBoxValue ? () => _openTransactionFormModal(context) : null,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: BottomAppBar(
            child: CheckboxListTile(
          title: Text('Ativar/desativar botão'),
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
