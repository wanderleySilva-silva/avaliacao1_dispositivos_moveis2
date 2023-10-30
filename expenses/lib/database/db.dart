import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';
import 'package:expenses/models/transaction.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    
    final caminho = await path_provider.getApplicationCacheDirectory();
    log(caminho.path);
    
    String path = join(caminho.path, 'transactions.db');

    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id TEXT PRIMARY KEY,
        category TEXT,
        title TEXT,
        value REAL,
        payment TEXT,
        date TEXT
      )
    ''');
  }

  Future<void> insertTransaction(Transacao transaction) async {
    Database db = await database;
    
    await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Transacao>> getTransactions() async {
    Database db = await database;

    List<Map<String, dynamic>> maps = await db.query('transactions');

    return List.generate(maps.length, (i) {
      return Transacao(
        maps[i]['id'],
        maps[i]['category'],
        maps[i]['title'],
        maps[i]['value'],
        maps[i]['payment'],
        DateTime.parse(maps[i]['date']),
      );
    });
  }
}
