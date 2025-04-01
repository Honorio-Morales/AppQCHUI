import 'package:cloud_firestore/cloud_firestore.dart';

class Pregunta {
  final String id;
  final String usuarioUid;
  final String nombreUsuario;
  final String texto;
  final DateTime fecha;
  final List<Respuesta>? respuestas;

  Pregunta({
    required this.id,
    required this.usuarioUid,
    required this.nombreUsuario,
    required this.texto,
    required this.fecha,
    this.respuestas,
  });

  factory Pregunta.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Pregunta(
      id: doc.id,
      usuarioUid: data['usuario_uid'],
      nombreUsuario: data['nombreUsuario'] ?? 'Usuario desconocido',
      texto: data['texto'],
      fecha: (data['fecha'] as Timestamp).toDate(),
      respuestas: data['respuestas'] != null
          ? (data['respuestas'] as List).map((r) => Respuesta.fromMap(r)).toList()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'usuario_uid': usuarioUid,
      'nombreUsuario': nombreUsuario,
      'texto': texto,
      'fecha': fecha,
    };
  }
}

class Respuesta {
  final String usuarioUid;
  final String texto;
  final DateTime fecha;

  Respuesta({
    required this.usuarioUid,
    required this.texto,
    required this.fecha,
  });

  factory Respuesta.fromMap(Map<String, dynamic> map) {
    return Respuesta(
      usuarioUid: map['usuario_uid'],
      texto: map['texto'],
      fecha: (map['fecha'] as Timestamp).toDate(),
    );
  }
}
