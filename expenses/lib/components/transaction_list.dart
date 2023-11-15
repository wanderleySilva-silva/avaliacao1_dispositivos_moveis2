import 'dart:developer';

import 'package:expenses/components/edition_transaction_page.dart';
import 'package:expenses/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionList extends StatelessWidget {
  final Function editHandler;
  final void Function(String) onRemove;
  final Future<List<Transacao>> Function() getTransactions;

  const TransactionList(
    this.editHandler,
    this.onRemove,
    this.getTransactions, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Transacao>>(
      future: getTransactions(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
            final transactions = snapshot.data!;
            return SizedBox(
              height: 430,
              child: transactions.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Nenhuma transação cadastrada',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 200,
                          child: Image.asset(
                            'assets/images/waiting.png',
                            fit: BoxFit.cover,
                          ),
                        )
                      ],
                    )
                  : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (ctx, index) {
                        final tr = transactions[index];
                        log('${tr.toJson()}');
                        return Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 5,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 30,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: FittedBox(
                                  child: Text('R\$${tr.value}'),
                                ),
                              ),
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Id: " + tr.id,
                                ),
                                Text(
                                  "Título: " + tr.title,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  "Categoria: " + tr.category,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  "Forma de pagamento: " + tr.payment,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),
                            subtitle: Text(
                              DateFormat('d MMM yyy').format(tr.date),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditTransactionPage(
                                                tr, editHandler),
                                      ),
                                    );
                                  },
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => onRemove(tr.id),
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            );
          default:
            return const Center(
              child: Text('Nenhum estado encontrado.'),
            );
        }
      },
    );
  }
}
