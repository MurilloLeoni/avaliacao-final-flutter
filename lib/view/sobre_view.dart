//ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class SobreView extends StatefulWidget {
  const SobreView({Key? key}) : super(key: key);

  @override
  State<SobreView> createState() => _SobreViewState();
}

class _SobreViewState extends State<SobreView> {
  final txtValor3 = TextEditingController();
  final txtValor4 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o APP'),
        backgroundColor: Colors.grey[300],
      ),
      body: Container(
        color: Colors.grey[100],
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tema escolhido:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Organizador de anotações.', // ATUALIZAR TEMA
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Objetivo do aplicativo:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Criar anotações de forma simples e objetiva.', // ATUALIZAR OBJETIVO
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Desenvolvedores:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Murillo Leoni', //  NOMES
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Carlos Germano G. de Souza', //  NOMES
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, 'login');
                  },
                  child: Text('Voltar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
