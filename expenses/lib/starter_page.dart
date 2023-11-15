import 'package:expenses/my_home_page.dart';
import 'package:flutter/material.dart';

class StartPage extends StatelessWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bem-vindo'),
      ),
      body: Center(
        child: Builder(
          builder: (BuildContext newContext) {
            return ElevatedButton(
              onPressed: () {
                Navigator.of(newContext).push(
                  MaterialPageRoute(
                    builder: (context) => const MyHomePage(),
                  ),
                );
              },
              child: const Text('Ir para as transações'),
            );
          },
        ),
      ),
    );
  }
}
