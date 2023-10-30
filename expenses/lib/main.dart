// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'package:expenses/components/chart.dart';
import 'package:expenses/components/transaction_form.dart';
import 'package:expenses/database/db.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart';
import 'dart:math';
import './components/transaction_list.dart';
import 'models/transaction.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper().initDatabase();

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

  final List<Transacao> _transactions = [];

  List<Transacao> get _recentTransactions {
    return _transactions.where((tr) {
      return tr.date.isAfter(DateTime.now().subtract(
        Duration(days: 7),
      ));
    }).toList();
  }

  _addTransaction(String categoria, String title, double value, String payment,
      DateTime date) {
    // String categoria adicinada
    final newTransaction = Transacao(
      Random().nextDouble().toString(),
      categoria, // Linha adicionada
      title,
      value,
      payment,
      date,
    );

    setState(() {
      _transactions.add(newTransaction);
    });

    Navigator.of(context).pop();
  }

  _removeTransaciton(String id) {
    setState(() {
      _transactions.removeWhere((tr) => tr.id == id);
    });
  }

  _openTransactionFormModal(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return TransactionForm(_addTransaction);
        });
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
                TransactionList(_transactions, _removeTransaciton),
                Switch(
                    value: isDarkMode, // Linha adicionada
                    onChanged: (value) {
                      // Linha adicionada
                      setState(() {
                        // Linha adicionada
                        isDarkMode = value; // Linha adicionada
                      }); // Linha adicionada
                    })

                /// Linha adicionada
              ]),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: checkBoxValue ? () => _openTransactionFormModal(context) : null,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: BottomAppBar(
          child: CheckboxListTile(
            title: Text('Ativar/desativar botão'),
            value: checkBoxValue,
            onChanged: (value){
              setState(() {
                checkBoxValue = value!;
              });
            },
          )),
      ),
    );
  }
}
