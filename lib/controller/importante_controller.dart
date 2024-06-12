import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_controller.dart';

class TarefaImportante {
  // Método para listar apenas tarefas marcadas como importantes
  listarImportantes() {
    return FirebaseFirestore.instance
        .collection('tarefas')
        .where('uid', isEqualTo: LoginController().idUsuario())
        .where('importante',
            isEqualTo: true); // Apenas tarefas marcadas como importantes
  }
  // Outros métodos existentes aqui
}
