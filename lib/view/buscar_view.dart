

// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controller/tarefa_controller.dart';
import '../controller/login_controller.dart';
import '../model/tarefa.dart';
import 'alterar_dados_view.dart'; // Importar a nova tela

class BuscaView extends StatefulWidget {
  @override
  _BuscaViewState createState() => _BuscaViewState();
}

class _BuscaViewState extends State<BuscaView> {
  var txtSearch = TextEditingController();
  String searchQuery = "";

  var txtTitulo = TextEditingController();
  var txtDescricao = TextEditingController();

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
                            trailing: SizedBox(
                              width: 80,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit_outlined),
                                    onPressed: () {
                                      txtTitulo.text = item['titulo'];
                                      txtDescricao.text = item['descricao'];
                                      salvarTarefa(context, docId: id);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outlined),
                                    onPressed: () {
                                      TarefaController().excluir(context, id);
                                    },
                                  ),
                                ],
                              ),
                            ),
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

  void salvarTarefa(context, {docId}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text((docId == null) ? "Adicionar Tarefa" : "Editar Tarefa"),
          content: SizedBox(
            height: 250,
            width: 300,
            child: Column(
              children: [
                TextField(
                  controller: txtTitulo,
                  decoration: InputDecoration(
                    labelText: 'Título',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: txtDescricao,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: EdgeInsets.fromLTRB(20, 0, 20, 10),
          actions: [
            TextButton(
              child: Text("fechar"),
              onPressed: () {
                txtTitulo.clear();
                txtDescricao.clear();
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text("salvar"),
              onPressed: () {
                var t = Tarefa(
                  LoginController().idUsuario(),
                  txtTitulo.text,
                  txtDescricao.text,
                );

                if (docId == null) {
                  TarefaController().adicionar(context, t);
                } else {
                  TarefaController().atualizar(context, docId, t);
                }

                txtTitulo.clear();
                txtDescricao.clear();
                Navigator.of(context).pop(); // Fechar o diálogo ao salvar
              },
            ),
          ],
        );
      },
    );
  }
}
