// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'package:flutter/material.dart';

import '../controller/login_controller.dart';

class CadastrarView extends StatefulWidget {
  const CadastrarView({super.key});

  @override
  State<CadastrarView> createState() => _CadastrarViewState();
}

class _CadastrarViewState extends State<CadastrarView> {
  var txtNome = TextEditingController();
  var txtEmail = TextEditingController();
  var txtSenha = TextEditingController();
  var txtConfirmarSenha = TextEditingController();
  var txtTelefone = TextEditingController();
  var txtCpf = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _hasUppercase = false;
  bool _hasDigits = false;
  bool _hasLowercase = false;
  bool _hasSpecialCharacters = false;
  bool _hasMinLength = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _validatePassword(String value) {
    setState(() {
      _hasUppercase = value.contains(RegExp(r'[A-Z]'));
      _hasDigits = value.contains(RegExp(r'[0-9]'));
      _hasLowercase = value.contains(RegExp(r'[a-z]'));
      _hasSpecialCharacters = value.contains(RegExp(r'[!@#\$&*~]'));
      _hasMinLength = value.length >= 8;
    });
  }

  String? _validateEmail(String? value) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z0-9]+');
    if (value == null || value.isEmpty) {
      return 'Email não pode estar vazio';
    } else if (!emailRegExp.hasMatch(value)) {
      return 'Digite um email válido';
    }
    return null;
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

  String? _validatePasswordConfirmation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha não pode estar vazia';
    } else if (value != txtSenha.text) {
      return 'As senhas não correspondem';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromARGB(255, 217, 222, 224),
        padding: EdgeInsets.fromLTRB(30, 50, 30, 85),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Criar Conta',
                  style: TextStyle(fontSize: 40),
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: txtNome,
                  decoration: InputDecoration(
                      labelText: 'Nome',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nome não pode estar vazio';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: txtEmail,
                  decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder()),
                  validator: _validateEmail,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: txtSenha,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: Icon(Icons.password),
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  onChanged: _validatePassword,
                  validator: (value) {
                    if (!_hasUppercase ||
                        !_hasDigits ||
                        !_hasLowercase ||
                        !_hasSpecialCharacters ||
                        !_hasMinLength) {
                      return 'A senha deve atender a todos os requisitos abaixo';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PasswordRequirement(
                      condition: _hasUppercase,
                      requirement: "Contém uma letra maiúscula",
                    ),
                    PasswordRequirement(
                      condition: _hasLowercase,
                      requirement: "Contém uma letra minúscula",
                    ),
                    PasswordRequirement(
                      condition: _hasDigits,
                      requirement: "Contém um número",
                    ),
                    PasswordRequirement(
                      condition: _hasSpecialCharacters,
                      requirement: "Contém um caractere especial (!@#\$&*~)",
                    ),
                    PasswordRequirement(
                      condition: _hasMinLength,
                      requirement: "Possui pelo menos 8 caracteres",
                    ),
                  ],
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: txtConfirmarSenha,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Senha',
                    prefixIcon: Icon(Icons.password),
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: _validatePasswordConfirmation,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: txtTelefone,
                  decoration: InputDecoration(
                      labelText: 'Telefone',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder()),
                  validator: _validatePhone,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: txtCpf,
                  decoration: InputDecoration(
                      labelText: 'CPF',
                      prefixIcon: Icon(Icons.perm_identity),
                      border: OutlineInputBorder()),
                  validator: _validateCpf,
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 214, 210, 200),
                        minimumSize: Size(140, 40),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'CANCELAR',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                        backgroundColor:
                            const Color.fromARGB(255, 160, 158, 153),
                        minimumSize: Size(140, 40),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          LoginController().criarConta(
                            context,
                            txtNome.text,
                            txtEmail.text,
                            txtSenha.text,
                            txtTelefone.text,
                            txtCpf.text,
                          );
                        }
                      },
                      child: Text(
                        'CRIAR',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordRequirement extends StatelessWidget {
  final bool condition;
  final String requirement;

  PasswordRequirement({required this.condition, required this.requirement});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          condition ? Icons.check : Icons.close,
          color: condition ? Colors.green : Colors.red,
        ),
        SizedBox(width: 10),
        Text(requirement),
      ],
    );
  }
}
