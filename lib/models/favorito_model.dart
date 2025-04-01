import 'package:cloud_firestore/cloud_firestore.dart';

class Favorito {
  final String id; // ID del documento en Firestore
  final String usuarioUid;
  final String palabraId;
  final DateTime fecha;

  Favorito({
    required this.id,
    required this.usuarioUid,
    required this.palabraId,
    required this.fecha,
  });

  factory Favorito.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!; // El ! asegura que data no es null
    return Favorito(
      id: doc.id,
      usuarioUid: data['usuario_uid'] as String,
      palabraId: data['palabra_id'] as String,
      fecha: (data['fecha'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usuario_uid': usuarioUid,
      'palabra_id': palabraId,
      'fecha': Timestamp.fromDate(fecha),
    };
  }
}