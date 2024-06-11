import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../view/util.dart';

class LoginController {
  //
  // CRIAR CONTA
  // Adiciona a conta de um novo usuário no serviço
  // Firebase Authentication
  //
  criarConta(BuildContext context, String nome, String email, String senha,
      String telefone, String cpf) {
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email,
      password: senha,
    )
        .then((resultado) {
      // Sucesso

      //
      // Armazenar o NOME, UID, TELEFONE e CPF do usuário em uma coleção
      // no banco de dados Firestore
      //
      var uid = resultado.user!.uid;
      FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        "nome": nome,
        "uid": uid, // Usando o UID do usuário como ID do documento
        "telefone": telefone,
        "cpf": cpf,
      });

      sucesso(context, 'Usuário criado com sucesso!');
      Navigator.pop(context);
    }).catchError((e) {
      // Erro

      switch (e.code) {
        case 'email-already-in-use':
          erro(context, 'O email já foi cadastrado.');
          break;
        default:
          erro(context, 'ERRO: ${e.code.toString()}');
      }
    });
  }

  //
  // ATUALIZAR DADOS
  //
  void salvarDados(
      BuildContext context, String nome, String telefone, String cpf) {
    var uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      erro(context, 'Usuário não está autenticado.');
      return;
    }
    if (nome.isEmpty || telefone.isEmpty || cpf.isEmpty) {
      erro(context, 'Todos os campos devem ser preenchidos.');
      return;
    }
    var dadosAtualizados = {
      "nome": nome,
      "telefone": telefone,
      "cpf": cpf,
    };

    FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .update(dadosAtualizados)
        .then((value) {
      erro(context, 'Não foi possível atualizar os dados.');
    }).catchError((e) {
      sucesso(context, 'Dados atualizados com sucesso!');
    }).whenComplete(() {
      print('Operação de atualização de dados concluída.');
      Navigator.pop(context);
    });
  }

  //
  // LOGIN
  //
  login(BuildContext context, String email, String senha) {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: email,
      password: senha,
    )
        .then((resultado) {
      sucesso(context, 'Usuário autenticado com sucesso!');
      Navigator.pushNamed(context, 'principal');
    }).catchError((e) {
      switch (e.code) {
        case 'invalid-credential':
          erro(context, 'Email e/ou senha inválida.');
          break;
        case 'invalid-email':
          erro(context, 'O formato do email é inválido.');
          break;
        default:
          erro(context, 'ERRO: ${e.code.toString()}');
      }
    });
  }

  //
  // ESQUECEU A SENHA
  //
  esqueceuSenha(BuildContext context, String email) {
    if (email.isNotEmpty) {
      FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      sucesso(context, 'Email enviado com sucesso!');
    } else {
      erro(context, 'Favor preencher o campo email.');
    }
  }

  //
  // LOGOUT
  //
  logout() {
    FirebaseAuth.instance.signOut();
  }

  //
  // ID do Usuário Logado
  //
  String idUsuario() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }
}
