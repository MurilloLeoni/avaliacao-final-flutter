// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../controller/login_controller.dart';
import '../controller/tarefa_controller.dart';
import '../model/tarefa.dart';
import 'buscar_view.dart';
import 'alterar_dados_view.dart';
import 'tarefas_importantes_view.dart';

class PrincipalView extends StatefulWidget {
  const PrincipalView({super.key});

  @override
  State<PrincipalView> createState() => _PrincipalViewState();
}

class _PrincipalViewState extends State<PrincipalView> {
  var txtTitulo = TextEditingController();
  var txtDescricao = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 44, 217, 64),
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
              _scaffoldKey.currentState?.openEndDrawer();
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      endDrawer: Drawer(
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
            ListTile(
              leading: Icon(Icons.priority_high),
              title: Text('Histórico'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TarefasImportantesView()),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: Color.fromARGB(255, 217, 222, 224),
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

                      bool importante = item['importante'] ?? false;

                      var dataFormatada = item['data'] != null
                          ? DateTime.parse(item['data'])
                              .toLocal()
                              .toString()
                              .split(' ')[0]
                          : 'Sem data';

                      return ListTile(
                        title: Text(item['titulo']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['descricao']),
                            SizedBox(height: 5),
                            Text('Importante: ${importante ? 'Sim' : 'Não'}'),
                            Text('Data: $dataFormatada'),
                          ],
                        ),
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
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(Icons.search),
          ),
          Container(
            margin: EdgeInsets.only(left: 50),
            child: FloatingActionButton(
              onPressed: () {
                salvarTarefa(context);
              },
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.black),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  void salvarTarefa(context, {docId}) {
    bool isImportante = false;
    DateTime? selectedDate;

    if (docId != null) {
      var doc = FirebaseFirestore.instance.collection('tarefas').doc(docId);
      doc.get().then((snapshot) {
        if (snapshot.exists) {
          var data = snapshot.data() as Map<String, dynamic>;
          txtTitulo.text = data['titulo'];
          txtDescricao.text = data['descricao'];
          isImportante = data['importante'] ?? false;
          selectedDate =
              data['data'] != null ? DateTime.parse(data['data']) : null;
        }
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text((docId == null) ? "Adicionar Tarefa" : "Editar Tarefa"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
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
                    SizedBox(height: 15),
                    CheckboxListTile(
                      title: Text("Importante"),
                      value: isImportante,
                      onChanged: (bool? value) {
                        setState(() {
                          isImportante = value ?? false;
                        });
                      },
                    ),
                    SizedBox(height: 15),
                    ListTile(
                      title: Text(
                        selectedDate == null
                            ? "Nenhuma data selecionada"
                            : "Data: ${selectedDate!.toLocal()}".split(' ')[0],
                      ),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              );
            },
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
                  importante: isImportante,
                  data: selectedDate ?? DateTime.now(),
                );

                if (docId == null) {
                  TarefaController().adicionar(context, t);
                } else {
                  TarefaController().atualizar(context, docId, t);
                }

                txtTitulo.clear();
                txtDescricao.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
