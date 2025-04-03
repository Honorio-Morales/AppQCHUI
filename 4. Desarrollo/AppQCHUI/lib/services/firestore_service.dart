import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/palabra_model.dart';
import '../models/favorito_model.dart';
import '../models/pregunta_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Diccionario
  Stream<List<Palabra>> getPalabras() {
    return _firestore.collection('diccionario').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Palabra.fromFirestore(doc)).toList();
    });
  }

  Future<List<Palabra>> buscarPalabras(String query) async {
    final snapshot = await _firestore
        .collection('diccionario')
        .where('palabraQuechua', isGreaterThanOrEqualTo: query)
        .where('palabraQuechua', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    return snapshot.docs.map((doc) => Palabra.fromFirestore(doc)).toList();
  }

  // Favoritos
  Future<void> addFavorito(Favorito favorito) {
    return _firestore.collection('favoritos').add(favorito.toMap());
  }

  Future<void> removeFavorito(String favoritoId) {
    return _firestore.collection('favoritos').doc(favoritoId).delete();
  }

  Stream<List<Favorito>> getFavoritos(String usuarioUid) {
    return _firestore
        .collection('favoritos')
        .where('usuario_uid', isEqualTo: usuarioUid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Favorito.fromFirestore(doc)).toList();
    });
  }

  Future<String?> getFavoritoId(String usuarioUid, String palabraId) async {
    final query = await _firestore
        .collection('favoritos')
        .where('usuario_uid', isEqualTo: usuarioUid)
        .where('palabra_id', isEqualTo: palabraId)
        .limit(1)
        .get();
    return query.docs.isEmpty ? null : query.docs.first.id;
  }

  Stream<bool> esFavorito(String usuarioUid, String palabraId) {
    return _firestore
        .collection('favoritos')
        .where('usuario_uid', isEqualTo: usuarioUid)
        .where('palabra_id', isEqualTo: palabraId)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  Stream<List<Palabra>> getPalabrasFavoritas(String usuarioUid) {
    return _firestore
        .collection('favoritos')
        .where('usuario_uid', isEqualTo: usuarioUid)
        .snapshots()
        .asyncMap((snapshot) async {
      final palabrasFuturas = snapshot.docs.map((doc) async {
        final palabraDoc = await _firestore.collection('diccionario').doc(doc['palabra_id']).get();
        return palabraDoc.exists ? Palabra.fromFirestore(palabraDoc) : null;
      }).toList();

      final palabras = await Future.wait(palabrasFuturas);
      return palabras.where((p) => p != null).cast<Palabra>().toList();
    });
  }

  // Métodos para preguntas/comunidad
  Future<void> addPregunta(Pregunta pregunta) async {
    await _firestore.collection('comunidad').add({
      'usuario_uid': pregunta.usuarioUid,
      'nombreUsuario': pregunta.nombreUsuario,
      'texto': pregunta.texto,
      'fecha': Timestamp.fromDate(pregunta.fecha),
    });
  }

  Stream<List<Pregunta>> getPreguntas() {
    return _firestore
        .collection('comunidad')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Pregunta.fromFirestore(doc)).toList();
    });
  }
}