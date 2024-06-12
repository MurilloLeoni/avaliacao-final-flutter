class Tarefa {
  final String uid;
  final String titulo;
  final String descricao;
  final bool importante;
  final DateTime data;

  // Construtor atualizado
  Tarefa(this.uid, this.titulo, this.descricao,
      {this.importante = false, DateTime? data})
      : this.data = data ?? DateTime.now();

  // Converte um objeto Dart em um JSON
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'titulo': titulo,
      'descricao': descricao,
      'importante': importante, // Adiciona o campo ao JSON
      'data': data.toIso8601String(), // Adiciona o campo ao JSON
    };
  }

  // Converte um JSON em um objeto Dart
  factory Tarefa.fromJson(Map<String, dynamic> dados) {
    return Tarefa(
      dados['uid'],
      dados['titulo'],
      dados['descricao'],
      importante: dados['importante'] ?? false,
      data: DateTime.parse(dados['data']),
    );
  }
}