// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../controller/login_controller.dart';
import '../view/util.dart';

class AlterarDadosView extends StatefulWidget {
  @override
  _AlterarDadosViewState createState() => _AlterarDadosViewState();
}

class _AlterarDadosViewState extends State<AlterarDadosView> {
  var txtNome = TextEditingController();
  var txtTelefone = TextEditingController();
  var txtCpf = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    carregarDadosUsuario();
  }

  void carregarDadosUsuario() async {
    var uid = LoginController().idUsuario();
    var doc =
        await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();

    if (doc.exists) {
      setState(() {
        txtNome.text = doc['nome'];
        txtTelefone.text = doc['telefone'];
        txtCpf.text = doc['cpf'];
      });
    } else {
      erro(context, 'Documento do usuário não encontrado no Firestore.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alterar Dados da Conta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: txtNome,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nome não pode estar vazio';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: txtTelefone,
                decoration: InputDecoration(
                  labelText: 'Telefone',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: _validatePhone,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: txtCpf,
                decoration: InputDecoration(
                  labelText: 'Cpf',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                validator: _validateCpf,
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Se todas as validações passarem
                    LoginController().atualizarDados(
                      context,
                      txtNome.text,
                      txtTelefone.text,
                      txtCpf.text,
                    );
                  }
                },
                child: Text('Salvar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String? _validatePhone(String? value) {
  final phoneRegExp = RegExp(r'^\d{10,11}$');
  if (value == null || value.isEmpty) {
    return 'Telefone não pode estar vazio';
  } else if (!phoneRegExp.hasMatch(value)) {
    return 'Digite um telefone válido com 10 ou 11 dígitos';
  }
  return null;
}

String? _validateCpf(String? value) {
  final cpfRegExp = RegExp(r'^\d{11}$');
  if (value == null || value.isEmpty) {
    return 'CPF não pode estar vazio';
  } else if (!cpfRegExp.hasMatch(value)) {
    return 'Digite um CPF válido com 11 dígitos';
  }
  return null;
}
