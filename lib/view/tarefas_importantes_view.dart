// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../controller/login_controller.dart';
import '../controller/tarefa_controller.dart';
import '../model/importante.dart';
import '../model/tarefa.dart';

class TarefasImportantesView extends StatelessWidget {
  const TarefasImportantesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tarefas Importantes'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('importantes')
            .where('uid', isEqualTo: LoginController().idUsuario())
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Erro: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Text('Nenhuma tarefa marcada como importante.');
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              var tarefa = TarefaImportante.fromJson(data);
              return ListTile(
                title: Text(tarefa.titulo),
                subtitle: Text(tarefa.descricao),
              );
            },
          );
        },
      ),
    );
  }
}
