import 'package:cloud_firestore/cloud_firestore.dart';

class Palabra {
  final String id; // ID del documento en Firestore
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
      palabraEspanol: data['espanol'] ?? '',
      palabraQuechua: data['quechua'] ?? '',
      categoria: data['categoria'],
      ejemplo: data['ejemplo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'espanol': palabraEspanol,
      'quechua': palabraQuechua,
      'categoria': categoria,
      'ejemplo': ejemplo,
    };
  }
}