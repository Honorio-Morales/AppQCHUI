import 'package:cloud_firestore/cloud_firestore.dart';

class Palabra {
  final String id;
  final String palabraEspanol;
  final String palabraQuechua;
  final String? categoria;
  final String? ejemplo;

  Palabra({
    required this.id,
    required this.palabraEspanol,
    required this.palabraQuechua,
    this.categoria,
    this.ejemplo,
  });

  factory Palabra.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Palabra(
      id: doc.id,
      palabraEspanol: data['palabraEspanol'] ?? '', // <-- Corregido
      palabraQuechua: data['palabraQuechua'] ?? '', // <-- Corregido
      categoria: data['categoria'],
      ejemplo: data['ejemplo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'palabraEspanol': palabraEspanol, // <-- Corregido
      'palabraQuechua': palabraQuechua, // <-- Corregido
      'categoria': categoria,
      'ejemplo': ejemplo,
    };
  }
}