//ignore_for_file: prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../controller/tarefa_controller.dart';
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
        future: TarefaController().listar().get(),
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

          // Exibir as tarefas importantes
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
             var tarefa = Tarefa.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);
              return ListTile(
                title: Text(tarefa.titulo),
                subtitle: Text(tarefa.descricao),
                // Adicione aqui qualquer outro elemento que deseje exibir
              );
            },
          );
        },
      ),
    );
  }
}
