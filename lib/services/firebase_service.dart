import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/palabra_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener todas las palabras
  Stream<List<Palabra>> getPalabras() {
    return _firestore.collection('diccionario').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Palabra.fromFirestore(doc)).toList();
    });
  }

  // Buscar palabras por texto
  Future<List<Palabra>> buscarPalabras(String query) async {
    final result = await _firestore
        .collection('diccionario')
        .where('palabraEspanol', isGreaterThanOrEqualTo: query)
        .get();

    return result.docs.map((doc) => Palabra.fromFirestore(doc)).toList();
  }

  // Agregar o quitar favorito
  Future<void> toggleFavorito(String palabraId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Verificar si ya existe el favorito
    final favoritoRef = _firestore
        .collection('favoritos')
        .where('userId', isEqualTo: userId)
        .where('palabraId', isEqualTo: palabraId);

    final existingFav = await favoritoRef.get();

    if (existingFav.docs.isEmpty) {
      // Agregar a favoritos
      await _firestore.collection('favoritos').add({
        'userId': userId,
        'palabraId': palabraId,
      });
    } else {
      // Eliminar de favoritos
      await existingFav.docs.first.reference.delete();
    }
  }

  // Obtener favoritos del usuario
  Stream<Set<String>> getFavoritos() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value({});

    return _firestore
        .collection('favoritos')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc['palabraId'] as String).toSet();
    });
  }
}