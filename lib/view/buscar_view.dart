//teste
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controller/tarefa_controller.dart';

class BuscaView extends StatefulWidget {
  @override
  _BuscaViewState createState() => _BuscaViewState();
}

class _BuscaViewState extends State<BuscaView> {
  var txtSearch = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar Tarefas'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                searchQuery = txtSearch.text;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: txtSearch,
              decoration: InputDecoration(
                labelText: 'Palavra-Chave',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: TarefaController().listar().snapshots(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                      final dados = snapshot.requireData;
                      final filteredDocs = dados.docs.where((doc) {
                        final titulo = doc['titulo'].toString().toLowerCase();
                        final descricao = doc['descricao'].toString().toLowerCase();
                        return titulo.contains(searchQuery.toLowerCase()) ||
                            descricao.contains(searchQuery.toLowerCase());
                      }).toList();

                      if (filteredDocs.isEmpty) {
                        return Center(
                          child: Text('Nenhuma tarefa encontrada.'),
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          final item = filteredDocs[index].data() as Map;
                          final id = filteredDocs[index].id;

                          return ListTile(
                            title: Text(item['titulo']),
                            subtitle: Text(item['descricao']),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetalhesTarefaView(id: id, item: item),
                                ),
                              );
                            },
                          );
                        },
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetalhesTarefaView extends StatelessWidget {
  final String id;
  final Map item;

  DetalhesTarefaView({required this.id, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item['titulo']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Título:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(item['titulo']),
            SizedBox(height: 20),
            Text(
              'Descrição:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(item['descricao']),
          ],
        ),
      ),
    );
  }
}
