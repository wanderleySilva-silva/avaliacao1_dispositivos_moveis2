import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:expenses/models/transaction.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class DatabaseHelper {
  static DatabaseHelper? _instance;
  final Database _database;

  const DatabaseHelper._internal(this._database);

  static Future<void> init() async {
    if (_instance != null) return;

    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    final path = join(documentsDirectory.path, 'transactions.db');
    final database = await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE transactions('
            'id TEXT PRIMARY KEY,'
            'category TEXT,'
            'title TEXT,'
            'value REAL,'
            'payment TEXT,'
            'date TEXT'
            ')');
      },
    );
    _instance ??= DatabaseHelper._internal(database);
  }

  static DatabaseHelper get instance {
    assert(_instance != null);
    return _instance!;
  }

  Future<void> insertTransaction(Transacao transaction) async {
    await _database.insert(
      'transactions',
      transaction.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Transacao>> getTransactions() async {
    List<Map<String, dynamic>> maps = await _database.query('transactions');

    return List.generate(maps.length, (i) {
      return Transacao(
        id: maps[i]['id'],
        category: maps[i]['category'],
        title: maps[i]['title'],
        value: maps[i]['value'],
        payment: maps[i]['payment'],
        date: DateTime.parse(maps[i]['date']),
      );
    });
  }
}
