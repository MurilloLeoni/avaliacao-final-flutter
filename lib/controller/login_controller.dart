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
      FirebaseFirestore.instance.collection('usuarios').add({
        "nome": nome,
        "uid": resultado.user!.uid,
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
  //ATUALIZAR DADOS
  //
  void atualizarDados(
      BuildContext context, String nome, String telefone, String cpf) async {
    try {
      var user = FirebaseAuth.instance.currentUser;
      var uid = user?.uid;

      if (uid != null) {
        var userDoc =
            FirebaseFirestore.instance.collection('usuarios').doc(uid);
        var userSnapshot = await userDoc.get();

        if (userSnapshot.exists) {
          await userDoc.update({
            'nome': nome,
            'telefone': telefone,
            'cpf': cpf,
          });

          sucesso(context, 'Dados atualizados com sucesso!');
          Navigator.pop(context);
        } else {
          erro(context, 'Documento do usuário não encontrado no Firestore.');
        }
      } else {
        erro(context, 'UID do usuário não encontrado.');
      }
    } catch (e) {
      erro(context, 'Erro ao atualizar dados: ${e.toString()}');
    }
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
  idUsuario() {
    return FirebaseAuth.instance.currentUser!.uid;
  }
}
