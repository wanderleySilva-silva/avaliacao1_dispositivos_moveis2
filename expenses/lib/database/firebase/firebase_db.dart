import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/firebase_options.dart';
import 'package:expenses/models/transaction.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseFirestoreTransactionsRepository {
  static FirebaseFirestoreTransactionsRepository? _instance;

  final CollectionReference<Transacao> _database;

  const FirebaseFirestoreTransactionsRepository._internal(this._database);

  static Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // { 'name': 'trasacao', 'value': 30.0 }

    final collection = FirebaseFirestore.instance.collection('transacoes').withConverter<Transacao>(
          fromFirestore: (snapshot, _) =>
              Transacao.fromJson({'id': snapshot.id, ...snapshot.data()!}),
          toFirestore: (value, _) => value.toJson(),
        );

    _instance ??= FirebaseFirestoreTransactionsRepository._internal(collection);
  }

  static FirebaseFirestoreTransactionsRepository get instance {
    assert(_instance != null);
    return _instance!;
  }

  Future<List<Transacao>> getTransactions() async {
    return (await _database.get()).docs.map((snapshot) => snapshot.data()).toList();
  }

  Future<void> save(Transacao transacao) async {
    await _database.doc(transacao.id).set(transacao);
  }

  Future<void> delete(String transacaoId) async {
    await _database.doc(transacaoId).delete();
  }
}
