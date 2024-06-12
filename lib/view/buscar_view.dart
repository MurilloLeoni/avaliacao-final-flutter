// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controller/tarefa_controller.dart';
import '../controller/login_controller.dart';
import '../model/tarefa.dart';

enum OrderBy { date, title, oldest, newest }

class BuscaView extends StatefulWidget {
  @override
  _BuscaViewState createState() => _BuscaViewState();
}

class _BuscaViewState extends State<BuscaView> {
  var txtSearch = TextEditingController();
  String searchQuery = "";
  OrderBy orderBy = OrderBy.date;

  var txtTitulo = TextEditingController();
  var txtDescricao = TextEditingController();

  void _showOrderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ordenar por'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Título'),
                leading: Radio<OrderBy>(
                  value: OrderBy.title,
                  groupValue: orderBy,
                  onChanged: (OrderBy? value) {
                    setState(() {
                      orderBy = value!;
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('Mais recente'),
                leading: Radio<OrderBy>(
                  value: OrderBy.oldest,
                  groupValue: orderBy,
                  onChanged: (OrderBy? value) {
                    setState(() {
                      orderBy = value!;
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('Mais antigo'),
                leading: Radio<OrderBy>(
                  value: OrderBy.newest,
                  groupValue: orderBy,
                  onChanged: (OrderBy? value) {
                    setState(() {
                      orderBy = value!;
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar Tarefas'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showOrderDialog,
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Erro: ${snapshot.error}'),
                    );
                  }

                  final dados = snapshot.requireData;
                  final filteredDocs = dados.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final titulo = data['titulo']?.toString().toLowerCase() ?? '';
                    final descricao = data['descricao']?.toString().toLowerCase() ?? '';
                    return titulo.contains(searchQuery.toLowerCase()) ||
                        descricao.contains(searchQuery.toLowerCase());
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Text('Nenhuma tarefa encontrada.'),
                    );
                  }

                  // Ordenar os resultados com base na opção selecionada
                  filteredDocs.sort((a, b) {
                    final dataA = a.data() as Map<String, dynamic>;
                    final dataB = b.data() as Map<String, dynamic>;

                    switch (orderBy) {
                      case OrderBy.date:
                        final dateA = dataA['data'] != null
                            ? DateTime.tryParse(dataA['data'])
                            : DateTime.now();
                        final dateB = dataB['data'] != null
                            ? DateTime.tryParse(dataB['data'])
                            : DateTime.now();
                        return dateB!.compareTo(dateA!); // Inverter a ordem
                      case OrderBy.title:
                        final titleA = dataA['titulo'] ?? '';
                        final titleB = dataB['titulo'] ?? '';
                        return titleA.compareTo(titleB);
                      case OrderBy.oldest:
                        final dateA = dataA['data'] != null
                            ? DateTime.tryParse(dataA['data'])
                            : DateTime.now();
                        final dateB = dataB['data'] != null
                            ? DateTime.tryParse(dataB['data'])
                            : DateTime.now();
                        return dateA!.compareTo(dateB!);
                      case OrderBy.newest:
                        final dateA = dataA['data'] != null
                            ? DateTime.tryParse(dataA['data'])
                            : DateTime.now();
                        final dateB = dataB['data'] != null
                            ? DateTime.tryParse(dataB['data'])
                            : DateTime.now();
                        return dateB!.compareTo(dateA!);
                    }
                  });

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final item = filteredDocs[index].data() as Map<String, dynamic>;
                      final id = filteredDocs[index].id;

                      return ListTile(
                        title: Text(item['titulo'] ?? ''),
                        subtitle: Text(item['descricao'] ?? ''),
                        trailing: SizedBox(
                          width: 80,
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit_outlined),
                                onPressed: () {
                                  txtTitulo.text = item['titulo'] ?? '';
                                  txtDescricao.text = item['descricao'] ?? '';
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void salvarTarefa(BuildContext context, {docId}) {
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
              child: Text("Fechar"),
              onPressed: () {
                txtTitulo.clear();
                txtDescricao.clear();
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text("Salvar"),
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

                   
