import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_controller.dart';

class TarefaImportante {
  listarImportantes() {
    return FirebaseFirestore.instance
        .collection('tarefas')
        .where('uid', isEqualTo: LoginController().idUsuario())
        .where('importante',
            isEqualTo: true);
  }
}
