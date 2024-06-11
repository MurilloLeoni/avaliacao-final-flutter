import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/importante.dart';
import '../model/tarefa.dart';
import '../view/util.dart';
import 'login_controller.dart';

class TarefaController {
  void adicionar(context, Tarefa t) {
    FirebaseFirestore.instance
        .collection('tarefas')
        .add(t.toJson())
        .then((value) {
          // Se a tarefa for marcada como importante, adicione também à coleção "importantes"
          if (t.importante) {
            TarefaImportante importante = TarefaImportante(
              uid: t.uid,
              titulo: t.titulo,
              descricao: t.descricao,
              data: t.data,
            );
            FirebaseFirestore.instance
                .collection('importantes')
                .add(importante.toJson());
          }
          sucesso(context, 'Tarefa adicionada com sucesso!');
        })
        .catchError(
            (e) => erro(context, 'Não foi possível adicionar a tarefa.'))
        .whenComplete(() => Navigator.pop(context));
  }

  //
  // Recuperar todas as tarefas do usuário que está logado
  //
  listar() {
    return FirebaseFirestore.instance
        .collection('tarefas')
        .where('uid', isEqualTo: LoginController().idUsuario())
        .where('importante', isEqualTo: true); // Filtrar tarefas importantes
  }

  //
  // ATUALIZAR
  //
  void atualizar(context, id, Tarefa t) {
    FirebaseFirestore.instance
        .collection('tarefas')
        .doc(id)
        .update(t.toJson())
        .then((value) => sucesso(context, 'Tarefa atualizada com sucesso!'))
        .catchError(
            (e) => erro(context, 'Não foi possível atualizar a tarefa.'))
        .whenComplete(() => Navigator.pop(context));
  }

  //
  // EXCLUIR
  //
  void excluir(context, id) {
    FirebaseFirestore.instance
        .collection('tarefas')
        .doc(id)
        .get()
        .then((snapshot) {
      var tarefa = Tarefa.fromJson(snapshot.data()!);
      if (tarefa.importante) {
        // Se a tarefa é importante, remova apenas da coleção "importantes"
        FirebaseFirestore.instance.collection('importantes').doc(id).delete();
      } else {
        // Se não for importante, remova da coleção "tarefas"
        FirebaseFirestore.instance.collection('tarefas').doc(id).delete();
      }
      sucesso(context, 'Tarefa excluída com sucesso!');
    }).catchError((e) => erro(context, 'Não foi possível excluir a tarefa.'));
  }
}
