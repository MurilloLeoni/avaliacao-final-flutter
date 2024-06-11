// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../controller/login_controller.dart';
import '../controller/tarefa_controller.dart';
import '../model/tarefa.dart';
import 'buscar_view.dart';
import 'alterar_dados_view.dart'; // Importar a nova tela

class PrincipalView extends StatefulWidget {
  const PrincipalView({super.key});

  @override
  State<PrincipalView> createState() => _PrincipalViewState();
}

class _PrincipalViewState extends State<PrincipalView> {
  var txtTitulo = TextEditingController();
  var txtDescricao = TextEditingController();

  // Criação da chave global para o Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Definindo a chave no Scaffold
      appBar: AppBar(
        title: Text('Tarefas'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              LoginController().logout();
              Navigator.pop(context);
            },
            icon: Icon(Icons.exit_to_app),
          ),
          IconButton(
            onPressed: () {
              // Usando a chave para abrir o endDrawer
              _scaffoldKey.currentState?.openEndDrawer();
            },
            icon: Icon(Icons.settings), // Botão de engrenagem
          ),
        ],
      ),
      endDrawer: Drawer(
        // Adicionar o Drawer lateral
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Configurações',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Alterar Dados da Conta'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlterarDadosView()),
                );
              },
            ),
            // Outras opções podem ser adicionadas aqui
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: TarefaController().listar().snapshots(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Center(
                  child: Text('Não foi possível conectar ao banco de dados'),
                );
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
              default:
                final dados = snapshot.requireData;
                if (dados.size > 0) {
                  return ListView.builder(
                    itemCount: dados.size,
                    itemBuilder: (context, index) {
                      String id = dados.docs[index].id;
                      dynamic item = dados.docs[index].data();

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
                } else {
                  return Center(
                    child: Text('Nenhuma tarefa encontrada.'),
                  );
                }
            }
          },
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BuscaView()),
              );
            },
            child: Icon(Icons.search),
          ),
          FloatingActionButton(
            onPressed: () {
              salvarTarefa(context);
            },
            child: Icon(Icons.add),
          ),
        ],
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
