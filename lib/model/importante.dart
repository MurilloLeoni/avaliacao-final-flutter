class TarefaImportante {
  final String uid;
  final String titulo;
  final String descricao;
  final DateTime data;

  TarefaImportante({
    required this.uid,
    required this.titulo,
    required this.descricao,
    required this.data,
  });

  // Converte um objeto Dart em um JSOn
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'titulo': titulo,
      'descricao': descricao,
      'data': data.toIso8601String(),
    };
  }

  // Converte um JSON em um objeto Dart
  factory TarefaImportante.fromJson(Map<String, dynamic> dados) {
    return TarefaImportante(
      uid: dados['uid'],
      titulo: dados['titulo'],
      descricao: dados['descricao'],
      data: DateTime.parse(dados['data']),
    );
  }
}
